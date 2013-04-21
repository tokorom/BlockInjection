//
//  BILibUtils.h
//
//  Created by ToKoRo on 2013-04-21.
//

#import <objc/runtime.h>

@interface BILibUtils : NSObject

+ (NSString*)saveNameForMethodName:(NSString*)methodName;
+ (NSString*)preprocessNameForMethodName:(NSString*)methodName index:(int)index;
+ (NSString*)postprocessNameForMethodName:(NSString*)methodName index:(int)index;
+ (NSString*)superNameForMethodName:(NSString*)methodName;

+ (Method)getMethodInClass:(Class)class selector:(SEL)selector;
+ (Method)getMethodInClass:(Class)class selector:(SEL)selector isClassMethod:(BOOL*)isClassMethod;
+ (void)addMethodToClass:(Class)class selector:(SEL)selector imp:(IMP)imp typeEncoding:(const char*)typeEncoding isClassMethod:(BOOL)isClassMethod;
+ (NSArray*)classesWithRegex:(NSRegularExpression*)regex;
+ (NSArray*)selectorsWithRegex:(NSRegularExpression*)regex forClass:(Class)class;

@end
