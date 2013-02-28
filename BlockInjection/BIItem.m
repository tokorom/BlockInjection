//
//  MIItem.m
//
//  Created by ToKoRo on 2013-02-27.
//

#import "MIItem.h"

@implementation MIItem

- (id)init
{
  if ((self = [super init])) {
    self.preprocess = [NSMutableArray array];
    self.postprocess = [NSMutableArray array];
  }
  return self;
}

@end
