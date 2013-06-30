//
//  ReturnValueTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 4/7/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "ReturnValueTest.h"
#import "BILib.h"

static int ia[2] = {1, 2};

struct ReturnValueBigStruct {
  char buff[500];
  CGFloat f;
  char buff2[500];
};

#pragma mark - ClassForReturnValue

@interface ClassForReturnValue : NSObject
@end

@implementation ClassForReturnValue
- (const int)ci {
  return 100;
}
- (const char*)constChars {
  return "ci";
}
- (double)doubleValue {
  return 99.99;
}
- (bool)boolValue {
  return true;
}
- (char)charValue {
  return 'c';
}
- (int*)arrayValue {
  return ia;
}
- (Class)classValue {
  return NSClassFromString(@"UIView");
}
- (SEL)selValue {
  return @selector(tag);
}
- (struct ReturnValueBigStruct)bigStructValue {
  struct ReturnValueBigStruct bigStruct;
  bigStruct.f = 0.255;
  return bigStruct;
}
@end

#pragma mark - Private Methods

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

- (void)testReturnConstInt
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"ci" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
  }];

  const int ret = [[ClassForReturnValue new] ci];

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(ret, (const int)100, @"ret is invalid.");
}

- (void)testReturnConstChars
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"constChars" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
  }];

  const char* ret = [[ClassForReturnValue new] constChars];

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(ret[0], (char)'c', @"ret is invalid.");
  STAssertEquals(ret[1], (char)'i', @"ret is invalid.");
}

- (void)testReturnDouble
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"doubleValue" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
  }];

  double ret = [[ClassForReturnValue new] doubleValue];

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(ret, (double)99.99, @"ret is invalid.");
}

- (void)testReturnCppBool
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"boolValue" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
  }];

  bool ret = [[ClassForReturnValue new] boolValue];

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(ret, (bool)true, @"ret is invalid.");
}

- (void)testReturnChar
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"charValue" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
  }];

  char ret = [[ClassForReturnValue new] charValue];

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(ret, (char)'c', @"ret is invalid.");
}

- (void)testReturnArray
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"arrayValue" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
  }];

  int* ret = [[ClassForReturnValue new] arrayValue];

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(ret[0], (int)1, @"ret is invalid.");
  STAssertEquals(ret[1], (int)2, @"ret is invalid.");
}

- (void)testReturnClass
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"classValue" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
  }];

  Class ret = [[ClassForReturnValue new] classValue];

  STAssertTrue(success, @"success is invalid.");
  STAssertTrue([@"UIView" isEqualToString:NSStringFromClass(ret)], @"ret is invalid.");
}

- (void)testReturnSelector
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"selValue" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
  }];

  SEL ret = [[ClassForReturnValue new] selValue];

  STAssertTrue(success, @"success is invalid.");
  STAssertTrue([@"tag" isEqualToString:NSStringFromSelector(ret)], @"ret is invalid.");
}

- (void)testReturnCGRect
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"UIView" methodName:@"frame" preprocess:^(UIView* view){
    if ([view isKindOfClass:[UIView class]]) {
      success = YES;
    }
    return CGRectMake(0,0,0,0);
  }];

  UIView* view = [UIView new];
  view.frame = CGRectMake(1.0, 2.0, 3.0, 4.0);

  CGRect frame = view.frame;

  STAssertTrue(success, @"success is invalid.");

  STAssertEquals(frame.origin.x, (CGFloat)1.0, @"x is invalid.");
  STAssertEquals(frame.origin.y, (CGFloat)2.0, @"y is invalid.");
  STAssertEquals(frame.size.width, (CGFloat)3.0, @"w is invalid.");
  STAssertEquals(frame.size.height, (CGFloat)4.0, @"h is invalid.");
}

- (void)testReturnCGPoint
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"UIView" methodName:@"center" preprocess:^(UIView* view){
    if ([view isKindOfClass:[UIView class]]) {
      success = YES;
    }
    return CGPointMake(0,0);
  }];

  UIView* view = [UIView new];
  view.center = CGPointMake(1.0, 2.0);

  CGPoint center = view.center;

  STAssertTrue(success, @"success is invalid.");

  STAssertEquals(center.x, (CGFloat)1.0, @"x is invalid.");
  STAssertEquals(center.y, (CGFloat)2.0, @"y is invalid.");
}

- (void)testReturnBigStruct
{
  __block BOOL success = NO;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"bigStructValue" preprocess:^(id target){
    if ([target isKindOfClass:[ClassForReturnValue class]]) {
      success = YES;
    }
    struct ReturnValueBigStruct st;
    return st;
  }];

  struct ReturnValueBigStruct ret = [[ClassForReturnValue new] bigStructValue];

  STAssertTrue(success, @"success is invalid.");
  STAssertEquals(ret.f, (CGFloat)0.255, @"ret is invalid.");
}

@end
