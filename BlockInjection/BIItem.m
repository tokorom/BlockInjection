//
//  BIItem.m
//
//  Created by ToKoRo on 2013-03-04.
//

#import "BIItem.h"
#import "BILibArg.h"

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
  if (self.pResult) free(self.pResult);
}

#pragma mark - Public Interface

- (NSString*)prettyFunction
{
  return [NSString stringWithFormat:@"%@[%@ %@]",
    self.isClassMethod ? @"+" : @"-",
    NSStringFromClass(self.targetClass),
    NSStringFromSelector(self.targetSel)
  ];
}

- (void)prepareWithInvocation:(NSInvocation*)invocation
{
  self.skip = NO;
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
  if (!self.skip) {
    // Original
    [invocation setSelector:self.originalSel];
    [invocation invoke];
    // Get return value
    NSUInteger returnLength = [[invocation methodSignature] methodReturnLength];
    if (returnLength && result) {
      [invocation getReturnValue:result];
    }
    // Postprocess
    [self invokePostprocessWithInvocation:invocation];
  }
  return self.pResult ?: result;
}

- (void)skipAfterProcessesWithReturnValue:(void*)pReturnValue
{
  self.skip = YES;
  NSUInteger returnLength = [[self.invocation methodSignature] methodReturnLength];
  if (pReturnValue && returnLength) {
    if (self.pResult) free(self.pResult);
    self.pResult = malloc(returnLength);
    memcpy(self.pResult, pReturnValue, returnLength);
  }
}

#pragma mark - Private Methods


- (void)invokePreprocessWithInvocation:(NSInvocation*)invocation
{
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
  for (NSValue* value in self.postprocesses) {
    [invocation setSelector:[value pointerValue]];
    [invocation invoke];
    if (self.skip) {
      break;
    }
  }
}

@end
