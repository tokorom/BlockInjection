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

+ (void)clear
{
  [[BIItemManager sharedInstance] clear];
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

  if (!savedMethod && originalMethod) {
    // Save original method
    [BILib addMethodToClass:class selector:saveSel imp:method_getImplementation(originalMethod) typeEncoding:method_getTypeEncoding(originalMethod) isClassMethod:isClassMethod];
  }

  // Replace implementation
  BIItem* item = [[BIItemManager sharedInstance] itemForMethodName:methodName forClass:class];
  if (!item) {
    item = [BIItem new];
    item.targetClass = class;
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

@end
