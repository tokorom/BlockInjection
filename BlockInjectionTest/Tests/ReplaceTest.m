//
//  ReplaceTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 3/23/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "ReplaceTest.h"
#import "BILib.h"

#pragma mark - SubjectForReplace

@interface SubjectForDummy : NSObject
- (void)instanceMethod2:(id)arg;
@end 

@interface SubjectForReplace : NSObject
- (void)instanceMethod:(id)arg;
+ (void)classMethod:(id)arg;
@end 

@implementation SubjectForReplace

- (void)instanceMethod:(id)arg
{
  NSLog(@"instanceMethod: %@", arg);
}

+ (void)classMethod:(id)arg
{
  NSLog(@"classMethod: %@", arg);
}

@end

#pragma mark - ReplaceTest

@implementation ReplaceTest

- (void)setUp
{
  [super setUp];
  [BILib clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testReplaceImplementation
{
  __block int i = 0;
  [BILib replaceImplementationForClass:[SubjectForReplace class] selector:@selector(instanceMethod:) block:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForReplace new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testReplaceImplementationForNoMethods
{
  __block int i = 0;
  [BILib replaceImplementationForClass:[SubjectForReplace class] selector:@selector(instanceMethod2:) block:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForReplace new] instanceMethod:@"hello!"];

  STAssertEquals(i, 0, @"i is invalid.");
}

- (void)testReplaceImplementationWithArg
{
  __block NSString* got = nil;
  [BILib replaceImplementationForClass:[SubjectForReplace class] selector:@selector(instanceMethod:) block:^(id target, id arg){
    got = arg;
  }];

  STAssertNil(got, @"got is invalid.");

  [[SubjectForReplace new] instanceMethod:@"got!"];

  STAssertTrue([got isEqualToString:@"got!"], @"got is invalid: %@", got);
}

- (void)testReplaceWithName
{
  __block int i = 0;
  [BILib replaceImplementationForClassName:@"SubjectForReplace" methodName:@"instanceMethod:" block:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForReplace new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testReplaceClassMethod
{
  __block int i = 0;
  [BILib replaceImplementationForClass:[SubjectForReplace class] selector:@selector(classMethod:) block:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [SubjectForReplace classMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testReplaceAndInject
{
  __block NSString* got = nil;
  [BILib replaceImplementationForClass:[SubjectForReplace class] selector:@selector(instanceMethod:) block:^(id target, id arg){
    got = arg;
  }];

  __block int i = 0;
  [BILib injectToClass:[SubjectForReplace class] selector:@selector(instanceMethod:) preprocess:^{
    ++i;
  }];

  STAssertNil(got, @"got is invalid.");
  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForReplace new] instanceMethod:@"got!"];

  STAssertTrue([got isEqualToString:@"got!"], @"got is invalid: %@", got);
  STAssertEquals(i, 1, @"i is invalid.");
}
@end
