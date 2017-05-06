//
//  TKHelper.m
//  WeChatPlugin
//
//  Created by TK on 2017/4/19.
//  Copyright © 2017年 tk. All rights reserved.
//

#import "Helper.h"

@implementation Helper

/**
 替换对象方法
 
 @param originalClass 原始类
 @param originalSelector 原始类的方法
 @param swizzledClass 替换类
 @param swizzledSelector 替换类的方法
 */
void hookMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    if(originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
        NSLog(@"Inject successful");
    } else {
        NSLog(@"Inject faild");
    }
}

/**
 替换类方法
 
 @param originalClass 原始类
 @param originalSelector 原始类的类方法
 @param swizzledClass 替换类
 @param swizzledSelector 替换类的类方法
 */
void hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(swizzledClass, swizzledSelector);
    if(originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
        NSLog(@"Inject successful");
    } else {
        NSLog(@"Inject faild");
    }
}

@end
