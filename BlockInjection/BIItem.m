//
//  BIItem.m
//
//  Created by ToKoRo on 2013-03-04.
//

#import "BIItem.h"

@interface BIItem ()
@property (strong) NSMutableArray* preprocesses;
@property (strong) NSMutableArray* postprocesses;
@end 

@implementation BIItem

- (id)init
{
  if ((self = [super init])) {
    self.preprocesses = [NSMutableArray array];
    self.postprocesses = [NSMutableArray array];
  }
  return self;
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

- (void)invokePreprocessWithInvocation:(NSInvocation*)invocation
{
  for (NSValue* value in self.preprocesses) {
    [invocation setSelector:[value pointerValue]];
    [invocation invoke];
  }
}

- (void)invokePostprocessWithInvocation:(NSInvocation*)invocation
{
  for (NSValue* value in self.postprocesses) {
    [invocation setSelector:[value pointerValue]];
    [invocation invoke];
  }
}

@end
