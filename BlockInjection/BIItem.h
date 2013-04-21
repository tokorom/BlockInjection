//
//  BIItem.h
//
//  Created by ToKoRo on 2013-03-04.
//

@interface BIItem : NSObject

@property (assign) Class targetClass;
@property (assign) SEL targetSel;
@property (assign) SEL originalSel;
@property (assign) SEL superSel;
@property (assign) void* originalMethod;
@property (strong) NSMethodSignature* signature;
@property (assign) unsigned int numberOfArguments;
@property (assign) BOOL isClassMethod;

- (NSString*)prettyFunction;

- (void)prepareWithInvocation:(NSInvocation*)invocation;

- (void)addPreprocessForSelector:(SEL)sel;
- (void)addPostprocessForSelector:(SEL)sel;
- (NSUInteger)numberOfPreprocess;
- (NSUInteger)numberOfPostprocess;

- (void*)invokeWithTarget:(id)target args:(va_list*)args;

- (void)skipAfterProcessesWithReturnValue:(void*)pReturnValue;

@end
