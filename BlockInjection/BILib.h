//
//  BILib.h
//
//  Created by ToKoRo on 2013-02-27.
//

@interface BILib : NSObject

+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class preprocess:(id)preprocess;
+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class postprocess:(id)postprocess;
+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className preprocess:(id)preprocess;
+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className postprocess:(id)postprocess;

+ (void)clear;

@end
