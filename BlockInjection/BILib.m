//
//  BILib.m
//
//  Created by ToKoRo on 2013-02-27.
//

#import "BILib.h"
#import "BIRuntime.h"
#import "BIItem.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

static BILib* sharedInstance = nil;

@interface BILib ()
@property (strong) NSMutableDictionary* dic;
@property (strong) NSMutableDictionary* backupTypes;
@property (strong) NSMutableDictionary* preprocessCounts;
@property (strong) NSMutableDictionary* postprocessCounts;
@end 

@implementation BILib

#pragma mark - Memory Management

- (id)init
{
  if ((self = [super init])) {
    self.dic = [NSMutableDictionary dictionary];
    self.backupTypes = [NSMutableDictionary dictionary];
    self.preprocessCounts = [NSMutableDictionary dictionary];
    self.postprocessCounts = [NSMutableDictionary dictionary];
  }
  return self;
}

#pragma mark - Public Interface
  
- (BOOL)insertPreprocessToSelector:(SEL)sel forClass:(Class)class block:(id)block
{
  return [self insertPreprocess:block andPostprocess:nil forSelector:sel forClass:class];
}

- (BOOL)insertPostprocessToSelector:(SEL)sel forClass:(Class)class block:(id)block
{
  return [self insertPreprocess:nil andPostprocess:block forSelector:sel forClass:class];
}

- (BOOL)insertPreprocess:(id)preprocess andPostprocess:(id)postprocess forSelector:(SEL)sel forClass:(Class)class
{
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  Method originalMethod = class_getInstanceMethod(class, sel);
  BIItem* item;
  NSString* className = NSStringFromClass(class);

  if (![self alreadyReplacedForMethodName:methodName withClassName:className]) {
    // Rename original method
    if (originalMethod) {
      struct mi_objc_method* method = (struct mi_objc_method*)originalMethod;
      method->method_name = sel_registerName([[BILib dummyNameFromMethodName:methodName] UTF8String]);

      // Save original method
      IMP originalImp = method_getImplementation(originalMethod);
      SEL saveSel = sel_registerName([[BILib saveNameForMethodName:methodName] UTF8String]);
      class_addMethod(class, saveSel, originalImp, [item.methodTypeEncoding UTF8String]);

      // Replace forwarding methods
      if (![self replaceForwardingMethodsForClass:class withItem:item]) {
        return NO;
      }
    }

    // Add BIItem
    item = [self addItemForMethodName:methodName withClassName:className];
    if (originalMethod) {
      item.methodTypeEncoding = [NSString stringWithUTF8String:method_getTypeEncoding(originalMethod)];
      [self.backupTypes setObject:item.methodTypeEncoding forKey:methodName];
    } else {
      item.methodTypeEncoding = [self.backupTypes objectForKey:methodName];
    }

  } else {
    item = [self itemForMethodName:methodName withClassName:className];
  }

  // Insert preprocess
  if (preprocess) {
    SEL preSel = sel_registerName([[BILib preprocessNameForMethodName:methodName withItem:item] UTF8String]);
    class_addMethod(class, preSel, imp_implementationWithBlock(preprocess), [item.methodTypeEncoding UTF8String]);
    [item.preprocess addObject:[NSValue valueWithPointer:preSel]];
  }

  // Insert postprocess
  if (postprocess) {
    SEL postSel = sel_registerName([[BILib postprocessNameForMethodName:methodName withItem:item] UTF8String]);
    class_addMethod(class, postSel, imp_implementationWithBlock(postprocess), [item.methodTypeEncoding UTF8String]);
    [item.postprocess addObject:[NSValue valueWithPointer:postSel]];
  }

  return YES;
}

- (BOOL)insertPreprocessToMethodName:(NSString*)methodName forClassName:(NSString*)className block:(id)block
{
  Class class = objc_getClass([className UTF8String]);
  SEL sel = sel_getUid([methodName UTF8String]);
  return [self insertPreprocessToSelector:sel forClass:class block:block];
}

- (BOOL)insertPostprocessToMethodName:(NSString*)methodName forClassName:(NSString*)className block:(id)block
{
  Class class = objc_getClass([className UTF8String]);
  SEL sel = sel_getUid([methodName UTF8String]);
  return [self insertPostprocessToSelector:sel forClass:class block:block];
}

- (void)clear
{
  self.dic = [NSMutableDictionary dictionary];
}

#pragma mark - Forwarding

- (void)forwardInvocation:(NSInvocation*)invocation
{
  SEL sel = [invocation selector];
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  BIItem* item = [BILIB itemForMethodName:methodName withClassName:NSStringFromClass(self.class)];

  if (item) {
    if (item.preprocess.count) {
      for (NSValue* selVal in item.preprocess) {
        [invocation setSelector:[selVal pointerValue]];
        [invocation invoke];
      }
    }

    [invocation setSelector:sel_registerName([[BILib saveNameForMethodName:methodName] UTF8String])];
    [invocation invoke];

    if (item.postprocess.count) {
      for (NSValue* selVal in item.postprocess) {
        [invocation setSelector:[selVal pointerValue]];
        [invocation invoke];
      }
    }
  } else {
    NSString* currentMethodName = [NSString stringWithUTF8String:sel_getName(@selector(forwardInvocation:))];
    SEL saveSel = sel_getUid([[BILib saveNameForMethodName:currentMethodName] UTF8String]);
    [self performSelector:saveSel withObject:invocation];
  }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  BIItem* item = [BILIB itemForMethodName:methodName withClassName:NSStringFromClass(self.class)];

  if (item) {
    return [NSMethodSignature signatureWithObjCTypes:[item.methodTypeEncoding UTF8String]];
  } else {
    NSString* currentMethodName = [NSString stringWithUTF8String:sel_getName(@selector(methodSignatureForSelector:))];
    SEL saveSel = sel_getUid([[BILib saveNameForMethodName:currentMethodName] UTF8String]);
    return [self performSelector:saveSel withObject:(__bridge id)(void*)sel];
  }
}

#pragma mark - Private Methods

- (BOOL)replaceForwardingMethodsForClass:(Class)class withItem:(BIItem*)item
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
  saveSel = sel_registerName([[BILib saveNameForMethodName:methodName] UTF8String]);
  class_addMethod(class, saveSel, originalImp, method_getTypeEncoding(method));

  // forwardInvocation:
  originalSel = @selector(forwardInvocation:);
  method = class_getInstanceMethod(class, originalSel);
  originalImp = method_getImplementation(method);
  mlibMethod = class_getInstanceMethod(self.class, originalSel);
  method_setImplementation(method, method_getImplementation(mlibMethod));
  methodName = [NSString stringWithUTF8String:sel_getName(originalSel)];
  saveSel = sel_registerName([[BILib saveNameForMethodName:methodName] UTF8String]);
  class_addMethod(class, saveSel, originalImp, method_getTypeEncoding(method));

  return YES;
}

+ (NSString*)dummyNameFromMethodName:(NSString*)methodName
{
  return [NSString stringWithFormat:@"__mi_dummy_%@", methodName];
}

+ (NSString*)saveNameForMethodName:(NSString*)methodName
{
  return [NSString stringWithFormat:@"__mi_save_%@", methodName];
}

+ (NSString*)preprocessNameForMethodName:(NSString*)methodName withItem:(BIItem*)item
{
  int count = [[BILIB.preprocessCounts objectForKey:methodName] intValue];
  ++count;
  [BILIB.preprocessCounts setObject:[NSNumber numberWithInt:count] forKey:methodName];
  return [NSString stringWithFormat:@"__mi_pre_%d_%@", count, methodName];
}

+ (NSString*)postprocessNameForMethodName:(NSString*)methodName withItem:(BIItem*)item
{
  int count = [[BILIB.postprocessCounts objectForKey:methodName] intValue];
  ++count;
  [BILIB.postprocessCounts setObject:[NSNumber numberWithInt:count] forKey:methodName];
  return [NSString stringWithFormat:@"__mi_post_%d_%@", count, methodName];
}

- (BIItem*)addItemForMethodName:(NSString*)methodName withClassName:(NSString*)className
{
  BIItem* item = [BIItem new];
  [self.dic setObject:item forKey:[self itemKeyWithClassName:className withMethodName:methodName]];
  return item;
}

- (BIItem*)itemForMethodName:(NSString*)methodName withClassName:(NSString*)className
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

+ (BILib*)sharedInstance
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
