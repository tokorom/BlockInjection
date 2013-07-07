//
//  EtcTest.m
//  BlockInjectionTest
//
//  Created by ytokoro on 7/7/13.
//  Copyright (c) 2013 tokorom. All rights reserved.
//

#import "EtcTest.h"
#import "BILib.h"
#import "BIItemManager.h"
#import "BIItem.h"
#import <objc/runtime.h>
#import "BILibUtils.h"

typedef struct SuperBigStruct {
  char buff[1096];
  bool b;
} SuperBig;

@interface ClassForEtc : NSObject
@end

@implementation ClassForEtc
- (SuperBig)superBig {
  SuperBig bigStruct;
  bigStruct.b = false;
  return bigStruct;
}
- (int)intValue {
  return 0;
}
@end

@implementation EtcTest

- (void)setUp
{
  [super setUp];
  [BILib clear];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testCopyBIItemManager
{
  BIItemManager *manager1 = [BIItemManager sharedInstance];
  BIItemManager *manager2 = [manager1 copy];

  STAssertEqualObjects(manager1, manager2, @"manager1 and manager2 is different");
}

- (void)testReturnSuperBigStruct
{
  [BILib injectToClassWithName:@"ClassForEtc" methodName:@"superBig" preprocess:^SuperBig(id target){
    SuperBig st;
    st.b = true;
    return st;
  }];

  SuperBig ret = [[ClassForEtc new] superBig];

  STAssertEquals(ret.b, (bool)false, @"ret is invalid.");
}

- (void)testDeallocBIItem
{
  BIItem* item = [BIItem new];
  int i = 100;
  [item prepareWithInvocation:[self.class invocation]];
  [item skipAfterProcessesWithReturnValue:&i];

  STAssertNotNil(item, @"item is nil");
}

- (void)testBIItemOthers
{
  BIItem* item = [BIItem new];
  int i = 100;
  [item prepareWithInvocation:[self.class invocation]];
  [item skipAfterProcessesWithReturnValue:&i];
  int i2 = 200;
  [item skipAfterProcessesWithReturnValue:&i2];
  [item prepareWithInvocation:nil];

  STAssertNotNil(item, @"item is nil");
}

#pragma mark - Private Methods

+ (NSInvocation*)invocation
{
  BOOL isClassMethod = NO;
  Method method = [BILibUtils getMethodInClass:[ClassForEtc class] selector:@selector(intValue) isClassMethod:&isClassMethod];
  NSMethodSignature* signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
  NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
  return invocation;
}

@end
