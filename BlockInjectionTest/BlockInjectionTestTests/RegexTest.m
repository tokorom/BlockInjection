//
//  RegexTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 3/24/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "RegexTest.h"
#import "BILib.h"

#pragma mark - SubjectForRegex

@interface SubjectForRegex : NSObject
@end 

@implementation SubjectForRegex

- (void)instanceMethod:(id)arg
{
  NSLog(@"instanceMethod: %@", arg);
}

- (void)instanceMethod2
{
  NSLog(@"instanceMethod2");
}

@end

#pragma mark - SubjectForRegex2

@interface SubjectForRegex2 : NSObject
@end 

@implementation SubjectForRegex2

- (void)instanceMethod:(id)arg
{
  NSLog(@"instanceMethod: %@", arg);
}

@end

#pragma mark - RegexTest

@implementation RegexTest

- (void)setUp
{
  [super setUp];
  [BILib clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testAnyMethodsWithPreprocess
{
  __block int i = 0;
  [BILib injectToClassWithNames:@[@"SubjectForRegex"] methodNames:@[@"instanceMethod:", @"instanceMethod2"] preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod2];

  STAssertEquals(i, 2, @"i is invalid.");
}

- (void)testAnyMethodsWithPostprocess
{
  __block int i = 0;
  [BILib injectToClassWithNames:@[@"SubjectForRegex"] methodNames:@[@"instanceMethod:", @"instanceMethod2"] postprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod2];

  STAssertEquals(i, 2, @"i is invalid.");
}

- (void)testAnyClassesAndAnyMethodsWithPreprocess
{
  __block int i = 0;
  [BILib injectToClassWithNames:@[@"SubjectForRegex", @"SubjectForRegex2"] methodNames:@[@"instanceMethod:", @"instanceMethod2"] preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForRegex2 new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod:@"hello!"];

  STAssertEquals(i, 2, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod2];

  STAssertEquals(i, 3, @"i is invalid.");
}

- (void)testAnyClassesAndAnyMethodsWithPostprocess
{
  __block int i = 0;
  [BILib injectToClassWithNames:@[@"SubjectForRegex", @"SubjectForRegex2"] methodNames:@[@"instanceMethod:", @"instanceMethod2"] postprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForRegex2 new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod:@"hello!"];

  STAssertEquals(i, 2, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod2];

  STAssertEquals(i, 3, @"i is invalid.");
}

- (void)testHandlePrettyFunction
{
  __block NSString* handlePrettyFunction = @"";
  [BILib injectToClassWithNames:@[@"SubjectForRegex", @"SubjectForRegex2"] methodNames:@[@"instanceMethod:", @"instanceMethod2"] preprocess:^{
    handlePrettyFunction = [BILib prettyFunction];
  }];

  [[SubjectForRegex2 new] instanceMethod:@"hello!"];

  STAssertTrue([handlePrettyFunction isEqualToString:@"-[SubjectForRegex2 instanceMethod:]"], @"handlePrettyFunction is invalid: %@", handlePrettyFunction);

  [[SubjectForRegex new] instanceMethod:@"hello!"];

  STAssertTrue([handlePrettyFunction isEqualToString:@"-[SubjectForRegex instanceMethod:]"], @"handlePrettyFunction is invalid: %@", handlePrettyFunction);

  [[SubjectForRegex new] instanceMethod2];

  STAssertTrue([handlePrettyFunction isEqualToString:@"-[SubjectForRegex instanceMethod2]"], @"handlePrettyFunction is invalid: %@", handlePrettyFunction);
}

- (void)testRegexWithPreprocess
{
  NSError* error = nil;
  NSRegularExpression* classNameRegex = [NSRegularExpression regularExpressionWithPattern:@"^SubjectForRegex$" options:0 error:&error];
  NSRegularExpression* methodNameRegex = [NSRegularExpression regularExpressionWithPattern:@"^instance.*" options:0 error:&error];

  __block int i = 0;
  [BILib injectToClassWithNameRegex:classNameRegex methodNameRegex:methodNameRegex preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod2];

  STAssertEquals(i, 2, @"i is invalid.");
}

- (void)testRegexWithPostprocess
{
  NSError* error = nil;
  NSRegularExpression* classNameRegex = [NSRegularExpression regularExpressionWithPattern:@"^SubjectForRegex.*" options:0 error:&error];
  NSRegularExpression* methodNameRegex = [NSRegularExpression regularExpressionWithPattern:@"^instance.*" options:0 error:&error];

  __block int i = 0;
  [BILib injectToClassWithNameRegex:classNameRegex methodNameRegex:methodNameRegex postprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod2];

  STAssertEquals(i, 2, @"i is invalid.");

  [[SubjectForRegex2 new] instanceMethod:@"hello!"];

  STAssertEquals(i, 3, @"i is invalid.");
}

- (void)testRegexWithUIView
{
  NSError* error = nil;
  NSRegularExpression* classNameRegex = [NSRegularExpression regularExpressionWithPattern:@"UIView" options:0 error:&error];
  NSRegularExpression* methodNameRegex = [NSRegularExpression regularExpressionWithPattern:@"^set.*" options:0 error:&error];

  [BILib injectToClassWithNameRegex:classNameRegex methodNameRegex:methodNameRegex postprocess:^{
    NSLog(@"%@", [BILib prettyFunction]);
  }];

  UIView* view = [UIView new];
  view.frame = CGRectMake(0.0, 0.0, 10.0, 5.0);

  STAssertEquals(1, 1, nil);
}

- (void)testRegexWithMacro
{
  __block int i = 0;
  [BILib injectToClassWithNameRegex:BIRegex(@"^SubjectForRegex$") methodNameRegex:BIRegex(@"^instance.*") preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");

  [[SubjectForRegex new] instanceMethod2];

  STAssertEquals(i, 2, @"i is invalid.");
}

@end
