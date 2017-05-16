#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>

NSMutableDictionary *MusicIDsMap;

@interface HijackURLProtocol : NSURLProtocol <NSURLConnectionDelegate>
    @property(nonatomic, strong) NSURLConnection *connection;
    @property(nonatomic, strong) NSMutableData *responseData;
    @end

@implementation HijackURLProtocol{
    BOOL isStream;
}
    
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSLog(@"URL: %@", [[request URL] path]);
    if ([NSURLProtocol propertyForKey:@"Hijacked" inRequest:request]) {
        return NO;
    }else if ([[[request URL] path] isEqualToString:@"/eapi/v3/song/detail"]) {
        return YES;
    }else if([[[request URL] path] isEqualToString:@"/eapi/v3/playlist/detail"]){
        return YES;
    }else if([[[request URL] path] containsString:@"/eapi/cloudsearch/pc"]){
        return YES;
    }else if([[[request URL] path] containsString:@"/eapi/v1/album"]){
        return YES;
    }else if([[[request URL] path] containsString:@"/eapi/v1/artist"]){
        return YES;
    }else if([[[request URL] path] containsString:@"/eapi/song/enhance/player/url"]){
        return YES;
    }else if([[[request URL] path] isEqualToString:@"/eapi/v1/discovery/new/songs"]){
        return YES;
    }else if([[[request URL] path] isEqualToString:@"/eapi/v1/discovery/recommend/songs"]){
        return YES;
    }else if([[[request URL] path] isEqualToString:@"/eapi/batch"]){
        return YES;
    }
    return NO;
}
    
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}
    
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}
    
- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    NSString* ip = [NSString stringWithFormat:@"202.114.79.%d", (arc4random() % 255) + 1];
    [newRequest addValue:ip forHTTPHeaderField:@"X-Real-IP"];
    [NSURLProtocol setProperty:@YES forKey:@"Hijacked" inRequest:newRequest];
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}
    
- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}
    
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
    NSURLResponse *res = response;
    [self.client URLProtocol:self
          didReceiveResponse:res
          cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}
    
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(isStream){
        [self.client URLProtocol:self didLoadData:data];
    }else{
        [self.responseData appendData:data];
    }
}
    
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    id res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:nil];
    if(!res || ![res count]){
        NSLog(@"Cannot get json data");
        return [self returnOriginData];
    }
    
    int replaced = 0;
    
    // Privileges
    if(![self isEmpty:res[@"privileges"]]){
        unsigned long count = [res[@"privileges"] count];
        for (int i = 0; i < count; i++) {
            NSNumber *st = res[@"privileges"][i][@"st"];
            NSNumber *fee = res[@"privileges"][i][@"fee"];
            if(st.intValue < 0 || fee.intValue > 0){
                res[@"privileges"][i] = [self replacePrivilege:res[@"privileges"][i]];
                replaced++;
            }
        }
    }
    
    // Search Results
    if(![self isEmpty:res[@"result"]] && ![self isEmpty:res[@"result"][@"songs"]]){
        unsigned long scount = [res[@"result"][@"songs"] count];
        for (int i = 0; i < scount; i++) {
            id song = res[@"result"][@"songs"][i];
            song[@"st"] = @0;
            song[@"fee"] = @0;
            song[@"privilege"] = [self replacePrivilege:song[@"privilege"]];
            replaced++;
            MusicIDsMap[song[@"id"]] = song;
            res[@"result"][@"songs"][i] = song;
        }
    }
    
    
    // Songs
    if(![self isEmpty:res[@"songs"]]){
        unsigned long scount = [res[@"songs"] count];
        for (int i = 0; i < scount; i++) {
            id song = res[@"songs"][i];
            song[@"st"] = @0;
            song[@"fee"] = @0;
            if(![self isEmpty:song[@"privilege"]]){
                song[@"privilege"] = [self replacePrivilege:song[@"privilege"]];
                replaced++;
            }
            MusicIDsMap[song[@"id"]] = song;
            res[@"songs"][i] = song;
        }
    }
    
    // Hot Songs
    if(![self isEmpty:res[@"hotSongs"]]){
        unsigned long scount = [res[@"hotSongs"] count];
        for (int i = 0; i < scount; i++) {
            id song = res[@"hotSongs"][i];
            song[@"st"] = @0;
            song[@"fee"] = @0;
            if(![self isEmpty:song[@"privilege"]]){
                song[@"privilege"] = [self replacePrivilege:song[@"privilege"]];
                replaced++;
            }
            MusicIDsMap[song[@"id"]] = song;
            res[@"hotSongs"][i] = song;
        }
    }
    
    // Playlists
    if(![self isEmpty:res[@"playlist"]] && ![self isEmpty:res[@"playlist"][@"tracks"]]){
        unsigned long scount = [res[@"playlist"][@"tracks"] count];
        for (int i = 0; i < scount; i++) {
            res[@"playlist"][@"tracks"][i][@"st"] = @0;
            res[@"playlist"][@"tracks"][i][@"fee"] = @0;
            MusicIDsMap[res[@"playlist"][@"tracks"][i][@"id"]] = res[@"playlist"][@"tracks"][i];
        }
    }
    
    NSLog(@"蛤蛤！替换了 %d 首被下架的歌曲",replaced);
    NSData *d = [NSJSONSerialization dataWithJSONObject:res options:0 error:nil];
    [self.client URLProtocol:self didLoadData:d];
    [self.client URLProtocolDidFinishLoading:self];
}
    
- (NSDictionary *)replacePrivilege:(NSDictionary *)dict{
    NSMutableDictionary *res = [dict mutableCopy];
    res[@"st"] = @0;
    res[@"pl"] = res[@"maxbr"];
    res[@"dl"] = res[@"maxbr"];
    res[@"fl"] = res[@"maxbr"];
    res[@"sp"] = @7;
    res[@"cp"] = @1;
    res[@"subp"] = @1;
    res[@"fee"] = @0;
    return res;
}
    
- (void)returnOriginData{
    [self.client URLProtocol:self didLoadData:self.responseData];
    [self.client URLProtocolDidFinishLoading:self];
}
    
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}
    
- (BOOL)isEmpty:(id)obj{
    if(!obj || [obj isEqual:[NSNull null]] || ![obj count]){
        return YES;
    }
    return NO;
}
    
    @end

BOOL isLoaded = NO;

__attribute__((constructor)) void DllMain()
{
    if (!isLoaded) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            MusicIDsMap = [[NSMutableDictionary alloc] init];
            if ([NSURLProtocol registerClass:[HijackURLProtocol class]]) {
                NSLog(@"[NMUnlock] 插♂入成功! ");
            } else {
                NSLog(@"[NMUnlock] 我去竟然失败了");
            }
            isLoaded = YES;
        });
    }
}
