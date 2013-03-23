//
//  BILib.h
//
//  Created by ToKoRo on 2013-02-27.
//

@interface BILib : NSObject

+ (BOOL)injectToClass:(Class)class selector:(SEL)sel preprocess:(id)preprocess;
+ (BOOL)injectToClass:(Class)class selector:(SEL)sel postprocess:(id)postprocess;
+ (BOOL)injectToClassWithName:(NSString*)className methodName:(NSString*)methodName preprocess:(id)preprocess;
+ (BOOL)injectToClassWithName:(NSString*)className methodName:(NSString*)methodName postprocess:(id)postprocess;

+ (void)clear;

+ (BOOL)replaceImplementationForClass:(Class)class selector:(SEL)sel block:(id)block;
+ (BOOL)replaceImplementationForClassName:(NSString*)className methodName:(NSString*)methodName block:(id)block;

+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class preprocess:(id)preprocess __deprecated;
+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class postprocess:(id)postprocess __deprecated;
+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className preprocess:(id)preprocess __deprecated;
+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className postprocess:(id)postprocess __deprecated;

@end
