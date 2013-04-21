//
//  BILib.h
//
//  Created by ToKoRo on 2013-02-27.
//

#pragma mark - BILib

@interface BILib : NSObject

+ (NSString*)prettyFunction;

+ (BOOL)injectToClass:(Class)class selector:(SEL)sel preprocess:(id)preprocess;
+ (BOOL)injectToClass:(Class)class selector:(SEL)sel postprocess:(id)postprocess;
+ (BOOL)injectToClassWithName:(NSString*)className methodName:(NSString*)methodName preprocess:(id)preprocess;
+ (BOOL)injectToClassWithName:(NSString*)className methodName:(NSString*)methodName postprocess:(id)postprocess;

+ (BOOL)injectToClassWithNames:(NSArray*)classNames methodNames:(NSArray*)methodNames preprocess:(id)preprocess;
+ (BOOL)injectToClassWithNames:(NSArray*)classNames methodNames:(NSArray*)methodNames postprocess:(id)postprocess;

+ (BOOL)injectToClassWithNameRegex:(NSRegularExpression*)classNameRegex methodNameRegex:(NSRegularExpression*)methodNameRegex preprocess:(id)preprocess;
+ (BOOL)injectToClassWithNameRegex:(NSRegularExpression*)classNameRegex methodNameRegex:(NSRegularExpression*)methodNameRegex postprocess:(id)postprocess;

+ (void)skipAfterProcessesWithReturnValue:(void*)pReturnValue;

+ (BOOL)replaceImplementationForClass:(Class)class selector:(SEL)sel block:(id)block;
+ (BOOL)replaceImplementationForClassName:(NSString*)className methodName:(NSString*)methodName block:(id)block;

+ (void)clear;

/**
 * Deprecated
 */
+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class preprocess:(id)preprocess __deprecated;
+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class postprocess:(id)postprocess __deprecated;
+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className preprocess:(id)preprocess __deprecated;
+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className postprocess:(id)postprocess __deprecated;

@end

#pragma mark - Inline methods

NSRegularExpression* BIRegex(NSString* regexString);
