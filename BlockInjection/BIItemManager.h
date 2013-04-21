//
//  BIItemManager.h
//
//  Created by ToKoRo on 2013-03-04.
//

@class BIItem;

@interface BIItemManager : NSObject

@property (weak) BIItem* currentItem;
@property (assign) int indent;

+ (BIItemManager*)sharedInstance;

- (BIItem*)itemForMethodName:(NSString*)methodName forClass:(Class)class;
- (void)setItem:(BIItem*)item forMethodName:(NSString*)methodName forClass:(Class)class;

- (void)clear;

@end
