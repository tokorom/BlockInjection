//
//  BlockInjectionTestTests.m
//
//  Created by ToKoRo on 2013-02-28.
//

#import "BlockInjectionTestTests.h"
#import "BILib.h"

#pragma mark - Bizz

@interface Bizz : NSObject
@property (assign) int count;
@property (copy) NSString* backup;
- (void)sayMessage:(NSString*)message;
@end 

@implementation Bizz
- (void)sayMessage:(NSString*)message
{
  ++self.count;
  NSLog(@"Bizz says: %@", message);
}
@end 

#pragma mark - Buzz

@interface Buzz : NSObject
- (void)sendInt1:(int)int1 int2:(int)int2 long1:(long)long1;
@end 

@implementation Buzz
- (void)sendInt1:(int)int1 int2:(int)int2 long1:(long)long1
{
  NSLog(@"%d %d %ld", int1, int2, long1);
}
@end 

#pragma mark - Child

@interface Child : Bizz
- (void)sayMessage:(NSString*)message tag:(int)tag;
@end 

@implementation Child
- (void)sayMessage:(NSString*)message tag:(int)tag
{
  NSLog(@"Child says: %@ %d", message, tag);
  [super sayMessage:message];
}
@end 

#pragma mark - ViewController

@interface ViewController : NSObject
- (void)buttonDidPush:(id)sender;
@end 

@implementation ViewController
- (void)buttonDidPush:(id)sender
{
  NSLog(@"buttonDidPush:");
}
@end 

#pragma mark - TestCase

@implementation BlockInjectionTestTests

- (void)setUp
{
  [super setUp];
  [BILib clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testInject
{
  __block int i = 0;
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testPostprocess
{
  __block int i = 0;
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] postprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testCallTwice
{
  __block int i = 0;
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];
  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 2, @"i is invalid.");
}

- (void)testHandleProperty
{
  __block NSString* b = nil;
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^(Bizz* bizz){
    b = bizz.backup;
  }];

  STAssertNil(b, @"b is invalid.");

  Bizz* bizz = [Bizz new];
  bizz.backup = @"backup";
  [bizz sayMessage:@"hello!"];

  STAssertTrue([b isEqualToString:@"backup"], @"b is invalid: %@", b);
}

- (void)testHandleArg
{
  __block NSString* b = nil;
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^(Bizz* bizz, NSString* message){
    b = message;
  }];

  STAssertNil(b, @"b is invalid.");

  Bizz* bizz = [Bizz new];
  [bizz sayMessage:@"hello!"];

  STAssertTrue([b isEqualToString:@"hello!"], @"b is invalid: %@", b);
}

- (void)testPremitiveArgs
{
  __block int x, y;
  __block long l;
  [BILib injectToSelector:@selector(sendInt1:int2:long1:) forClass:[Buzz class] preprocess:^(Buzz* buzz, int int1, int int2, long long1){
    x = int1;
    y = int2;
    l = long1;
  }];

  [[Buzz new] sendInt1:1 int2:2 long1:0xFFFFFFFF];

  STAssertEquals(x, 1, @"x is invalid.");
  STAssertEquals(y, 2, @"y is invalid.");
  STAssertEquals(l, (long)0xFFFFFFFF, @"l is invalid.");
}

- (void)testInjectWithString
{
  __block int i = 0;
  [BILib injectToSelectorWithMethodName:@"sayMessage:" forClassName:@"Bizz" preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testInjectTwice
{
  __block int i = 0;
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^(Bizz* bizz, NSString* message){
    i += 100;
  }];
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^(Bizz* bizz, NSString* message){
    i += 200;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 300, @"i is invalid.");
}

- (void)testInjectTriple
{
  __block int i = 0;
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^(Bizz* bizz, NSString* message){
    i += 100;
  }];
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^(Bizz* bizz, NSString* message){
    i += 200;
  }];
  [BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^(Bizz* bizz, NSString* message){
    i += 300;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 600, @"i is invalid.");
}

- (void)testSubclass
{
  [BILib injectToSelector:@selector(sayMessage:tag:) forClass:[Child class] preprocess:^(Child* child, NSString* message, int tag){
    ++child.count;
  }];

  Child* child = [Child new];

  STAssertEquals(child.count, 0, @"count is invalid.");

  [child sayMessage:@"hello!" tag:5];

  STAssertEquals(child.count, 2, @"count is invalid.");
}

- (void)testUIView
{
  [BILib injectToSelector:@selector(setFrame:) forClass:[UIView class] preprocess:^(UIView* view, CGRect frame){
    view.tag += 100;
  }];

  UIView* view = [UIView new];

  STAssertEquals(view.tag, 100, @"tag is invalid.");

  [view setFrame:CGRectMake(0, 0, 20, 20)];

  STAssertEquals(view.tag, 200, @"tag is invalid.");
}

- (void)testUIViewController
{
  __block BOOL bflag = NO;
  [BILib injectToSelector:@selector(presentViewController:animated:completion:)
                 forClass:[UIViewController class]
                    preprocess:^(id target, UIViewController* vc, BOOL flag, id completion)
  {
    NSLog(@"presentViewController:%@ animated:%d completion:%@", vc, flag, completion);

    bflag = flag;
  }];

  UIViewController* viewController = [UIViewController new];

  STAssertEquals(bflag, NO, @"blag is invalid.");

  [viewController presentViewController:[UIViewController new] animated:YES completion:NULL];

  STAssertEquals(bflag, YES, @"blag is invalid.");
}

- (void)testReturnValue
{
  [BILib injectToSelector:@selector(count) forClass:[Bizz class] preprocess:^(Bizz* bizz){
    NSLog(@"preprocess");
  }];

  Bizz* bizz = [Bizz new];

  STAssertEquals(bizz.count, 0, @"i is invalid.");

  bizz.count = 100;
  int ret = bizz.count;

  STAssertEquals(ret, 100, @"ret is invalid.");
}

- (void)testReturnValueForObject
{
  [BILib injectToSelector:@selector(backup) forClass:[Bizz class] preprocess:^(Bizz* bizz){
    NSLog(@"preprocess");
  }];

  Bizz* bizz = [Bizz new];

  bizz.backup = @"xxx";

  STAssertTrue([bizz.backup isEqualToString:@"xxx"], @"bizz.backup is invalid: %@", bizz.backup);
}

- (void)testForReadme
{
  __block int i = 0;
  [BILib injectToSelector:@selector(buttonDidPush:) forClass:[ViewController class] preprocess:^{

    //[tracker sendEventWithCategory:@"uiAction"
                        //withAction:@"buttonDidPush"
                         //withLabel:nil
                         //withValue:0];

    ++i;
  }];

  [[ViewController new] buttonDidPush:nil];

  STAssertEquals(i, 1, @"i is invalid.");

  [BILib injectToSelectorWithMethodName:@"buttonDidPush:" forClassName:@"ViewController" preprocess:^{

    //[tracker sendEventWithCategory:@"uiAction"
                        //withAction:@"buttonDidPush"
                         //withLabel:nil
                         //withValue:0];

    i = 10;
  }];

  [[ViewController new] buttonDidPush:nil];

  STAssertEquals(i, 10, @"i is invalid.");
}

@end
