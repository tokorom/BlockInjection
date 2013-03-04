# BlockInjection

BlockInjection is a helpful library for iOS and Mac OS X.

You can insert some Blocks before and after the method by this library.

## Samples

For example, if you use Google Analytics,
you can embed the code for tracking without polluting your original source code.

``` objective-c
#import "BILib.h"

[BILib injectToSelector:@selector(buttonDidPush:) forClass:[ViewController class] preprocess:^{

  // This code is called just before buttnDidPush:
  [tracker sendEventWithCategory:@"uiAction"
                      withAction:@"buttonDidPush"
                       withLabel:nil
                       withValue:0];

}];
```

You can use NSString instead of Selector and Class.

``` objective-c
#import "BILib.h"

[BILib injectToSelectorWithMethodName:@"buttonDidPush:" forClassName:@"ViewController" preprocess:^{

  // This code is called just before buttnDidPush:
  [tracker sendEventWithCategory:@"uiAction"
                      withAction:@"buttonDidPush"
                       withLabel:nil
                       withValue:0];

}];
```

You can insert a Postprocess.

``` objective-c
#import "BILib.h"

[BILib injectToSelector:@selector(buttonDidPush:) forClass:[ViewController class] postprocess:^{

  // This code is called just after buttnDidPush:
  [tracker sendEventWithCategory:@"uiAction"
                      withAction:@"buttonDidPush"
                       withLabel:nil
                       withValue:0];

}];
```

You can use a instance method's argument in your block.

``` objective-c
#import "BILib.h"

// Sample class

@interface Bizz : NSObject
- (void)sayMessage:(NSString*)message;
@end 

@implementation Bizz
- (void)sayMessage:(NSString*)message
{
  NSLog(@"Bizz says: %@", message);
}
@end 

// ...

[BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] preprocess:^(Bizz* bizz, NSString* message){

  // This code is called just before buttnDidPush:
  [tracker sendEventWithCategory:@"Bizz"
                      withAction:@"sayMessage"
                       withLabel:message //< You can use the argument that is passed to sayMessage:
                       withValue:0];

}];

// ...
```

