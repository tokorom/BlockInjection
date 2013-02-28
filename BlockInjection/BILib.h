//
//  BILib.h
//
//  Created by ToKoRo on 2013-02-27.
//

#define BILIB [BILib sharedInstance]

@interface BILib : NSObject

+ (BILib*)sharedInstance;

- (BOOL)insertPreprocessToSelector:(SEL)sel forClass:(Class)class block:(id)block;
- (BOOL)insertPostprocessToSelector:(SEL)sel forClass:(Class)class block:(id)block;
- (BOOL)insertPreprocess:(id)preprocess andPostprocess:(id)postprocess forSelector:(SEL)sel forClass:(Class)class;

- (BOOL)insertPreprocessToMethodName:(NSString*)methodName forClassName:(NSString*)className block:(id)block;
- (BOOL)insertPostprocessToMethodName:(NSString*)methodName forClassName:(NSString*)className block:(id)block;

- (void)clear;

@end
