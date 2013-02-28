//
//  BIItem.m
//
//  Created by ToKoRo on 2013-02-27.
//

#import "BIItem.h"

@implementation BIItem

- (id)init
{
  if ((self = [super init])) {
    self.preprocess = [NSMutableArray array];
    self.postprocess = [NSMutableArray array];
  }
  return self;
}

@end
