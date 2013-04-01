//
//  BILib.m
//
//  Created by ToKoRo on 2013-02-27.
//

#import "BILib.h"
#import "BIItem.h"
#import "BIItemManager.h"
#import "BILibArg.h"
#import <objc/runtime.h>

@implementation BILib

#pragma mark - Public Interface
  
+ (NSString*)prettyFunction
{
  BIItem* item = [[BIItemManager sharedInstance] currentItem];
  return [item prettyFunction];
}

+ (BOOL)injectToClass:(Class)class selector:(SEL)sel preprocess:(id)preprocess;
{
  return [BILib injectToSelector:sel forClass:class preprocess:preprocess postprocess:nil];
}

+ (BOOL)injectToClass:(Class)class selector:(SEL)sel postprocess:(id)postprocess;
{
  return [BILib injectToSelector:sel forClass:class preprocess:nil postprocess:postprocess];
}

+ (BOOL)injectToClassWithName:(NSString*)className methodName:(NSString*)methodName preprocess:(id)preprocess;
{
  Class class = objc_getClass([className UTF8String]);
  SEL sel = sel_getUid([methodName UTF8String]);
  return [BILib injectToClass:class selector:sel preprocess:preprocess];
}

+ (BOOL)injectToClassWithName:(NSString*)className methodName:(NSString*)methodName postprocess:(id)postprocess;
{
  Class class = objc_getClass([className UTF8String]);
  SEL sel = sel_getUid([methodName UTF8String]);
  return [BILib injectToClass:class selector:sel postprocess:postprocess];
}

+ (BOOL)injectToClassWithNames:(NSArray*)classNames methodNames:(NSArray*)methodNames preprocess:(id)preprocess
{
  BOOL failed = NO;
  for (NSString* className in classNames) {
    for (NSString* methodName in methodNames) {
      failed |= ![BILib injectToClassWithName:className methodName:methodName preprocess:preprocess];
    }
  }
  return !failed;
}

+ (BOOL)injectToClassWithNames:(NSArray*)classNames methodNames:(NSArray*)methodNames postprocess:(id)postprocess
{
  BOOL failed = NO;
  for (NSString* className in classNames) {
    for (NSString* methodName in methodNames) {
      failed |= ![BILib injectToClassWithName:className methodName:methodName postprocess:postprocess];
    }
  }
  return !failed;
}

+ (BOOL)injectToClassWithNameRegex:(NSRegularExpression*)classNameRegex methodNameRegex:(NSRegularExpression*)methodNameRegex preprocess:(id)preprocess
{
  BOOL failed = NO;
  NSArray* matchClasses = [BILib classesWithRegex:classNameRegex];
  for (NSValue* classValue in matchClasses) {
    Class class = [classValue pointerValue];
    NSArray* matchSelectors = [BILib selectorsWithRegex:methodNameRegex forClass:class];
    for (NSValue* selValue in matchSelectors) {
      SEL sel = [selValue pointerValue];
      failed |= ![BILib injectToClass:class selector:sel preprocess:preprocess];
    }
  }
  return !failed;
}

+ (BOOL)injectToClassWithNameRegex:(NSRegularExpression*)classNameRegex methodNameRegex:(NSRegularExpression*)methodNameRegex postprocess:(id)postprocess
{
  BOOL failed = NO;
  NSArray* matchClasses = [BILib classesWithRegex:classNameRegex];
  for (NSValue* classValue in matchClasses) {
    Class class = [classValue pointerValue];
    NSArray* matchSelectors = [BILib selectorsWithRegex:methodNameRegex forClass:class];
    for (NSValue* selValue in matchSelectors) {
      SEL sel = [selValue pointerValue];
      failed |= ![BILib injectToClass:class selector:sel postprocess:postprocess];
    }
  }
  return !failed;
}

+ (void)clear
{
  [[BIItemManager sharedInstance] clear];
}

+ (BOOL)replaceImplementationForClass:(Class)class selector:(SEL)sel block:(id)block
{
  Method method = [BILib getMethodInClass:class selector:sel];
  if (method) {
    if (method_setImplementation(method, imp_implementationWithBlock(block))) {
      return YES;
    }
  }
  return NO;
}

+ (BOOL)replaceImplementationForClassName:(NSString*)className methodName:(NSString*)methodName block:(id)block
{
  Class class = objc_getClass([className UTF8String]);
  SEL sel = sel_getUid([methodName UTF8String]);
  return [BILib replaceImplementationForClass:class selector:sel block:block];
}

#pragma mark - Private Methods

+ (NSString*)saveNameForMethodName:(NSString*)methodName
{
  return [NSString stringWithFormat:@"__mi_save_%@", methodName];
}

+ (NSString*)preprocessNameForMethodName:(NSString*)methodName index:(int)index
{
  return [NSString stringWithFormat:@"__mi_pre_%d_%@", index, methodName];
}

+ (NSString*)postprocessNameForMethodName:(NSString*)methodName index:(int)index
{
  return [NSString stringWithFormat:@"__mi_post_%d_%@", index, methodName];
}

+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class preprocess:(id)preprocess postprocess:(id)postprocess
{
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  SEL saveSel = sel_registerName([[BILib saveNameForMethodName:methodName] UTF8String]);
  BOOL isClassMethod = NO;
  Method originalMethod = [BILib getMethodInClass:class selector:sel isClassMethod:&isClassMethod];
  Method savedMethod = [BILib getMethodInClass:class selector:saveSel];

  if (!originalMethod) {
    NSLog(@"BILib: [%@ %@] is not found.", NSStringFromClass(class), NSStringFromSelector(sel));
    return NO;
  }

  if (!savedMethod) {
    // Save original method
    [BILib addMethodToClass:class selector:saveSel imp:method_getImplementation(originalMethod) typeEncoding:method_getTypeEncoding(originalMethod) isClassMethod:isClassMethod];
  }

  // Replace implementation
  BIItem* item = [[BIItemManager sharedInstance] itemForMethodName:methodName forClass:class];
  if (!item) {
    item = [BIItem new];
    item.targetClass = class;
    item.targetSel = sel;
    item.originalSel = saveSel;
    item.originalMethod = originalMethod;
    item.numberOfArguments = method_getNumberOfArguments(originalMethod) - 2;
    item.signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(originalMethod)];
    item.isClassMethod = isClassMethod;
    [[BIItemManager sharedInstance] setItem:item forMethodName:methodName forClass:class];
  }
  [BILib savePreprocess:preprocess andPostprocess:postprocess withItem:item forMethodName:methodName];
  [BILib replaceImplementationWithItem:item];

  return YES;
}

+ (Method)getMethodInClass:(Class)class selector:(SEL)selector
{
  return [BILib getMethodInClass:class selector:selector isClassMethod:NULL];
}

+ (Method)getMethodInClass:(Class)class selector:(SEL)selector isClassMethod:(BOOL*)isClassMethod
{
  if (isClassMethod) *isClassMethod = NO;
  Method method = class_getInstanceMethod(class, selector);
  if (!method) {
    method = class_getClassMethod(class, selector);
    if (method) {
      if (isClassMethod) *isClassMethod = YES;
    }
  }
  return method;
}

+ (void)addMethodToClass:(Class)class selector:(SEL)selector imp:(IMP)imp typeEncoding:(const char*)typeEncoding isClassMethod:(BOOL)isClassMethod
{
  Method method = [BILib getMethodInClass:class selector:selector];
  if (method) {
    method_setImplementation(method, imp);
  } else {
    if (isClassMethod) {
      class = object_getClass(class);
    }
    class_addMethod(class, selector, imp, typeEncoding);
  }
}

+ (void)savePreprocess:(id)preprocess andPostprocess:(id)postprocess withItem:(BIItem*)item forMethodName:(NSString*)methodName
{
  if (preprocess) {
    // Save preprocess
    SEL preprocessSel = sel_registerName([[BILib preprocessNameForMethodName:methodName index:[item numberOfPreprocess]] UTF8String]);
    [BILib addMethodToClass:item.targetClass
                   selector:preprocessSel
                        imp:imp_implementationWithBlock(preprocess)
               typeEncoding:method_getTypeEncoding(item.originalMethod)
              isClassMethod:item.isClassMethod];
    [item addPreprocessForSelector:preprocessSel];
  }
  if (postprocess) {
    // Save postprocess
    SEL postprocessSel = sel_registerName([[BILib postprocessNameForMethodName:methodName index:[item numberOfPostprocess]] UTF8String]);
    [BILib addMethodToClass:item.targetClass
                   selector:postprocessSel
                        imp:imp_implementationWithBlock(postprocess)
               typeEncoding:method_getTypeEncoding(item.originalMethod)
              isClassMethod:item.isClassMethod];
    [item addPostprocessForSelector:postprocessSel];
  }
}

+ (void)replaceImplementationWithItem:(BIItem*)item
{
  if (item.signature) {
    id replaceBlock = ^(id target, ...){
      [[BIItemManager sharedInstance] setCurrentItem:item];
      void* retp = NULL;
      NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:item.signature];
      [invocation setTarget:target];
      // Set arguments
      va_list argp;
      va_start(argp, target);
      [BILibArg sendArgumentsToInvocation:invocation arguments:&argp numberOfArguments:item.numberOfArguments signature:item.signature];
      va_end(argp);
      // Preprocess
      [item invokePreprocessWithInvocation:invocation];
      // Original
      [invocation setSelector:item.originalSel];
      [invocation invoke];
      // Get return value
      NSUInteger returnLength = [[invocation methodSignature] methodReturnLength];
      if (returnLength) {
        void* result = __builtin_alloca(returnLength);
        [invocation getReturnValue:result];
        retp = result;
      }
      // Postprocess
      [item invokePostprocessWithInvocation:invocation];
      return retp ? *(void**)retp : NULL;
    };
    method_setImplementation(item.originalMethod, imp_implementationWithBlock(replaceBlock));
  }
}

+ (NSArray*)classesWithRegex:(NSRegularExpression*)regex
{
  @autoreleasepool {
    NSMutableArray* retClasses = [NSMutableArray array];
    int numClasses;
    numClasses = objc_getClassList(NULL, 0);
    if (0 < numClasses) {
      Class* classes = (Class*)malloc(sizeof(Class) * numClasses);
      objc_getClassList(classes, numClasses);
      for (int i = 0; i < numClasses; ++i) {
        Class class = classes[i];
        NSString* className = NSStringFromClass(class);
        NSTextCheckingResult* match = [regex firstMatchInString:className options:0 range:NSMakeRange(0, className.length)];
        if (0 < match.numberOfRanges) {
          [retClasses addObject:[NSValue valueWithPointer:(void*)class]];
        }
      }
      free(classes);
    }
    return retClasses;
  }
}

+ (NSArray*)selectorsWithRegex:(NSRegularExpression*)regex forClass:(Class)class
{
  @autoreleasepool {
    NSArray* instanceMethods = [BILib _selectorsWithRegex:regex forClass:class];
    NSArray* classMethods = [BILib _selectorsWithRegex:regex forClass:object_getClass(class)];
    NSMutableArray* retSelectors = [NSMutableArray arrayWithArray:instanceMethods];
    [retSelectors addObjectsFromArray:classMethods];
    return retSelectors;
  }
}

+ (NSArray*)_selectorsWithRegex:(NSRegularExpression*)regex forClass:(Class)class
{
  NSMutableArray* retSelectors = [NSMutableArray array];
  unsigned int count;
  Method* methods = class_copyMethodList(class, &count);
  for (int i = 0; i < count; ++i) {
    SEL sel = method_getName(methods[i]);
    NSString* methodName = NSStringFromSelector(sel);
    NSTextCheckingResult* match = [regex firstMatchInString:methodName options:0 range:NSMakeRange(0, methodName.length)];
    if (0 < match.numberOfRanges) {
      [retSelectors addObject:[NSValue valueWithPointer:(void*)sel]];
    }
  }
  return retSelectors;
}

#pragma mark - Deprecated Methods

+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class preprocess:(id)preprocess
{
  return [BILib injectToSelector:sel forClass:class preprocess:preprocess postprocess:nil];
}

+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class postprocess:(id)postprocess
{
  return [BILib injectToSelector:sel forClass:class preprocess:nil postprocess:postprocess];
}

+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className preprocess:(id)preprocess
{
  Class class = objc_getClass([className UTF8String]);
  SEL sel = sel_getUid([methodName UTF8String]);
  return [BILib injectToSelector:sel forClass:class preprocess:preprocess];
}

+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className postprocess:(id)postprocess
{
  Class class = objc_getClass([className UTF8String]);
  SEL sel = sel_getUid([methodName UTF8String]);
  return [BILib injectToSelector:sel forClass:class postprocess:postprocess];
}

#pragma mark - Inline methods

inline NSRegularExpression* BIRegex(NSString* regexString)
{
  NSError* error = nil;
  return [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
}

@end
