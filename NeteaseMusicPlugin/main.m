//
//  main.m
//  NeteaseMusicPlugin
//
//  Created by Jesse Zhu on 2017/5/4.
//  Copyright © 2017年 Jesse Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NeteaseMusicPlugin.h"

static void __attribute__((constructor)) initialize(void) {
    NSLog(@"+++ NeteaseMusicPlugin Loaded +++");
    [NSObject hookNeteaseMusic];
}
