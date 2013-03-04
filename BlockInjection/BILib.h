//
//  BILib.h
//
//  Created by ToKoRo on 2013-02-27.
//

@interface BILib : NSObject

+ (BOOL)injectToSelector:(SEL)sel forClass:(Class)class block:(id)block;
+ (BOOL)injectToSelectorWithMethodName:(NSString*)methodName forClassName:(NSString*)className block:(id)block;

+ (void*)performOriginalSelector:(SEL)sel target:(id)target, ... NS_REQUIRES_NIL_TERMINATION;
+ (void*)performOriginalSelectorWithMethodName:(NSString*)methodName target:(id)target, ... NS_REQUIRES_NIL_TERMINATION;

@end
