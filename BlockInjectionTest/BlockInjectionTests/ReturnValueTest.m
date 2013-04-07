//
//  ReturnValueTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 4/7/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "ReturnValueTest.h"
#import "BILib.h"

@implementation ReturnValueTest

- (void)setUp
{
  [super setUp];
  [BILib clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testReturnBool
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"UIView" methodName:@"isHidden" preprocess:^(UIView* view){
    if ([view isKindOfClass:[UIView class]]) {
      success = YES;
    } 
  }];

  UIView* view = [UIView new];
  view.hidden = YES;

  BOOL isHidden = view.isHidden;

  STAssertTrue(success, @"success is invalid.");
  STAssertTrue(isHidden, @"isHidden is invalid.");
}

- (void)testReturnInt
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"UIView" methodName:@"tag" preprocess:^(UIView* view){
    if ([view isKindOfClass:[UIView class]]) {
      success = YES;
    }
  }];

  UIView* view = [UIView new];
  view.tag = 5;

  int tag = view.tag;

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(tag, (int)5, @"tag is invalid.");
}

- (void)testReturnId
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"UIView" methodName:@"backgroundColor" preprocess:^(UIView* view){
    if ([view isKindOfClass:[UIView class]]) {
      success = YES;
    }
  }];

  UIView* view = [UIView new];
  view.backgroundColor = [UIColor redColor];

  UIColor* color = view.backgroundColor;

  STAssertTrue(success, @"success is invalid.");

  CGFloat r1, r2, g1, g2, b1, b2, a1, a2;
  [color getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
  [[UIColor redColor] getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

  STAssertEquals(r1, r2, @"r is invalid.");
  STAssertEquals(g1, g2, @"g is invalid.");
  STAssertEquals(b1, b2, @"b is invalid.");
  STAssertEquals(a1, a2, @"a is invalid.");
}

- (void)testReturnCGFloat
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"UIView" methodName:@"alpha" preprocess:^(UIView* view){
    if ([view isKindOfClass:[UIView class]]) {
      success = YES;
    }
  }];

  UIView* view = [UIView new];
  view.alpha = 0.8;

  CGFloat alpha = view.alpha;

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(alpha, (CGFloat)0.8, @"alpha is invalid.");
}

@end
