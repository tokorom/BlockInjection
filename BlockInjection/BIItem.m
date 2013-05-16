//
//  BIItem.m
//
//  Created by ToKoRo on 2013-03-04.
//

#import "BIItem.h"
#import "BILibArg.h"
#import "BIItemManager.h"
#import "BILibUtils.h"

@interface BIItem ()
@property (strong) NSMutableArray* preprocesses;
@property (strong) NSMutableArray* postprocesses;
@property (weak) NSInvocation* invocation;
@property (assign) BOOL skip;
@property (assign) void* pResult;
@end 

@implementation BIItem

#pragma mark - Lifecycle

- (id)init
{
  if ((self = [super init])) {
    self.preprocesses = [NSMutableArray array];
    self.postprocesses = [NSMutableArray array];
  }
  return self;
}

- (void)dealloc
{
  if (self.pResult) {
    free(self.pResult);
    self.pResult = NULL;
  }
}

#pragma mark - Public Interface

- (NSString*)prettyFunction
{
  return [NSString stringWithFormat:@"%@%@[%@ %@]",
    [@"" stringByPaddingToLength:[[BIItemManager sharedInstance] indent] withString:@" " startingAtIndex:0],
    self.isClassMethod ? @"+" : @"-",
    NSStringFromClass(self.targetClass),
    NSStringFromSelector(self.targetSel)
  ];
}

- (void)prepareWithInvocation:(NSInvocation*)invocation
{
  self.skip = NO;
  if (self.pResult) {
    free(self.pResult);
    self.pResult = NULL;
  }
  self.invocation = invocation;
}

- (void)addPreprocessForSelector:(SEL)sel
{
  [self.preprocesses addObject:[NSValue valueWithPointer:sel]];
}

- (void)addPostprocessForSelector:(SEL)sel
{
  [self.postprocesses addObject:[NSValue valueWithPointer:sel]];
}

- (NSUInteger)numberOfPreprocess
{
  return self.preprocesses.count;
}

- (NSUInteger)numberOfPostprocess
{
  return self.postprocesses.count;
}

- (void*)invokeWithTarget:(id)target args:(va_list*)args
{
  if (![BILibUtils getMethodInClass:[target class] selector:self.originalSel]) {
    return NULL;
  }

  BOOL isSuperMethod = NO;
  if ([self isSuperClassMethodWithTarget:target]) {
    [self setupSuperClassMethodForTarget:target];
    isSuperMethod = YES;
  }

  BIItemManager* manager = [BIItemManager sharedInstance];

  NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:self.signature];
  [invocation setTarget:target];
  // Set arguments
  [BILibArg sendArgumentsToInvocation:invocation arguments:args numberOfArguments:self.numberOfArguments signature:self.signature];
  // Prepar the variable for return value 
  void* result = NULL;
  NSUInteger returnLength = [[invocation methodSignature] methodReturnLength];
  if (returnLength) {
    result = __builtin_alloca(returnLength);
  }
  // Preprocess
  [self prepareWithInvocation:invocation];
  [self invokePreprocessWithInvocation:invocation];
  ++manager.indent;

  if (!self.skip) {
    // Original
    if (isSuperMethod) {
      [invocation setSelector:self.superSel];
    } else {
      [invocation setSelector:self.originalSel];
    }
    [invocation invoke];
    // Get return value
    if (returnLength && result) {
      [invocation getReturnValue:result];
    }
    // Postprocess
    --manager.indent;
    [self invokePostprocessWithInvocation:invocation];
  }
  return self.pResult ?: result;
}

- (void)skipAfterProcessesWithReturnValue:(void*)pReturnValue
{
  self.skip = YES;
  NSUInteger returnLength = [[self.invocation methodSignature] methodReturnLength];
  if (pReturnValue && returnLength) {
    if (self.pResult) {
      free(self.pResult);
      self.pResult = NULL;
    }
    self.pResult = malloc(returnLength);
    if (self.pResult) {
      memcpy(self.pResult, pReturnValue, returnLength);
    }
  }
}

#pragma mark - Private Methods

- (void)invokePreprocessWithInvocation:(NSInvocation*)invocation
{
  [[BIItemManager sharedInstance] setCurrentItem:self];
  for (NSValue* value in self.preprocesses) {
    [invocation setSelector:[value pointerValue]];
    [invocation invoke];
    if (self.skip) {
      break;
    }
  }
}

- (void)invokePostprocessWithInvocation:(NSInvocation*)invocation
{
  [[BIItemManager sharedInstance] setCurrentItem:self];
  for (NSValue* value in self.postprocesses) {
    [invocation setSelector:[value pointerValue]];
    [invocation invoke];
    if (self.skip) {
      break;
    }
  }
}

- (BOOL)isSuperClassMethodWithTarget:(id)target
{
  NSString* itemClassName = NSStringFromClass(self.targetClass);
  NSString* targetClassName = NSStringFromClass([target class]);
  return ![itemClassName isEqualToString:targetClassName];
}

- (void)setupSuperClassMethodForTarget:(id)target
{
  self.superSel = sel_registerName([[BILibUtils superNameForMethodName:NSStringFromSelector(self.targetSel)] UTF8String]);
  Method superMethod = [BILibUtils getMethodInClass:self.targetClass selector:self.originalSel];
  [BILibUtils addMethodToClass:[target class]
                      selector:self.superSel
                           imp:method_getImplementation(superMethod)
                  typeEncoding:method_getTypeEncoding(superMethod)
                 isClassMethod:self.isClassMethod];
}

@end
