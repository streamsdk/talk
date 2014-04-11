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
static NSMutableArray *_fileUpload;
static NSMutableDictionary * dic;
static NSMutableDictionary*_downloadingFile;
static NSMutableDictionary*_countDict;
static NSLock *_theLock;
static NSMutableArray * _downVideo;
static NSMutableDictionary *_contentOffset;
static NSMutableDictionary*_allCountDict;
static NSMutableDictionary*_onlineDict;
static NSMutableDictionary*_voiceDict;
static NSMutableArray * _searchImage;
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
        _fileUpload = [[NSMutableArray alloc]init];
        dic = [[NSMutableDictionary alloc]init];
        _downloadingFile =[[NSMutableDictionary alloc]init];
        _countDict = [[NSMutableDictionary alloc]init];
        _theLock = [[NSLock alloc] init];
        _downVideo = [[NSMutableArray alloc]init];
        _contentOffset = [[NSMutableDictionary alloc]init];
        _allCountDict = [[NSMutableDictionary alloc]init];
        _onlineDict = [[NSMutableDictionary alloc]init];
        _voiceDict = [[NSMutableDictionary alloc]init];
        _searchImage =[[NSMutableArray alloc]init];
    });
    
    return sharedInstance;

}

- (NSLock *)getLock{
    return _theLock;
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
-(void)removefileId:(NSString *)fileId{
    [_cachedSelfImageFiles removeObject:fileId];
    [_selfImageDictionary removeObjectForKey:fileId];
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
-(void) addFileUpload:(FilesUpload *)file{
    
    [_fileUpload addObject:file];
}

-(NSMutableArray *)getFileUpload{
    return _fileUpload;
}

-(void)removeFileUpload:(FilesUpload *)file{

    [_fileUpload removeObject:file];
}

-(void)removeAllFileUpload{
    
    [_fileUpload removeAllObjects];
}
-(void) saveBubbleData:(NSBubbleData *)bubbledata withKey:(NSString *)key{
    
    [dic setObject:bubbledata forKey:key];
}

-(NSMutableDictionary *)getBubbleData{
    
    return dic;
}

-(void)removeBubbleData:(NSString *)key{
   
    [dic removeObjectForKey:key];
}

-(void)addDownloadingFile:(NSString *)fileId withTag:(NSNumber *)tag{
    [_downloadingFile setObject:tag forKey:fileId];
}


-(BOOL)isFileDownloading:(NSString *)fileId{
    NSArray * keys = [_downloadingFile allKeys];
    return [keys containsObject:fileId];
}

-(void)removeDownloadingFile:(NSString *)fileId{
    [_downloadingFile removeObjectForKey:fileId];
}

-(NSNumber *)getDownloadingFile:(NSString *)fileId{
    
    return [_downloadingFile objectForKey:fileId];
}

-(void) saveRaedCount:(NSNumber *)count withuserID:(NSString *)userId{
    if (userId) {
        [_countDict setObject:count forKey:userId];
    }
    
}

-(NSInteger)getReadCount:(NSString *)userId{

    return [[_countDict objectForKey:userId]intValue];
}

-(void) removeCoun{
    [_countDict removeAllObjects];
}
-(void) saveRaedAllCount:(NSNumber *)count withuserID:(NSString *)userId{
    if (userId) {
        [_allCountDict setObject:count forKey:userId];
    }
}

-(NSInteger)getAllReadCount:(NSString *)userId{
    return [[_allCountDict objectForKey:userId]intValue];
}
-(void) saveDownVideo :(DownLoadVideo *)downVideo{
    [_downVideo addObject:downVideo];
}
-(DownLoadVideo *)getDownVideo{
   return [_downVideo objectAtIndex:0];
}
-(BOOL) downVideoArrayIsNull{
    if ([_downVideo count]==0) {
        return YES;
    }else{
        return NO;
    }
}
-(void) deleteDownVideo{
    [_downVideo removeObjectAtIndex:0];
}
-(void) saveTablecontentOffset:(CGFloat)f withUser:(NSString *)user{
    [_contentOffset setObject:[NSNumber numberWithFloat:f] forKey:user];
}
-(CGFloat)getTablecontentOffset:(NSString *)user{
    return [[_contentOffset objectForKey:user] floatValue];
}

-(void)saveOnline:(NSString *)online withuserId:(NSString *)userId{
    [_onlineDict setObject:online forKey:userId];
}
-(NSString *)getOnline:(NSString *)userId{
    return [_onlineDict objectForKey:userId];
}
-(void)saveVoiceFile:(NSArray *)array withfileID:(NSString *)fileId{
    [_voiceDict setObject:array forKey:fileId];
}
-(NSArray *)getVoiceFile:(NSString *)fileId{
    return [_voiceDict objectForKey:fileId];
}
-(void)removeVoiceFile:(NSString *)fileId{
    
    [_voiceDict removeObjectForKey:fileId];
}
-(void)saveSearchImage:(UIImage *)image{
    [_searchImage addObject:image];
}
-(NSMutableArray *)getSearchImage{
    return _searchImage;
}
-(void)removeSearchImage{
    [_searchImage removeAllObjects];
}
@end
