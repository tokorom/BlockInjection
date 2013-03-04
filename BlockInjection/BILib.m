//
//  BILib.m
//
//  Created by ToKoRo on 2013-02-27.
//

#import "BILib.h"
#import <objc/runtime.h>

@implementation BILib

#pragma mark - Public Interface
  
+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class block:(id)block
{
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  Method originalMethod = class_getInstanceMethod(class, sel);

  if (originalMethod) {
    // Save original method
    IMP originalImp = method_getImplementation(originalMethod);
    SEL saveSel = sel_registerName([[BILib saveNameForMethodName:methodName] UTF8String]);
    class_addMethod(class, saveSel, originalImp, method_getTypeEncoding(originalMethod));
  }

  // Replace implementation
  method_setImplementation(originalMethod, imp_implementationWithBlock(block));

  return YES;
}

+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className block:(id)block
{
  Class class = objc_getClass([className UTF8String]);
  SEL sel = sel_getUid([methodName UTF8String]);
  return [BILib injectToSelector:sel forClass:class block:block];
}

+ (void*)performOriginalSelector:(SEL)sel target:(id)target, ...
{
  va_list argp;
  va_start(argp, target);
  void* retp = [BILib performOriginalSelector:sel target:target argp:argp];
  va_end(argp);
  return retp;
}

+ (void*)performOriginalSelectorWithMethodName:(NSString*)methodName target:(id)target, ...
{
  va_list argp;
  va_start(argp, target);
  SEL sel = sel_getUid([methodName UTF8String]);
  void* retp = [BILib performOriginalSelector:sel target:target argp:argp];
  va_end(argp);
  return retp;
}

+ (void*)performOriginalSelector:(SEL)sel target:(id)target argp:(va_list)argp
{
  void* retp = NULL;
  NSString* methodName = [NSString stringWithUTF8String:sel_getName(sel)];
  SEL originalSel = sel_registerName([[BILib saveNameForMethodName:methodName] UTF8String]);
  Method method = class_getInstanceMethod([target class], sel);

  void* pval = (__bridge void*)(id)target;

  NSMethodSignature* signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
  if (signature) {
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:originalSel];

    int index = 2;
    while (pval) {
      pval = va_arg(argp, void*);
      if (pval) {
        [invocation setArgument:(void*)pval atIndex:index++];
      }
    }

    [invocation invoke];

    NSUInteger returnLength = [[invocation methodSignature] methodReturnLength];
    if (returnLength) {
      void* result = __builtin_alloca(returnLength);
      [invocation getReturnValue:result];
      retp = result;
    }
  } else {
    NSLog(@"%s is not found.", sel_getName(originalSel));
  }
  va_end(argp);
  return retp ? *(void**)retp : NULL;
}

#pragma mark - Private Methods

+ (NSString*)saveNameForMethodName:(NSString*)methodName
{
  return [NSString stringWithFormat:@"__mi_save_%@", methodName];
}

@end
