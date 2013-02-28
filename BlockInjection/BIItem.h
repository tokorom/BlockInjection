//
//  MIItem.h
//
//  Created by ToKoRo on 2013-02-27.
//

@interface MIItem : NSObject
@property (copy) NSString* methodTypeEncoding;
//@property (assign) BOOL hasPreprocess;
//@property (assign) BOOL hasPostprocess;
@property (strong) NSMutableArray* preprocess;
@property (strong) NSMutableArray* postprocess;
@end
