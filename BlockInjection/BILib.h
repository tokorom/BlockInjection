//
//  MILib.h
//
//  Created by ToKoRo on 2013-02-27.
//

#define MILIB [MILib sharedInstance]

@interface MILib : NSObject

+ (MILib*)sharedInstance;

- (BOOL)addPreprocessToSelector:(SEL)sel forClass:(Class)class block:(id)block;
- (BOOL)addPostprocessToSelector:(SEL)sel forClass:(Class)class block:(id)block;
- (BOOL)addPreprocess:(id)preprocess andPostprocess:(id)postprocess forSelector:(SEL)sel forClass:(Class)class;

@end
