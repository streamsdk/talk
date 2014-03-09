//
//  AudioHandler.m
//  talk
//
//  Created by wangshuai on 13-12-23.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "AudioHandler.h"
#import "NSBubbleData.h"
#import "TalkDB.h"
#import "STreamXMPP.h"
#import <arcstreamsdk/JSONKit.h> 
#import "HandlerUserIdAndDateFormater.h"
#import "ACKMessageDB.h"
#import "FilesUpload.h"
#import "ImageCache.h"
#import "UploadDB.h"
@implementation AudioHandler

@synthesize isAddUploadDB;

@synthesize uploadDate;

- (void)receiveAudioFile:(NSData *)data withBody:(NSString *)body forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
       if ([fromID isEqualToString:sendID]) {
        NSBubbleData *bubble = [NSBubbleData dataWithtimes:body date:[handler getDate] type:BubbleTypeSomeoneElse withData:data];
        if (otherData)
            bubble.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:bubble];
    }
}


-(void) sendAudio :(Voice *)voice forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID
{
    HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString * bodyData = [NSString stringWithFormat:@"%d",(int)voice.recordTime];

    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    [bodyDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [bodyDic setObject:bodyData forKey:@"duration"];
    [bodyDic setObject:@"voice" forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    
    ImageCache *cache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata = [cache getUserMetadata:sendID];
    if (userMetadata && [userMetadata objectForKey:@"token"]){
        [bodyDic setObject:[userMetadata objectForKey:@"token"] forKey:@"token"];
    }
    
    NSMutableArray * fileArray = [cache getFileUpload];
    FilesUpload * file = [[FilesUpload alloc]init];
    [file setTime:[NSString stringWithFormat:@"%lld", milliseconds]];
    [file setFilepath:voice.recordPath];
    [file setBodyDict:bodyDic];
    [file setUserId:sendID];
    [file setChatId:[NSString stringWithFormat:@"%lld", milliseconds]];
    [file setType:@"voice"];
    if (isAddUploadDB) {
        isAddUploadDB = NO;
        if (fileArray!=nil && [fileArray count]!=0) {
            FilesUpload * f =[fileArray objectAtIndex:0];
            long long ftime = [f.time longLongValue];
            if ((milliseconds/1000.0 - ftime/1000.0)<8) {
                [cache addFileUpload:file];
                return;
            }
            
        }else{
            [cache addFileUpload:file];
        }
        
        [super doFileUpload:fileArray];
        
    }else{
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        NSURL* url = [NSURL fileURLWithPath:voice.recordPath];
        NSError * err = nil;
        NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        
        NSBubbleData *bubble = [NSBubbleData dataWithtimes:bodyData date:date type:BubbleTypeMine withData:audioData];
        if (myData)
            bubble.avatar = [UIImage imageWithData:myData];
        [bubbleData addObject:bubble];
        
        NSMutableDictionary * friendsDict = [NSMutableDictionary dictionary];
        [friendsDict setObject:bodyData forKey:@"time"];
        [friendsDict setObject:[url path] forKey:@"audiodata"];
        [jsonDic setObject:friendsDict forKey:sendID];
        NSString * str = [jsonDic JSONString];
        TalkDB * db = [[TalkDB alloc]init];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
        [file setDate:date];
        [file setJsonDict:friendsDict];
        UploadDB * uploadDb = [[UploadDB alloc]init];
        [uploadDb insertUploadDB:[handler getUserID] filePath:voice.recordPath withTime:bodyData withFrom:sendID withType:@"voice" withDate:[dateFormatter stringFromDate:date]];
        
        if (fileArray != nil && [fileArray count] != 0) {
            FilesUpload * f =[fileArray objectAtIndex:0];
            long long ftime = [f.time longLongValue];
            if ((milliseconds/1000.0 - ftime/1000.0)<8) {
                [cache addFileUpload:file];
                return;
            }
        }
        [cache addFileUpload:file];
        [super doFileUpload:fileArray];
    }
    
}

@end
