//
//  NeteaseMusicPlugin.m
//  NeteaseMusicPlugin
//
//  Created by Jesse Zhu on 2017/5/4.
//  Copyright © 2017年 Jesse Zhu. All rights reserved.
//

#import <NeteaseMusicPlugin.h>

NSString *apiServer = @"http://nas.itjesse.com:8123";

@implementation SongModel
@end

@implementation ResModel
@end

@implementation DownloadModel
@end

@implementation NSObject (NeteaseMusicHook)

+ (void)hookNeteaseMusic {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        hookClassMethod(objc_getClass("CloudMusicCoSDK"), @selector(decryptData:), [self class], @selector(hook_decryptData:));
    });
}

- (NSString *)hook_decryptData:(id)data {
    NSLog(@"\n=== hook_decryptData ===");
    NSString *content = [self hook_decryptData:data];
    NSLog(@"\n%@", content);
    
    NSError *error = nil;
    ResModel *res = [[ResModel alloc] initWithString:content error:&error];
    SongModel* song = nil;
    if (error) {
        NSLog(@"Cannot parse JSON: %@", error);
        error = nil;
        DownloadModel *res = [[DownloadModel alloc] initWithString:content error:&error];
        if (error) {
            NSLog(@"Cannot parse JSON: %@", error);
            return content;
        }
        song = [res data];
    }
    
    NSArray* songArr = nil;
    if (!song) {
        songArr = [SongModel arrayOfModelsFromDictionaries:[res data] error:&error];
        if (error) {
            NSLog(@"Cannot parse JSON: %@", error);
            return content;
        }
        song = songArr[0];
    }
    
    
    NSLog(@"\n%@", song);
    
    if ([song code] != 200) {
        NSLog(@"\nSong is null, send to api server");
        NSString *urlStr;
        if (songArr) {
            urlStr = [NSString stringWithFormat:@"%@/api/plugin/player", apiServer];
        } else {
            urlStr = [NSString stringWithFormat:@"%@/api/plugin/download", apiServer];
        }
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        NSURLResponse *response;
        NSError *error;
        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *resultStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSString *errorDesc = [error localizedDescription];

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [httpResponse statusCode];
        
        NSLog(@"%ld, %@", (long)statusCode, resultStr);
        
        if (statusCode == 200) {
            return resultStr;
        } else {
            NSLog(@"\nCannot get song from api server: %@", errorDesc);
        }
    }
    
    return content;
}

@end

static void __attribute__((constructor)) initialize(void) {
    NSLog(@"+++ NeteaseMusicPlugin Loaded +++");
    [NSObject hookNeteaseMusic];
}
