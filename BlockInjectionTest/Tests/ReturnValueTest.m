//
//  ReturnValueTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 4/7/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "ReturnValueTest.h"
#import "BILib.h"
#import "BILibDummyStruct.h"

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
- (BILibStruct1)struct1 { BILibStruct1 st; return st; }
- (BILibStruct2)struct2 { BILibStruct2 st; return st; }
- (BILibStruct3)struct3 { BILibStruct3 st; return st; }
- (BILibStruct4)struct4 { BILibStruct4 st; return st; }
- (BILibStruct5)struct5 { BILibStruct5 st; return st; }
- (BILibStruct6)struct6 { BILibStruct6 st; return st; }
- (BILibStruct7)struct7 { BILibStruct7 st; return st; }
- (BILibStruct8)struct8 { BILibStruct8 st; return st; }
- (BILibStruct9)struct9 { BILibStruct9 st; return st; }
- (BILibStruct10)struct10 { BILibStruct10 st; return st; }
- (BILibStruct20)struct20 { BILibStruct20 st; return st; }
- (BILibStruct30)struct30 { BILibStruct30 st; return st; }
- (BILibStruct40)struct40 { BILibStruct40 st; return st; }
- (BILibStruct50)struct50 { BILibStruct50 st; return st; }
- (BILibStruct60)struct60 { BILibStruct60 st; return st; }
- (BILibStruct70)struct70 { BILibStruct70 st; return st; }
- (BILibStruct80)struct80 { BILibStruct80 st; return st; }
- (BILibStruct90)struct90 { BILibStruct90 st; return st; }
- (BILibStruct100)struct100 { BILibStruct100 st; return st; }
- (BILibStruct200)struct200 { BILibStruct200 st; return st; }
- (BILibStruct300)struct300 { BILibStruct300 st; return st; }
- (BILibStruct400)struct400 { BILibStruct400 st; return st; }
- (BILibStruct500)struct500 { BILibStruct500 st; return st; }
- (BILibStruct600)struct600 { BILibStruct600 st; return st; }
- (BILibStruct700)struct700 { BILibStruct700 st; return st; }
- (BILibStruct800)struct800 { BILibStruct800 st; return st; }
- (BILibStruct900)struct900 { BILibStruct900 st; return st; }
@end

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

- (void)testReturnSomeStruct
{
  __block int count = 0;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct1" preprocess:^BILibStruct1(id target){
    ++count; BILibStruct1 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct2" preprocess:^BILibStruct2(id target){
    ++count; BILibStruct2 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct3" preprocess:^BILibStruct3(id target){
    ++count; BILibStruct3 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct4" preprocess:^BILibStruct4(id target){
    ++count; BILibStruct4 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct5" preprocess:^BILibStruct5(id target){
    ++count; BILibStruct5 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct6" preprocess:^BILibStruct6(id target){
    ++count; BILibStruct6 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct7" preprocess:^BILibStruct7(id target){
    ++count; BILibStruct7 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct8" preprocess:^BILibStruct8(id target){
    ++count; BILibStruct8 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct9" preprocess:^BILibStruct9(id target){
    ++count; BILibStruct9 st; return st;
  }];

  STAssertEquals(count, (int)0, @"count is invalid.");

  ClassForReturnValue* c = [ClassForReturnValue new];
  [c struct1];
  [c struct2];
  [c struct3];
  [c struct4];
  [c struct5];
  [c struct6];
  [c struct7];
  [c struct8];
  [c struct9];

  STAssertEquals(count, (int)9, @"count is invalid.");
}

- (void)testReturnSomeStruct10
{
  __block int count = 0;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct10" preprocess:^BILibStruct10(id target){
    ++count; BILibStruct10 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct20" preprocess:^BILibStruct20(id target){
    ++count; BILibStruct20 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct30" preprocess:^BILibStruct30(id target){
    ++count; BILibStruct30 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct40" preprocess:^BILibStruct40(id target){
    ++count; BILibStruct40 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct50" preprocess:^BILibStruct50(id target){
    ++count; BILibStruct50 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct60" preprocess:^BILibStruct60(id target){
    ++count; BILibStruct60 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct70" preprocess:^BILibStruct70(id target){
    ++count; BILibStruct70 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct80" preprocess:^BILibStruct80(id target){
    ++count; BILibStruct80 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct90" preprocess:^BILibStruct90(id target){
    ++count; BILibStruct90 st; return st;
  }];

  STAssertEquals(count, (int)0, @"count is invalid.");

  ClassForReturnValue* c = [ClassForReturnValue new];
  [c struct10];
  [c struct20];
  [c struct30];
  [c struct40];
  [c struct50];
  [c struct60];
  [c struct70];
  [c struct80];
  [c struct90];

  STAssertEquals(count, (int)9, @"count is invalid.");
}

- (void)testReturnSomeStruct100
{
  __block int count = 0;
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct100" preprocess:^BILibStruct100(id target){
    ++count; BILibStruct100 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct200" preprocess:^BILibStruct200(id target){
    ++count; BILibStruct200 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct300" preprocess:^BILibStruct300(id target){
    ++count; BILibStruct300 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct400" preprocess:^BILibStruct400(id target){
    ++count; BILibStruct400 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct500" preprocess:^BILibStruct500(id target){
    ++count; BILibStruct500 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct600" preprocess:^BILibStruct600(id target){
    ++count; BILibStruct600 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct700" preprocess:^BILibStruct700(id target){
    ++count; BILibStruct700 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct800" preprocess:^BILibStruct800(id target){
    ++count; BILibStruct800 st; return st;
  }];
  [BILib injectToClassWithName:@"ClassForReturnValue" methodName:@"struct900" preprocess:^BILibStruct900(id target){
    ++count; BILibStruct900 st; return st;
  }];

  STAssertEquals(count, (int)0, @"count is invalid.");

  ClassForReturnValue* c = [ClassForReturnValue new];
  [c struct100];
  [c struct200];
  [c struct300];
  [c struct400];
  [c struct500];
  [c struct600];
  [c struct700];
  [c struct800];
  [c struct900];

  STAssertEquals(count, (int)9, @"count is invalid.");
}

@end
