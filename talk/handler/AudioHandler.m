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

@implementation AudioHandler

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
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    NSURL* url = [NSURL fileURLWithPath:voice.recordPath];
    NSError * err = nil;
    NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    NSString * bodyData = [NSString stringWithFormat:@"%d",(int)voice.recordTime];
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
    HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    [bodyDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [bodyDic setObject:bodyData forKey:@"duration"];
    [bodyDic setObject:@"voice" forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    
    ACKMessageDB *ack = [[ACKMessageDB alloc]init];
    [ack insertDB:[NSString stringWithFormat:@"%lld", milliseconds] withUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    
    [con sendFileInBackground:audioData toUser:sendID finished:^(NSString *res) {
        
        NSLog(@"%@", res);
        
    }byteSent:^(float b){
        
        NSLog(@"%@", [NSString stringWithFormat:@"%1.6f", b]);
        
    }withBodyData:bodyDic];
}

@end
