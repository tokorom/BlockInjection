//
//  MIRuntime.h
//
//  Created by ToKoRo on 2013-02-27.
//

#import <objc/runtime.h>

struct mi_objc_method {
    SEL method_name;
    char* method_types;
    IMP method_imp;
};

