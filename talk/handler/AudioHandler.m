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

@implementation AudioHandler

- (NSMutableDictionary *)receiveAudioFile:(NSData *)data withBody:(NSString *)body forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    if ([fromID isEqualToString:sendID]) {
        NSBubbleData *bubble = [NSBubbleData dataWithtimes:[body stringByAppendingString:@"\""] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse withData:data];
        if (otherData)
            bubble.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:bubble];
    }
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    
    NSString * recordFilePath = [[handler getPath] stringByAppendingString:@".aac"];
    [data writeToFile:recordFilePath atomically:YES];
    NSMutableDictionary * friendsDict = [NSMutableDictionary dictionary];
    [friendsDict setObject:[body stringByAppendingString:@"\""] forKey:@"time"];
    [friendsDict setObject:recordFilePath forKey:@"audiodata"];
    [jsonDic setObject:friendsDict forKey:sendID];
    return jsonDic;
}
-(void) sendAudio :(Voice *)voice forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID
{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    NSURL* url = [NSURL fileURLWithPath:voice.recordPath];
    NSError * err = nil;
    NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    NSString * bodyData = [NSString stringWithFormat:@"%d",(int)voice.recordTime];
    
    NSBubbleData *bubble = [NSBubbleData dataWithtimes:bodyData date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine withData:audioData];
    if (myData)
        bubble.avatar = [UIImage imageWithData:myData];
    [bubbleData addObject:bubble];
    
    NSMutableDictionary * friendsDict = [NSMutableDictionary dictionary];
    [friendsDict setObject:bodyData forKey:@"time"];
    [friendsDict setObject:[url path] forKey:@"audiodata"];
    [jsonDic setObject:friendsDict forKey:sendID];
    NSString * str = [jsonDic JSONString];
    NSLog(@"json===:%@",str);
    TalkDB * db = [[TalkDB alloc]init];
    HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    
    [con sendFileInBackground:audioData toUser:sendID finished:^(NSString *res) {
        
        NSLog(@"%@", res);
        
    }byteSent:^(float b){
        
        NSLog(@"%@", [NSString stringWithFormat:@"%1.6f", b]);
        
    }withBodyData:bodyData];
}

@end
