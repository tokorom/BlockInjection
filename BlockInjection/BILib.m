//
//  MILib.m
//
//  Created by ToKoRo on 2013-02-27.
//

#import "MILib.h"
#import "MIRuntime.h"
#import "MIItem.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

static MILib* sharedInstance = nil;

@interface MILib ()
@property (strong) NSMutableDictionary* dic;
@property (strong) NSMutableDictionary* backups;
@end 

@implementation MILib

#pragma mark - Memory Management

- (id)init
{
  if ((self = [super init])) {
    self.dic = [NSMutableDictionary dictionary];
    self.backups = [NSMutableDictionary dictionary];
  }
  return self;
}

#pragma mark - Public Interface
  
- (BOOL)addPreprocessToSelector:(SEL)sel forClass:(Class)class block:(id)block
{
  return [self addPreprocess:block andPostprocess:nil forSelector:sel forClass:class];
}

- (BOOL)addPostprocessToSelector:(SEL)sel forClass:(Class)class block:(id)block
{
  return [self addPreprocess:nil andPostprocess:block forSelector:sel forClass:class];
}

- (BOOL)addPreprocess:(id)preprocess andPostprocess:(id)postprocess forSelector:(SEL)sel forClass:(Class)class
{
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  Method originalMethod = class_getInstanceMethod(class, sel);
  MIItem* item;
  NSString* className = NSStringFromClass(class);

  if (![self alreadyReplacedForMethodName:methodName withClassName:className]) {
    // Rename original method
    struct mi_objc_method* method = (struct mi_objc_method*)originalMethod;
    method->method_name = sel_registerName([[MILib dummyNameFromMethodName:methodName] UTF8String]);

    item = [self addItemForMethodName:methodName withClassName:className];
    item.methodTypeEncoding = [NSString stringWithUTF8String:method_getTypeEncoding(originalMethod)];

    // Save original method
    IMP originalImp = method_getImplementation(originalMethod);
    SEL saveSel = sel_registerName([[MILib saveNameForMethodName:methodName] UTF8String]);
    class_addMethod(class, saveSel, originalImp, [item.methodTypeEncoding UTF8String]);

    // Replace forwarding methods
    if (![self replaceForwardingMethodsForClass:class withItem:item]) {
      return NO;
    }
  } else {
    item = [self itemForMethodName:methodName withClassName:className];
  }

  // Add preprocess
  if (preprocess) {
    SEL preSel = sel_registerName([[MILib preprocessNameForMethodName:methodName withItem:item] UTF8String]);
    class_addMethod(class, preSel, imp_implementationWithBlock(preprocess), [item.methodTypeEncoding UTF8String]);
    [item.preprocess addObject:[NSValue valueWithPointer:preSel]];
  }

  // Add postprocess
  if (postprocess) {
    SEL postSel = sel_registerName([[MILib postprocessNameForMethodName:methodName withItem:item] UTF8String]);
    class_addMethod(class, postSel, imp_implementationWithBlock(postprocess), [item.methodTypeEncoding UTF8String]);
    [item.postprocess addObject:[NSValue valueWithPointer:postSel]];
  }

  return YES;
}

- (BOOL)replaceForwardingMethodsForClass:(Class)class withItem:(MIItem*)item
{
  NSString* methodName;
  SEL originalSel, saveSel;
  Method method, mlibMethod;
  IMP originalImp;

  // methodSignatureForSelector:
  originalSel = @selector(methodSignatureForSelector:);
  method = class_getInstanceMethod(class, originalSel);
  originalImp = method_getImplementation(method);
  mlibMethod = class_getInstanceMethod(self.class, originalSel);
  method_setImplementation(method, method_getImplementation(mlibMethod));
  methodName = [NSString stringWithUTF8String:sel_getName(originalSel)];
  saveSel = sel_registerName([[MILib saveNameForMethodName:methodName] UTF8String]);
  class_addMethod(class, saveSel, originalImp, method_getTypeEncoding(method));

  // forwardInvocation:
  originalSel = @selector(forwardInvocation:);
  method = class_getInstanceMethod(class, originalSel);
  originalImp = method_getImplementation(method);
  mlibMethod = class_getInstanceMethod(self.class, originalSel);
  method_setImplementation(method, method_getImplementation(mlibMethod));
  methodName = [NSString stringWithUTF8String:sel_getName(originalSel)];
  saveSel = sel_registerName([[MILib saveNameForMethodName:methodName] UTF8String]);
  class_addMethod(class, saveSel, originalImp, method_getTypeEncoding(method));

  return YES;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
  SEL sel = [invocation selector];
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  MIItem* item = [MILIB itemForMethodName:methodName withClassName:NSStringFromClass(self.class)];

  if (item) {
    if (item.preprocess.count) {
      for (NSValue* selVal in item.preprocess) {
        [invocation setSelector:[selVal pointerValue]];
        [invocation invoke];
      }
    }

    [invocation setSelector:sel_registerName([[MILib saveNameForMethodName:methodName] UTF8String])];
    [invocation invoke];

    if (item.postprocess.count) {
      for (NSValue* selVal in item.postprocess) {
        [invocation setSelector:[selVal pointerValue]];
        [invocation invoke];
      }
    }
  } else {
    NSString* currentMethodName = [NSString stringWithUTF8String:sel_getName(@selector(forwardInvocation:))];
    SEL saveSel = sel_getUid([[MILib saveNameForMethodName:currentMethodName] UTF8String]);
    [self performSelector:saveSel withObject:invocation];
  }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  MIItem* item = [MILIB itemForMethodName:methodName withClassName:NSStringFromClass(self.class)];

  if (item) {
    return [NSMethodSignature signatureWithObjCTypes:[item.methodTypeEncoding UTF8String]];
  } else {
    NSString* currentMethodName = [NSString stringWithUTF8String:sel_getName(@selector(methodSignatureForSelector:))];
    SEL saveSel = sel_getUid([[MILib saveNameForMethodName:currentMethodName] UTF8String]);
    return [self performSelector:saveSel withObject:(__bridge id)(void*)sel];
  }
}

#pragma mark - Private Methods

+ (NSString*)dummyNameFromMethodName:(NSString*)methodName
{
  return [NSString stringWithFormat:@"__mi_dummy_%@", methodName];
}

+ (NSString*)saveNameForMethodName:(NSString*)methodName
{
  return [NSString stringWithFormat:@"__mi_save_%@", methodName];
}

+ (NSString*)preprocessNameForMethodName:(NSString*)methodName withItem:(MIItem*)item
{
  return [NSString stringWithFormat:@"__mi_pre_%d_%@", item.preprocess.count + 1, methodName];
}

+ (NSString*)postprocessNameForMethodName:(NSString*)methodName withItem:(MIItem*)item
{
  return [NSString stringWithFormat:@"__mi_post_%d_%@", item.postprocess.count + 1, methodName];
}

- (MIItem*)addItemForMethodName:(NSString*)methodName withClassName:(NSString*)className
{
  MIItem* item = [MIItem new];
  [self.dic setObject:item forKey:[self itemKeyWithClassName:className withMethodName:methodName]];
  return item;
}

- (MIItem*)itemForMethodName:(NSString*)methodName withClassName:(NSString*)className
{
  return [self.dic objectForKey:[self itemKeyWithClassName:className withMethodName:methodName]];
}

- (BOOL)alreadyReplacedForMethodName:(NSString*)methodName withClassName:(NSString*)className
{
  return nil != [self.dic objectForKey:[self itemKeyWithClassName:className withMethodName:methodName]];
}

- (NSString*)itemKeyWithClassName:(NSString*)className withMethodName:(NSString*)methodName
{
  return [NSString stringWithFormat:@"%@::%@", className, methodName];
}

#pragma mark - Singleton

+ (MILib*)sharedInstance
{
  @synchronized(self) {
    if (nil == sharedInstance) {
      [self new];
    }
  }
  return sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone
{
  @synchronized(self) {
    if (nil == sharedInstance) {
      sharedInstance = [super allocWithZone:zone];
      return sharedInstance;
    }
  }
  return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
  return self;
}

#pragma clang diagnostic pop

@end
