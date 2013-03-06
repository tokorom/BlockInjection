//
//  BILibArg.m
//
//  Created by ToKoRo on 2013-03-06.
//

#import "BILibArg.h"

#define BILIBARG_STRUCT(siz) struct bilib_struct_##siz { char buff[siz]; }

#define EXPAND_BITBARG_STRUCT(prf) \
  BILIBARG_STRUCT(prf ## 00); \
  BILIBARG_STRUCT(prf ## 04); \
  BILIBARG_STRUCT(prf ## 08); \
  BILIBARG_STRUCT(prf ## 12); \
  BILIBARG_STRUCT(prf ## 16); \
  BILIBARG_STRUCT(prf ## 20); \
  BILIBARG_STRUCT(prf ## 24); \
  BILIBARG_STRUCT(prf ## 28); \
  BILIBARG_STRUCT(prf ## 32); \
  BILIBARG_STRUCT(prf ## 36); \
  BILIBARG_STRUCT(prf ## 40); \
  BILIBARG_STRUCT(prf ## 44); \
  BILIBARG_STRUCT(prf ## 48); \
  BILIBARG_STRUCT(prf ## 52); \
  BILIBARG_STRUCT(prf ## 56); \
  BILIBARG_STRUCT(prf ## 60); \
  BILIBARG_STRUCT(prf ## 64); \
  BILIBARG_STRUCT(prf ## 68); \
  BILIBARG_STRUCT(prf ## 72); \
  BILIBARG_STRUCT(prf ## 76); \
  BILIBARG_STRUCT(prf ## 80); \
  BILIBARG_STRUCT(prf ## 84); \
  BILIBARG_STRUCT(prf ## 88); \
  BILIBARG_STRUCT(prf ## 92); \
  BILIBARG_STRUCT(prf ## 96)

BILIBARG_STRUCT(12);
BILIBARG_STRUCT(16);
BILIBARG_STRUCT(20);
BILIBARG_STRUCT(24);
BILIBARG_STRUCT(28);
BILIBARG_STRUCT(32);
BILIBARG_STRUCT(36);
BILIBARG_STRUCT(40);
BILIBARG_STRUCT(44);
BILIBARG_STRUCT(48);
BILIBARG_STRUCT(52);
BILIBARG_STRUCT(56);
BILIBARG_STRUCT(60);
BILIBARG_STRUCT(64);
BILIBARG_STRUCT(68);
BILIBARG_STRUCT(72);
BILIBARG_STRUCT(76);
BILIBARG_STRUCT(80);
BILIBARG_STRUCT(84);
BILIBARG_STRUCT(88);
BILIBARG_STRUCT(92);
BILIBARG_STRUCT(96);
EXPAND_BITBARG_STRUCT(1);
EXPAND_BITBARG_STRUCT(2);
EXPAND_BITBARG_STRUCT(3);
EXPAND_BITBARG_STRUCT(4);
EXPAND_BITBARG_STRUCT(5);
EXPAND_BITBARG_STRUCT(6);
EXPAND_BITBARG_STRUCT(7);
EXPAND_BITBARG_STRUCT(8);
EXPAND_BITBARG_STRUCT(9);
EXPAND_BITBARG_STRUCT(10);

#define ELSE_BILIBARG(siz) } else if (siz >= size) { \
  struct bilib_struct_##siz arg = va_arg(*pargp, struct bilib_struct_##siz); \
  [invocation setArgument:&arg atIndex:index]

#define EXPAND_ELSE_BILIBAG(prf) \
  ELSE_BILIBARG(prf ## 00); \
  ELSE_BILIBARG(prf ## 04); \
  ELSE_BILIBARG(prf ## 08); \
  ELSE_BILIBARG(prf ## 12); \
  ELSE_BILIBARG(prf ## 16); \
  ELSE_BILIBARG(prf ## 20); \
  ELSE_BILIBARG(prf ## 24); \
  ELSE_BILIBARG(prf ## 28); \
  ELSE_BILIBARG(prf ## 32); \
  ELSE_BILIBARG(prf ## 36); \
  ELSE_BILIBARG(prf ## 40); \
  ELSE_BILIBARG(prf ## 44); \
  ELSE_BILIBARG(prf ## 48); \
  ELSE_BILIBARG(prf ## 52); \
  ELSE_BILIBARG(prf ## 56); \
  ELSE_BILIBARG(prf ## 60); \
  ELSE_BILIBARG(prf ## 64); \
  ELSE_BILIBARG(prf ## 68); \
  ELSE_BILIBARG(prf ## 72); \
  ELSE_BILIBARG(prf ## 76); \
  ELSE_BILIBARG(prf ## 80); \
  ELSE_BILIBARG(prf ## 84); \
  ELSE_BILIBARG(prf ## 88); \
  ELSE_BILIBARG(prf ## 92); \
  ELSE_BILIBARG(prf ## 96)

@implementation BILibArg

#pragma mark - Public Interface
  
+ (void)sendArgumentsToInvocation:(NSInvocation*)invocation
                        arguments:(va_list*)pargp
                numberOfArguments:(NSUInteger)numberOfArguments
                        signature:(NSMethodSignature*)signature
{
  int index = 2;
  while (numberOfArguments--) {
    NSUInteger size, alignment;
    NSGetSizeAndAlignment([signature getArgumentTypeAtIndex:index], &size, &alignment);
    if (4 >= size) {
      void* pval = va_arg(*pargp, void*);
      [invocation setArgument:&pval atIndex:index++];
    } else if (8 >= size) {
      double dval = va_arg(*pargp, double);
      [invocation setArgument:&dval atIndex:index++];
    } else {
      [BILibArg sendOneArgumentToInvocation:invocation
                                  arguments:pargp
                                      index:index++
                                       size:size];
    }
  }
}

#pragma mark - Private Methods

+ (void)sendOneArgumentToInvocation:(NSInvocation*)invocation
                          arguments:(va_list*)pargp
                              index:(NSUInteger)index
                               size:(NSUInteger)size
{
  if (NO) {
  ELSE_BILIBARG(12);
  ELSE_BILIBARG(16);
  ELSE_BILIBARG(20);
  ELSE_BILIBARG(24);
  ELSE_BILIBARG(28);
  ELSE_BILIBARG(32);
  ELSE_BILIBARG(36);
  ELSE_BILIBARG(40);
  ELSE_BILIBARG(44);
  ELSE_BILIBARG(48);
  ELSE_BILIBARG(52);
  ELSE_BILIBARG(56);
  ELSE_BILIBARG(60);
  ELSE_BILIBARG(64);
  ELSE_BILIBARG(68);
  ELSE_BILIBARG(72);
  ELSE_BILIBARG(76);
  ELSE_BILIBARG(80);
  ELSE_BILIBARG(84);
  ELSE_BILIBARG(88);
  ELSE_BILIBARG(92);
  ELSE_BILIBARG(96);
  EXPAND_ELSE_BILIBAG(1);
  EXPAND_ELSE_BILIBAG(2);
  EXPAND_ELSE_BILIBAG(3);
  EXPAND_ELSE_BILIBAG(4);
  EXPAND_ELSE_BILIBAG(5);
  EXPAND_ELSE_BILIBAG(6);
  EXPAND_ELSE_BILIBAG(7);
  EXPAND_ELSE_BILIBAG(8);
  EXPAND_ELSE_BILIBAG(9);
  EXPAND_ELSE_BILIBAG(10);
  } else {
    struct bilib_struct_1096 arg = va_arg(*pargp, struct bilib_struct_1096);
    [invocation setArgument:&arg atIndex:index];
  }
}

@end
