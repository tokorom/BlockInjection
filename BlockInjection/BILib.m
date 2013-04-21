//
//  BILib.m
//
//  Created by ToKoRo on 2013-02-27.
//

#import "BILib.h"
#import "BIItem.h"
#import "BIItemManager.h"
#import <objc/runtime.h>
#import "BILibDummyStruct.h"
#import "BILibExclusives.h"
#import "BILibUtils.h"

#define REPLACEBLOCK_FOR_VOID \
  ^(id target, ...){ \
    [[BIItemManager sharedInstance] setCurrentItem:item]; \
    va_list argp; \
    va_start(argp, target); \
    [item invokeWithTarget:target args:&argp]; \
    va_end(argp); \
  }

#define REPLACEBLOCK_FOR(type) \
  ^type(id target, ...){ \
    [[BIItemManager sharedInstance] setCurrentItem:item]; \
    va_list argp; \
    va_start(argp, target); \
    void* retp = [item invokeWithTarget:target args:&argp]; \
    va_end(argp); \
    return *(type*)retp; \
  }

#define REPLACE_BLOCK_FOR_STRUCT_CASE(cas) case cas: return REPLACEBLOCK_FOR(BILibStruct##cas)

#define EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf) \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 0); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 1); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 2); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 3); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 4); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 5); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 6); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 7); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 8); \
  REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 9)

#define EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf) \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 0); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 1); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 2); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 3); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 4); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 5); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 6); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 7); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 8); \
  EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(prf ## 9)

#pragma mark - BILib

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
  NSArray* matchClasses = [BILibUtils classesWithRegex:classNameRegex];
  for (NSValue* classValue in matchClasses) {
    Class class = [classValue pointerValue];
    NSArray* matchSelectors = [BILibUtils selectorsWithRegex:methodNameRegex forClass:class];
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
  NSArray* matchClasses = [BILibUtils classesWithRegex:classNameRegex];
  for (NSValue* classValue in matchClasses) {
    Class class = [classValue pointerValue];
    NSArray* matchSelectors = [BILibUtils selectorsWithRegex:methodNameRegex forClass:class];
    for (NSValue* selValue in matchSelectors) {
      SEL sel = [selValue pointerValue];
      failed |= ![BILib injectToClass:class selector:sel postprocess:postprocess];
    }
  }
  return !failed;
}

+ (void)skipAfterProcessesWithReturnValue:(void*)pReturnValue
{
  BIItem* item = [[BIItemManager sharedInstance] currentItem];
  [item skipAfterProcessesWithReturnValue:pReturnValue];
}

+ (BOOL)replaceImplementationForClass:(Class)class selector:(SEL)sel block:(id)block
{
  Method method = [BILibUtils getMethodInClass:class selector:sel];
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

+ (void)clear
{
  [[BIItemManager sharedInstance] clear];
}

#pragma mark - Private Methods

+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class preprocess:(id)preprocess postprocess:(id)postprocess
{
  @try {
    NSString* methodName = NSStringFromSelector(sel);
    SEL saveSel = sel_registerName([[BILibUtils saveNameForMethodName:methodName] UTF8String]);
    BOOL isClassMethod = NO;
    Method originalMethod = [BILibUtils getMethodInClass:class selector:sel isClassMethod:&isClassMethod];
    Method savedMethod = [BILibUtils getMethodInClass:class selector:saveSel];

    if (!savedMethod) {
      // Save original method
      [BILibUtils addMethodToClass:class selector:saveSel imp:method_getImplementation(originalMethod) typeEncoding:method_getTypeEncoding(originalMethod) isClassMethod:isClassMethod];
    }

    if (!originalMethod) {
      NSLog(@"BILib: [%@ %@] is not found.", NSStringFromClass(class), methodName);
      return NO;
    }
    
    if ([methodName hasPrefix:@"__mi_"]) {
      return NO;
    }
    if ([BILib inIgnoreListWithClassName:NSStringFromClass(class) methodName:methodName]) {
      NSLog(@"BILib: [%@ %@] is not supported.", NSStringFromClass(class), methodName);
      return NO;
    }

    @try {
      [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(originalMethod)];
    } @catch (NSException* exception) {
      @throw exception;
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
  } @catch (NSException* exception) {
    NSLog(@"BILib handled a exception: %@", exception);
    return NO;
  }

  return YES;
}

+ (BOOL)inIgnoreListWithClassName:(NSString*)className methodName:(NSString*)methodName
{
  if ([kBILibExclusiveMethods containsObject:methodName]) {
    return YES;
  }
  return NO;
}

+ (void)savePreprocess:(id)preprocess andPostprocess:(id)postprocess withItem:(BIItem*)item forMethodName:(NSString*)methodName
{
  if (preprocess) {
    // Save preprocess
    SEL preprocessSel = sel_registerName([[BILibUtils preprocessNameForMethodName:methodName index:[item numberOfPreprocess]] UTF8String]);
    [BILibUtils addMethodToClass:item.targetClass
                        selector:preprocessSel
                             imp:imp_implementationWithBlock(preprocess)
                    typeEncoding:method_getTypeEncoding(item.originalMethod)
                   isClassMethod:item.isClassMethod];
    [item addPreprocessForSelector:preprocessSel];
  }
  if (postprocess) {
    // Save postprocess
    SEL postprocessSel = sel_registerName([[BILibUtils postprocessNameForMethodName:methodName index:[item numberOfPostprocess]] UTF8String]);
    [BILibUtils addMethodToClass:item.targetClass
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
    id replaceBlock;
    NSUInteger returnLength = [item.signature methodReturnLength];
    const char* returnType = [item.signature methodReturnType];
    if (NULL == returnType || 0 == strlen(returnType)) {
      replaceBlock = REPLACEBLOCK_FOR_VOID;
    } else {
      char prefix = returnType[0];
      char type = returnType[strlen(returnType) - 1];
      if ('^' == prefix || '{' == prefix) {
        type = prefix;
      }
      switch (type) {
        case 'v': { replaceBlock = REPLACEBLOCK_FOR_VOID; } break;
        case 'c': { replaceBlock = REPLACEBLOCK_FOR(char); } break;
        case 'i': { replaceBlock = REPLACEBLOCK_FOR(int); } break;
        case 's': { replaceBlock = REPLACEBLOCK_FOR(short); } break;
        case 'l': { replaceBlock = REPLACEBLOCK_FOR(long); } break;
        case 'q': { replaceBlock = REPLACEBLOCK_FOR(long long); } break;
        case 'C': { replaceBlock = REPLACEBLOCK_FOR(unsigned char); } break;
        case 'I': { replaceBlock = REPLACEBLOCK_FOR(unsigned int); } break;
        case 'S': { replaceBlock = REPLACEBLOCK_FOR(unsigned short); } break;
        case 'L': { replaceBlock = REPLACEBLOCK_FOR(unsigned long); } break;
        case 'Q': { replaceBlock = REPLACEBLOCK_FOR(unsigned long long); } break;
        case 'f': { replaceBlock = REPLACEBLOCK_FOR(float); } break;
        case 'd': { replaceBlock = REPLACEBLOCK_FOR(double); } break;
        case 'B': { replaceBlock = REPLACEBLOCK_FOR(bool); } break;
        case '*': { replaceBlock = REPLACEBLOCK_FOR(int*); } break;
        case '@': { replaceBlock = REPLACEBLOCK_FOR(int*); } break;
        case '#': { replaceBlock = REPLACEBLOCK_FOR(int*); } break;
        case ':': { replaceBlock = REPLACEBLOCK_FOR(int*); } break;
        case '{': { replaceBlock = [BILib replaceBlockForStructWithSize:returnLength withItem:item]; } break;
        case '^': { replaceBlock = REPLACEBLOCK_FOR(int*); } break;
        default: { replaceBlock = REPLACEBLOCK_FOR(int); } break;
      }
    }
    method_setImplementation(item.originalMethod, imp_implementationWithBlock(replaceBlock));
  }
}

+ (id)replaceBlockForStructWithSize:(NSUInteger)size withItem:(BIItem*)item
{
  switch (size) {
    REPLACE_BLOCK_FOR_STRUCT_CASE(1);
    REPLACE_BLOCK_FOR_STRUCT_CASE(2);
    REPLACE_BLOCK_FOR_STRUCT_CASE(3);
    REPLACE_BLOCK_FOR_STRUCT_CASE(4);
    REPLACE_BLOCK_FOR_STRUCT_CASE(5);
    REPLACE_BLOCK_FOR_STRUCT_CASE(6);
    REPLACE_BLOCK_FOR_STRUCT_CASE(7);
    REPLACE_BLOCK_FOR_STRUCT_CASE(8);
    REPLACE_BLOCK_FOR_STRUCT_CASE(9);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(1);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(2);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(3);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(4);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(5);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(6);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(7);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(8);
    EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(9);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(1);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(2);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(3);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(4);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(5);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(6);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(7);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(8);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(9);
    EXPAND_EXPAND_REPLACE_BLOCK_FOR_STRUCT_CASE(10);
    default: return REPLACEBLOCK_FOR(int);
  }
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
