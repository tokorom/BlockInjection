//
//  InheritanceTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 4/20/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "InheritanceTest.h"
#import "BILib.h"

#pragma mark - Parent

@interface Parent : NSObject
@end 

@implementation Parent

- (void)instanceMethod:(id)arg
{
  NSLog(@"Parent instanceMethod: %@", arg);
}

@end

#pragma mark - Child

@interface Child : Parent
@end 

@implementation Child

- (void)instanceMethod:(id)arg
{
  NSLog(@"Child instanceMethod: %@", arg);
  [super instanceMethod:arg];
}

@end

#pragma mark - InheritanceTest

@implementation InheritanceTest

- (void)setUp
{
  [super setUp];
  [BILib clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testSuperClassMethod
{
  __block int i = 0;
  [BILib injectToClassWithNames:@[@"Child"] methodNames:@[@"instanceMethod:"] preprocess:^{
    ++i;
  }];
  [BILib injectToClassWithNames:@[@"Parent"] methodNames:@[@"instanceMethod:"] preprocess:^{
    i+=2;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Parent new] instanceMethod:@"hello!"];

  STAssertEquals(i, 2, @"i is invalid.");

  [[Child new] instanceMethod:@"hello!"];

  STAssertEquals(i, 5, @"i is invalid.");
}

@end
