//
//  BILibUtils.m
//
//  Created by ToKoRo on 2013-04-21.
//

#import "BILibUtils.h"

@implementation BILibUtils

#pragma mark - Public Interface

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

+ (NSString*)superNameForMethodName:(NSString*)methodName
{
  return [NSString stringWithFormat:@"__mi_super_%@", methodName];
}

+ (Method)getMethodInClass:(Class)class selector:(SEL)selector
{
  return [BILibUtils getMethodInClass:class selector:selector isClassMethod:NULL];
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
  Method method = [BILibUtils getMethodInClass:class selector:selector];
  if (method) {
    method_setImplementation(method, imp);
  } else {
    if (isClassMethod) {
      class = object_getClass(class);
    }
    class_addMethod(class, selector, imp, typeEncoding);
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
    NSArray* instanceMethods = [BILibUtils _selectorsWithRegex:regex forClass:class];
    NSArray* classMethods = [BILibUtils _selectorsWithRegex:regex forClass:object_getClass(class)];
    NSMutableArray* retSelectors = [NSMutableArray arrayWithArray:instanceMethods];
    [retSelectors addObjectsFromArray:classMethods];
    return retSelectors;
  }
}

#pragma mark - Private Methods

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

@end
