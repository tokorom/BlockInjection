//
//  ClassMethodTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 3/23/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "ClassMethodTest.h"
#import "BILib.h"

#pragma mark - SubjectForClass

@interface SubjectForClass : NSObject
+ (void)classMethod:(id)arg;
@end 

@implementation SubjectForClass

+ (void)classMethod:(id)arg
{
  NSLog(@"classMethod: %@", arg);
}

@end

#pragma mark - ClassMethodTest

@implementation ClassMethodTest

- (void)setUp
{
  [super setUp];
  [BILib clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testInjectToClassMethod
{
  __block int i = 0;
  [BILib injectToClass:[SubjectForClass class] selector:@selector(classMethod:) preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [SubjectForClass classMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

@end
