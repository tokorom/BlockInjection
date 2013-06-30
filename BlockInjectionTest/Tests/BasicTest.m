//
//  BasicTest.m
//
//  Created by ToKoRo on 2013-02-28.
//

#import "BasicTest.h"
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

#pragma mark - struct 17

typedef struct bilib_test_17 {
  char c;
  long l1;
  long l2;
  long l3;
  long l4;
} bilib_test_17;

#pragma mark - struct 17

typedef struct bilib_test_1024 {
  char buff[1024];
  char c;
} bilib_test_1024;

#pragma mark - Buzz

@interface Buzz : NSObject
- (void)sendInt1:(int)int1 int2:(int)int2 long1:(long)long1;
- (void)sendChar:(char)c d:(double)d;
- (void)sendStruct17:(bilib_test_17)st1 st2:(bilib_test_17)st2;
- (void)sendStruct1024:(bilib_test_1024)st1024;
@end 

@implementation Buzz
- (void)sendInt1:(int)int1 int2:(int)int2 long1:(long)long1
{
  NSLog(@"%d %d %ld", int1, int2, long1);
}
- (void)sendChar:(char)c d:(double)d
{
  NSLog(@"%c %f", c, d);
}
- (void)sendStruct17:(bilib_test_17)st1 st2:(bilib_test_17)st2
{
}
- (void)sendStruct1024:(bilib_test_1024)st1024
{
}
@end 

#pragma mark - BizzChild

@interface BizzChild : Bizz
- (void)sayMessage:(NSString*)message tag:(int)tag;
@end 

@implementation BizzChild
- (void)sayMessage:(NSString*)message tag:(int)tag
{
  NSLog(@"BizzChild says: %@ %d", message, tag);
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

@implementation BasicTest

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
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testPostprocess
{
  __block int i = 0;
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) postprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testCallTwice
{
  __block int i = 0;
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^{
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
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^(Bizz* bizz){
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
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^(Bizz* bizz, NSString* message){
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
  [BILib injectToClass:[Buzz class] selector:@selector(sendInt1:int2:long1:) preprocess:^(Buzz* buzz, int int1, int int2, long long1){
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
  [BILib injectToClassWithName:@"Bizz" methodName:@"sayMessage:" preprocess:^{
    ++i;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 1, @"i is invalid.");
}

- (void)testInjectTwice
{
  __block int i = 0;
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^(Bizz* bizz, NSString* message){
    i += 100;
  }];
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^(Bizz* bizz, NSString* message){
    i += 200;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 300, @"i is invalid.");
}

- (void)testInjectTriple
{
  __block int i = 0;
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^(Bizz* bizz, NSString* message){
    i += 100;
  }];
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^(Bizz* bizz, NSString* message){
    i += 200;
  }];
  [BILib injectToClass:[Bizz class] selector:@selector(sayMessage:) preprocess:^(Bizz* bizz, NSString* message){
    i += 300;
  }];

  STAssertEquals(i, 0, @"i is invalid.");

  [[Bizz new] sayMessage:@"hello!"];

  STAssertEquals(i, 600, @"i is invalid.");
}

- (void)testSubclass
{
  [BILib injectToClass:[BizzChild class] selector:@selector(sayMessage:tag:) preprocess:^(BizzChild* child, NSString* message, int tag){
    ++child.count;
  }];

  BizzChild* child = [BizzChild new];

  STAssertEquals(child.count, 0, @"count is invalid.");

  [child sayMessage:@"hello!" tag:5];

  STAssertEquals(child.count, 2, @"count is invalid.");
}

- (void)testUIView
{
  [BILib injectToClass:[UIView class] selector:@selector(setFrame:) preprocess:^(UIView* view, CGRect frame){
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
  [BILib injectToClass:[UIViewController class]
              selector:@selector(presentViewController:animated:completion:)
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
  [BILib injectToClass:[Bizz class] selector:@selector(count) preprocess:^(Bizz* bizz){
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
  [BILib injectToClass:[Bizz class] selector:@selector(backup) preprocess:^(Bizz* bizz){
    NSLog(@"preprocess");
  }];

  Bizz* bizz = [Bizz new];

  bizz.backup = @"xxx";

  STAssertTrue([bizz.backup isEqualToString:@"xxx"], @"bizz.backup is invalid: %@", bizz.backup);
}

- (void)testForReadme
{
  __block int i = 0;
  [BILib injectToClass:[ViewController class] selector:@selector(buttonDidPush:) preprocess:^{

    //[tracker sendEventWithCategory:@"uiAction"
                        //withAction:@"buttonDidPush"
                         //withLabel:nil
                         //withValue:0];

    ++i;
  }];

  [[ViewController new] buttonDidPush:nil];

  STAssertEquals(i, 1, @"i is invalid.");

  [BILib injectToClassWithName:@"ViewController" methodName:@"buttonDidPush:" preprocess:^{

    //[tracker sendEventWithCategory:@"uiAction"
                        //withAction:@"buttonDidPush"
                         //withLabel:nil
                         //withValue:0];

    i = 10;
  }];

  [[ViewController new] buttonDidPush:nil];

  STAssertEquals(i, 10, @"i is invalid.");
}

- (void)testNilArgument
{
  __block NSString* str = nil;
  __block int i = 0;
  [BILib injectToClass:[BizzChild class] selector:@selector(sayMessage:tag:) preprocess:^(BizzChild* child, NSString* message, int tag){
    str = message;
    i = tag;
  }];

  BizzChild* child = [BizzChild new];

  STAssertEquals(i, 0, @"i is invalid.");

  [child sayMessage:nil tag:999];

  STAssertNil(str, @"str is not nil.");
  STAssertEquals(i, 999, @"i is invalid.");
}

- (void)testLongLongArgument
{
  __block char bc;
  __block double bd;
  [BILib injectToClass:[Buzz class] selector:@selector(sendChar:d:) preprocess:^(Buzz* buzz, char c, double d){
    bc = c;
    bd = d;
  }];

  [[Buzz new] sendChar:'k' d:0.33333];

  STAssertEquals(bc, (char)'k', @"bc is invalid.");
  STAssertEquals(bd, (double)0.33333, @"bd is invalid.");
}

- (void)testStructArgument
{
  __block CGFloat height = 0.0;
  [BILib injectToClass:[UIView class] selector:@selector(setFrame:) preprocess:^(UIView* view, CGRect frame){
    NSLog(@"%@ setFarme:(%f, %f, %f, %f)", NSStringFromClass(view.class), frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    height = frame.size.height;
  }];

  UIView* view = [UIView new];

  STAssertEquals(height, (CGFloat)0.0, @"height is invalid.");

  [view setFrame:CGRectMake(10, 0, 20, 50)];

  STAssertEquals(height, (CGFloat)50.0, @"height is invalid.");
}

- (void)testStruct17Argument
{
  __block long l14 = 0;
  __block long l24 = 0;
  [BILib injectToClass:[Buzz class] selector:@selector(sendStruct17:st2:) preprocess:^(id target, bilib_test_17 st1, bilib_test_17 st2){
    NSLog(@"st1:(%c, %ld, %ld, %ld, %ld)", st1.c, st1.l1, st1.l2, st1.l3, st1.l4);
    NSLog(@"st2:(%c, %ld, %ld, %ld, %ld)", st2.c, st2.l1, st2.l2, st2.l3, st2.l4);
    l14 = st1.l4;
    l24 = st2.l4;
  }];

  STAssertEquals(l14, (long)0, @"l14 is invalid.");
  STAssertEquals(l24, (long)0, @"l24 is invalid.");

  bilib_test_17 st1;
  st1.c = 'c';
  st1.l1 = 1;
  st1.l2 = 2;
  st1.l3 = 3;
  st1.l4 = 256;
  bilib_test_17 st2;
  st2.c = '0';
  st2.l1 = 11;
  st2.l2 = 12;
  st2.l3 = 13;
  st2.l4 = 1256;
  [[Buzz new] sendStruct17:st1 st2:st2];

  STAssertEquals(l14, (long)256, @"l14 is invalid.");
  STAssertEquals(l24, (long)1256, @"l24 is invalid.");
}

- (void)testStruct1024Argument
{
  __block char c = 0;
  [BILib injectToClass:[Buzz class] selector:@selector(sendStruct1024:) preprocess:^(id target, bilib_test_1024 st1024){
    c = st1024.c;
  }];

  STAssertEquals(c, (char)0, @"c is invalid.");

  bilib_test_1024 st1024;
  st1024.c = 'x';
  [[Buzz new] sendStruct1024:st1024];

  STAssertEquals(c, (char)'x', @"c is invalid.");
}

@end
