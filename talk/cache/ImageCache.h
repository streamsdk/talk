//
//  ImageCache.h
//  talk
//
//  Created by wangsh on 13-12-14.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilesUpload.h"
#import "NSBubbleData.h"
#import "DownLoadVideo.h"

@interface ImageCache : NSObject

+(ImageCache *)sharedObject;

-(NSLock *)getLock;

-(void)selfImageDownload:(NSData *)file withFileId:(NSString *)fileId;

-(NSData *)getImage:(NSString *)fileId;

-(void)removefileId:(NSString *)fileId;

-(void)saveUserMetadata:(NSString *)userName withMetadata:(NSMutableDictionary *)metaData;

-(NSMutableDictionary *)getUserMetadata:(NSString *)userName;

-(void) setFriendID:(NSString *)friendID;

-(NSString *) getFriendID;

-(void) setMessagesCount:(NSString *)friendId;

-(NSInteger)getMessagesCount:(NSString *)friendId;

-(void) removeFriendID:(NSString *)friendId;

-(void) setBrushColor:(UIColor *)color;

-(NSMutableArray *)getBrushColor;

-(void)setTwitters:(NSMutableArray *)twitters;;

-(NSMutableArray *)getTwitters;

-(void)saveJsonData:(NSString *)jd forFileId:(NSString *)fileId;

-(NSString *)getJsonData:(NSString *)fileId;

-(void)deleteJsonData:(NSString *)fileId;

-(void) addFileUpload:(FilesUpload *)file;

-(NSMutableArray *)getFileUpload;

-(void)removeFileUpload:(FilesUpload *)file;

-(void)removeAllFileUpload;

-(void) saveBubbleData:(NSBubbleData *)bubbledata withKey:(NSString *)key;

-(NSMutableDictionary *)getBubbleData;

-(void)removeBubbleData:(NSString *)key;

-(void)addDownloadingFile:(NSString *)fileId withTag:(NSNumber *)tag;

-(BOOL)isFileDownloading:(NSString *)fileId;

-(void)removeDownloadingFile:(NSString *)fileId;

-(NSNumber *)getDownloadingFile:(NSString *)fileId;

-(void) saveRaedCount:(NSNumber *)count withuserID:(NSString *)userId ;

-(NSInteger)getReadCount:(NSString *)userId;

-(void) removeCoun;

-(void) saveRaedAllCount:(NSNumber *)count withuserID:(NSString *)userId ;

-(NSInteger)getAllReadCount:(NSString *)userId;

-(void) saveDownVideo :(DownLoadVideo *)downVideo;
-(DownLoadVideo *)getDownVideo;
-(void) deleteDownVideo;
-(BOOL) downVideoArrayIsNull;

-(void)saveTablecontentOffset:(CGFloat)f withUser:(NSString *)user;

-(CGFloat) getTablecontentOffset:(NSString *)user;

-(void)saveOnline:(NSString *)online withuserId:(NSString *)userId;
-(NSString *)getOnline:(NSString *)userId;

-(void)saveVoiceFile:(NSArray *)array withfileID:(NSString *)fileId;
-(NSArray *)getVoiceFile:(NSString *)fileId;
-(void)removeVoiceFile:(NSString *)fileId;

-(void)saveSearchImage:(UIImage *)image;
-(NSMutableArray *)getSearchImage;
-(void)removeSearchImage;
@end
