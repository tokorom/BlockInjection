//
//  BIItem.h
//
//  Created by ToKoRo on 2013-03-04.
//

@interface BIItem : NSObject

@property (assign) Class targetClass;
@property (assign) SEL targetSel;
@property (assign) SEL originalSel;
@property (assign) void* originalMethod;
@property (strong) NSMethodSignature* signature;
@property (assign) unsigned int numberOfArguments;
@property (assign) BOOL isClassMethod;

- (NSString*)prettyFunction;

- (void)addPreprocessForSelector:(SEL)sel;
- (void)addPostprocessForSelector:(SEL)sel;
- (NSUInteger)numberOfPreprocess;
- (NSUInteger)numberOfPostprocess;

- (void)invokePreprocessWithInvocation:(NSInvocation*)invocation;
- (void)invokePostprocessWithInvocation:(NSInvocation*)invocation;

@end
