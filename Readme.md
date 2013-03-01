# BlockInjection

BlockInjection is a helpful library for iOS and Mac OS X.

You can insert some Blocks before and after the method by this library.

## Samples

For example, if you use Google Analytics,
you can embed the code for tracking without polluting your original source code.

``` objective-c
#import "BILib.h"

[BILib injectToSelector:@selector(buttonDidPush:) forClass:[ViewController class] block:^(id target, id sender){

  // You can call some methods before original method
  [tracker sendEventWithCategory:@"uiAction"
                      withAction:@"buttonDidPush"
                       withLabel:nil
                       withValue:0];

  // You must call original method by performOriginalSelector:target:...
  [BILib performOriginalSelector:@selector(buttonDidPush:) target:target, &sender, nil];
}];
```

You can use NSString instead of Selector and Class.

``` objective-c
#import "BILib.h"

[BILib injectToSelectorWithMethodName:@"buttonDidPush:" forClassName:@"ViewController" block:^(id target, id sender){

  [tracker sendEventWithCategory:@"uiAction"
                      withAction:@"buttonDidPush"
                       withLabel:nil
                       withValue:0];

  [BILib performOriginalSelectorWithMethodName:@"buttonDidPush:" target:target, &sender, nil];
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

[BILib injectToSelector:@selector(sayMessage:) forClass:[Bizz class] block:^(Bizz* bizz, NSString* message){

  [tracker sendEventWithCategory:@"Bizz"
                      withAction:@"sayMessage"
                       withLabel:message //< You can use the argument that is passed to sayMessage:
                       withValue:0];

  [BILib performOriginalSelector:@selector(sayMessage:) target:bizz, &message, nil];
}];

// ...
```

## Usage

### + (BOOL)injectToSelector:(SEL)sel forClass:(Class)class block:(id)block;

This is a main method for injection your blocks.

* *sel*  
    Target selector.
* *class*  
    Target class.
* *block*  
    aaa

### + (void)performOriginalSelector:(SEL)sel target:(id)target, ...;

You must call this method in your block for performing the original method.

* *sel*
    Target selector.
* *target*  
    Target instance.
* *...*  
    Oiriginal method's arguments.  
    You must add **'&'** before all arguments and You must add the **nil termination**.

``` objective-c
// Sample
// If you perform UIViewController's  
// - (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;

[BILib injectToSelector:@selector(presentViewController:animated:completion:)
               forClass:[UIViewController class]
                  block:^(id target, UIViewController* vc, BOOL flag, id completion)
{
  NSLog(@"presentViewController:%@ animated:%d completion:%@", vc, flag, completion);

  [BILib performOriginalSelector:@selector(presentViewController:animated:completion:) target:target, &vc, &flag, &completion, nil];
}];
```
