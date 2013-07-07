//
//  SkippingTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 4/4/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "SkippingTest.h"
#import "BILib.h"

#import <objc/runtime.h>
#import "BIItem.h"
#import "BIItemManager.h"

#pragma mark - SubjectForSkipping

@interface SubjectForSkipping : NSObject
@end 

@implementation SubjectForSkipping

- (int)intValue
{
  return 100;
}

- (CGRect)rectValue
{
  return CGRectMake(10.0, 20.0, 30.0, 40.0);
}

- (char)charValue
{
  return 'a';
}

@end

#pragma mark - SkippingTest

@implementation SkippingTest

- (void)setUp
{
  [super setUp];
  [BILib clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testNormallyReturnValue
{
  [BILib injectToClassWithName:@"SubjectForSkipping" methodName:@"intValue" preprocess:^{
  }];

  int ret = [[SubjectForSkipping new] intValue];

  STAssertEquals(ret, 100, @"ret is invalid.");
}

- (void)testSkippingOriginalMethod
{
  [BILib injectToClassWithName:@"SubjectForSkipping" methodName:@"intValue" preprocess:^{
    int ret = 10;
    [BILib skipAfterProcessesWithReturnValue:&ret];
  }];

  int ret = [[SubjectForSkipping new] intValue];

  STAssertEquals(ret, 10, @"ret is invalid.");
}

- (void)testSkippingPostprocess
{
  [BILib injectToClassWithName:@"SubjectForSkipping" methodName:@"intValue" preprocess:^{
    int ret = 10;
    [BILib skipAfterProcessesWithReturnValue:&ret];
  }];

  __block int i = 0;
  [BILib injectToClassWithName:@"SubjectForSkipping" methodName:@"intValue" postprocess:^{
    i = 1;
  }];

  int ret = [[SubjectForSkipping new] intValue];

  STAssertEquals(ret, 10, @"ret is invalid.");
  STAssertEquals(i, 0, @"i is invalid.");
}

- (void)testOverrideReturnValueByPostprocess
{
  [BILib injectToClassWithName:@"SubjectForSkipping" methodName:@"intValue" postprocess:^{
    int ret = 99;
    [BILib skipAfterProcessesWithReturnValue:&ret];
  }];

  int ret = [[SubjectForSkipping new] intValue];

  STAssertEquals(ret, 99, @"ret is invalid.");
}

- (void)testReturnChar
{
  [BILib injectToClassWithName:@"SubjectForSkipping" methodName:@"charValue" preprocess:^{
    char c = 'c';
    [BILib skipAfterProcessesWithReturnValue:&c];
  }];

  char c = [[SubjectForSkipping new] charValue];

  STAssertEquals(c, (char)'c', @"c is invalid.");
}

@end
