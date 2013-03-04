//
//  BILib.m
//
//  Created by ToKoRo on 2013-02-27.
//

#import "BILib.h"
#import "BIItem.h"
#import "BIItemManager.h"
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
  Method originalMethod = class_getInstanceMethod(class, sel);
  Method savedMethod = class_getInstanceMethod(class, saveSel);

  if (!savedMethod && originalMethod) {
    // Save original method
    IMP originalImp = method_getImplementation(originalMethod);
    class_addMethod(class, saveSel, originalImp, method_getTypeEncoding(originalMethod));
  }

  // Replace implementation
  BIItem* item = [[BIItemManager sharedInstance] itemForMethodName:methodName forClass:class];
  if (!item) {
    item = [BIItem new];
    item.originalSel = saveSel;
    item.numberOfArguments = method_getNumberOfArguments(originalMethod) - 2;
    item.signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(originalMethod)];
    [[BIItemManager sharedInstance] setItem:item forMethodName:methodName forClass:class];
  }
  if (preprocess) {
    // Save preprocess
    SEL preprocessSel = sel_registerName([[BILib preprocessNameForMethodName:methodName index:[item numberOfPreprocess]] UTF8String]);
    Method preMethod = class_getInstanceMethod(class, preprocessSel);
    if (preMethod) {
      method_setImplementation(preMethod, imp_implementationWithBlock(preprocess));
    } else {
      class_addMethod(class, preprocessSel, imp_implementationWithBlock(preprocess), method_getTypeEncoding(originalMethod));
    }
    [item addPreprocessForSelector:preprocessSel];
  }
  if (postprocess) {
    // Save postprocess
    SEL postprocessSel = sel_registerName([[BILib postprocessNameForMethodName:methodName index:[item numberOfPostprocess]] UTF8String]);
    Method postMethod = class_getInstanceMethod(class, postprocessSel);
    if (postMethod) {
      method_setImplementation(postMethod, imp_implementationWithBlock(postprocess));
    } else {
      class_addMethod(class, postprocessSel, imp_implementationWithBlock(postprocess), method_getTypeEncoding(originalMethod));
    }
    [item addPostprocessForSelector:postprocessSel];
  }
  if (item.signature) {
    id replaceBlock = ^(id target, ...){
      void* retp = NULL;
      NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:item.signature];
      [invocation setTarget:target];
      va_list argp;
      va_start(argp, target);
      void* pval = (__bridge void*)(id)target;
      int index = 2;
      unsigned int argumentsCount = item.numberOfArguments;
      while (argumentsCount--) {
        NSUInteger size;
        NSGetSizeAndAlignment([item.signature getArgumentTypeAtIndex:index], &size, NULL);
        if (8 == size) {
          double dval = va_arg(argp, double);
          [invocation setArgument:&dval atIndex:index++];
        } else {
          pval = va_arg(argp, void*);
          [invocation setArgument:&pval atIndex:index++];
        }
      }
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
    method_setImplementation(originalMethod, imp_implementationWithBlock(replaceBlock));
  }

  return YES;
}

@end
