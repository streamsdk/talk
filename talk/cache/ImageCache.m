//
//  ImageCache.m
//  talk
//
//  Created by wangsh on 13-12-14.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "ImageCache.h"
#import "FileCache.h"

static NSMutableDictionary *_userMetaData;
static FileCache *fileCache;
static NSMutableDictionary *_imageDictionary;
static NSMutableDictionary *_selfImageDictionary;
static NSMutableArray *_cachedSelfImageFiles;
static NSString * _friendID;
static NSDate * _time;
@implementation ImageCache


+(ImageCache *)sharedObject {
    static ImageCache *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[ImageCache alloc] init];
         _userMetaData = [[NSMutableDictionary alloc] init];
         fileCache = [FileCache sharedObject];
        _cachedSelfImageFiles = [[NSMutableArray alloc] init];
        _imageDictionary = [[NSMutableDictionary alloc] init];
        _selfImageDictionary = [[NSMutableDictionary alloc] init];
    });
    
    return sharedInstance;

}

-(void)saveUserMetadata:(NSString *)userName withMetadata:(NSMutableDictionary *)metaData{
    
     [_userMetaData setObject:metaData forKey:userName];
}

-(NSMutableDictionary *)getUserMetadata:(NSString *)userName{
    
     return [_userMetaData objectForKey:userName];
}

-(void)selfImageDownload:(NSData *)file withFileId:(NSString *)fileId{
    if ([_cachedSelfImageFiles count] >= 40){
        
        for (int i=0; i < 1; i++){
            NSString *fId = [_cachedSelfImageFiles objectAtIndex:i];
            [_selfImageDictionary removeObjectForKey:fId];
            [_cachedSelfImageFiles removeObjectAtIndex:i];
        }
        
    }
    [_cachedSelfImageFiles addObject:fileId];
    [_selfImageDictionary setObject:file forKey:fileId]; 
}

-(NSData *)getImage:(NSString *)fileId{
    NSData *data =  [_selfImageDictionary objectForKey:fileId];
    if (data){
        
    }else{
        data = [fileCache readFromFileDoc:fileId];
        if (data)
            [_selfImageDictionary setObject:data forKey:fileId];
    }
    
    return data;
}

-(void) setFriendID:(NSString *)friendID{
    _friendID = friendID;
}

-(NSString *) getFriendID{
    return _friendID;
}

-(void) messageTime :(NSDate *) time {
    _time = time;
}
-(NSDate *) getMessageTime{

    return _time;
}
@end
