//
//  BlockInjectionTestTests.m
//
//  Created by ToKoRo on 2013-02-28.
//

#import "BlockInjectionTestTests.h"
#import "BILib.h"

#pragma mark - Bizz

@interface Bizz : NSObject
@property (copy) NSString* backup;
- (void)sayMessage:(NSString*)message;
@end 

@implementation Bizz
- (void)sayMessage:(NSString*)message
{
  NSLog(@"Bizz says: %@", message);
}
@end 

#pragma mark - Buzz

@interface Buzz : NSObject
- (void)sayMessage:(NSString*)message;
@end 

@implementation Buzz
- (void)sayMessage:(NSString*)message
{
  NSLog(@"Buzz says: %@", message);
}
@end 

#pragma mark - TestCase

@implementation BlockInjectionTestTests

- (void)setUp
{
  [super setUp];
  self.preCount = 0;
  self.postCount = 0;
  [BILIB clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testInsertPreprocess
{
  [BILIB insertPreprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^{
    ++self.preCount;
  }];

  STAssertEquals(self.preCount, 0, @"preCount is invalid.");
  STAssertEquals(self.postCount, 0, @"postCount is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(self.preCount, 1, @"preCount is invalid.");
  STAssertEquals(self.postCount, 0, @"postCount is invalid.");
}

- (void)testInsertPostprocess
{
  [BILIB insertPostprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^{
    ++self.postCount;
  }];

  STAssertEquals(self.preCount, 0, @"preCount is invalid.");
  STAssertEquals(self.postCount, 0, @"postCount is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(self.preCount, 0, @"preCount is invalid.");
  STAssertEquals(self.postCount, 1, @"postCount is invalid.");
}

- (void)testInsertPostprocessAndPostprocess
{
  [BILIB insertPreprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^{
    ++self.preCount;
  }];
  [BILIB insertPostprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^{
    ++self.postCount;
  }];

  STAssertEquals(self.preCount, 0, @"preCount is invalid.");
  STAssertEquals(self.postCount, 0, @"postCount is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(self.preCount, 1, @"preCount is invalid.");
  STAssertEquals(self.postCount, 1, @"postCount is invalid.");
}

- (void)testCallTwice
{
  [BILIB insertPreprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^{
    ++self.preCount;
  }];
  [BILIB insertPostprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^{
    ++self.postCount;
  }];

  STAssertEquals(self.preCount, 0, @"preCount is invalid.");
  STAssertEquals(self.postCount, 0, @"postCount is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(self.preCount, 1, @"preCount is invalid.");
  STAssertEquals(self.postCount, 1, @"postCount is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(self.preCount, 2, @"preCount is invalid.");
  STAssertEquals(self.postCount, 2, @"postCount is invalid.");
}

- (void)testHandleProperty
{
  __block NSString* b = nil;
  [BILIB insertPreprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^(Bizz* bizz){
    b = bizz.backup;
  }];

  Bizz* bizz = [Bizz new];
  bizz.backup = @"Yah!";

  STAssertNil(b, @"b is invalid: %@", b);

  [bizz sayMessage:@"hello!"];

  STAssertTrue([b isEqualToString:@"Yah!"], 0, @"b is invalid: %@", b);
}

- (void)testHandleArg
{
  __block NSString* b = nil;
  [BILIB insertPreprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^(Bizz* bizz, NSString* message){
    b = message;
  }];

  Bizz* bizz = [Bizz new];

  STAssertNil(b, @"b is invalid: %@", b);

  [bizz sayMessage:@"hello!"];

  STAssertTrue([b isEqualToString:@"hello!"], 0, @"b is invalid: %@", b);
}

- (void)testOtherClass
{
  __block NSString* b1 = nil;
  [BILIB insertPreprocessToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^(id target, NSString* message){
    b1 = message;
  }];
  __block NSString* b2 = nil;
  [BILIB insertPreprocessToSelector:@selector(sayMessage:) forClass:[Buzz class] block:^(id target, NSString* message){
    b2 = message;
  }];

  STAssertNil(b1, @"b1 is invalid: %@", b1);
  STAssertNil(b2, @"b2 is invalid: %@", b2);

  [[Bizz new] sayMessage:@"bizz"];

  STAssertTrue([b1 isEqualToString:@"bizz"], 0, @"b1 is invalid: %@", b1);
  STAssertNil(b2, @"b2 is invalid: %@", b2);

  [[Buzz new] sayMessage:@"buzz"];

  STAssertTrue([b1 isEqualToString:@"bizz"], 0, @"b1 is invalid: %@", b1);
  STAssertTrue([b2 isEqualToString:@"buzz"], 0, @"b2 is invalid: %@", b2);
}

- (void)testInsertPreprocessWithString
{
  [BILIB insertPreprocessToMethodName:@"sayMessage:" forClassName:@"Bizz" block:^{
    ++self.preCount;
  }];

  STAssertEquals(self.preCount, 0, @"preCount is invalid.");
  STAssertEquals(self.postCount, 0, @"postCount is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(self.preCount, 1, @"preCount is invalid.");
  STAssertEquals(self.postCount, 0, @"postCount is invalid.");
}

- (void)testInsertPostprocessWithString
{
  [BILIB insertPostprocessToMethodName:@"sayMessage:" forClassName:@"Bizz" block:^{
    ++self.postCount;
  }];

  STAssertEquals(self.preCount, 0, @"preCount is invalid.");
  STAssertEquals(self.postCount, 0, @"postCount is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(self.preCount, 0, @"preCount is invalid.");
  STAssertEquals(self.postCount, 1, @"postCount is invalid.");
}

@end
