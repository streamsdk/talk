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
static NSMutableArray *_messagesCount;
static NSMutableDictionary *_messagesDict;
static NSMutableArray * _colors;
static NSMutableArray * _twitters;
static NSMutableDictionary *_jsonData;

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
        _messagesCount = [[NSMutableArray alloc]init];
        _messagesDict = [[NSMutableDictionary alloc]init];
        _colors =[[NSMutableArray alloc]init];
        _twitters = [[NSMutableArray alloc]init];
        _jsonData = [[NSMutableDictionary alloc] init];
    });
    
    return sharedInstance;

}

-(void)saveJsonData:(NSString *)jd forFileId:(NSString *)fileId{
    [_jsonData setObject:jd forKey:fileId];
}

-(NSString *)getJsonData:(NSString *)fileId{
    return [_jsonData objectForKey:fileId];
}

-(void)deleteJsonData:(NSString *)fileId{
    [_jsonData removeObjectForKey:fileId];
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
-(void)setMessagesCount:(NSString *)friendId {
    if ([[_messagesDict allKeys] containsObject:friendId]) {
         NSInteger count =[[_messagesDict objectForKey:friendId] integerValue];
        NSString * str = [NSString stringWithFormat:@"%d",count+1];
        [_messagesDict setObject:str forKey:friendId];
    }else{
        [_messagesDict setObject:@"1" forKey:friendId];
    }
}
-(NSInteger) getMessagesCount:(NSString *)friendId {
    
    NSInteger count =[[_messagesDict objectForKey:friendId] integerValue];
    return  count;
}
-(void) removeFriendID:(NSString *)friendId{
    [_messagesDict removeObjectForKey:friendId];
}
//BrushColor
-(void) setBrushColor:(UIColor *)color{
    [_colors addObject:color];
}

-(NSMutableArray *)getBrushColor{
    return _colors;
}

-(void)setTwitters:(NSMutableArray *)twitters{
    
    _twitters = twitters;
}

-(NSMutableArray *)getTwitters{
    return _twitters;
}
@end
