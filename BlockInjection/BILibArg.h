//
//  BILibArg.h
//
//  Created by ToKoRo on 2013-03-06.
//

@interface BILibArg : NSObject

+ (void)sendArgumentsToInvocation:(NSInvocation*)invocation
                        arguments:(va_list*)pargp
                numberOfArguments:(NSUInteger)numberOfArguments
                        signature:(NSMethodSignature*)signature;

@end
