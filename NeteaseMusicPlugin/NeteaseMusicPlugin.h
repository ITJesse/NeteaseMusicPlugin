//
//  NeteaseMusicPlugin.h
//  NeteaseMusicPlugin
//
//  Created by Jesse Zhu on 2017/5/4.
//  Copyright © 2017年 Jesse Zhu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Helper.h"
#import "JSONModel.h"
#import "JSONHTTPClient.h"

//! Project version number for NeteaseMusicPlugin.
FOUNDATION_EXPORT double NeteaseMusicPluginVersionNumber;

//! Project version string for NeteaseMusicPlugin.
FOUNDATION_EXPORT const unsigned char NeteaseMusicPluginVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NeteaseMusicPlugin/PublicHeader.h>

@interface NSObject (NeteaseMusicHook)
+ (void)hookNeteaseMusic;
@end

@interface ComNeteaseCloudMusicCoSDKNTESJson : NSObject
+ (id)ntes_jsonDataWithUTF8:(id)arg1;
+ (id)ntes_jsonObjectWithUTF8:(id)arg1;
@end

@interface SongModel : JSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger code;
@property (nonatomic) NSInteger br;
@property (nonatomic) NSInteger expi;
@property (nonatomic) NSInteger fee;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger payed;
@property (nonatomic) NSString<Optional>* md5;
@property (nonatomic) NSString<Optional>* type;
@property (nonatomic) NSString<Optional>* url;
@property (nonatomic) float gain;
@property (nonatomic) BOOL canExtend;
@end

@interface ResModel : JSONModel
@property (nonatomic) NSInteger code;
@property (nonatomic) NSArray<SongModel *> *data;
@end

