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
#import "ImageCache.h"
#import "FileUpload.h"

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
    ImageCache * cache = [ImageCache sharedObject];
    FileUpload * file = [[FileUpload alloc]init];
    [file setFriendId:sendID];
    [file setFileData:audioData];
    [file setBodyDic:bodyDic];
    [cache setFileUpload:file withTime:[dateFormatter stringFromDate:date]];

    NSArray * key = [[cache getFileUpload]allKeys];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    NSMutableArray *myArray=[[NSMutableArray alloc]initWithCapacity:0];
    if (key && [key count]!=0) {
        for (NSString * k in key) {
            [dict setObject:k forKey:@"time"];
            [myArray addObject:dict];
        }
    }
    NSMutableArray *dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    [dataArray addObjectsFromArray:myArray];
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc]initWithKey:@"time" ascending:YES];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    NSArray *keyArray=[dataArray sortedArrayUsingDescriptors:sortDescriptors];
    NSMutableArray *sortArray = [[NSMutableArray alloc]init];
    if (keyArray && [keyArray count]!=0) {
        for (int i=0; i<[keyArray count]; i++) {
            [sortArray addObject:[[keyArray objectAtIndex:i] objectForKey:@"time"]];
        }
    }


    ACKMessageDB *ack = [[ACKMessageDB alloc]init];
    [ack insertDB:[NSString stringWithFormat:@"%lld", milliseconds] withUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    __block CGFloat byte = 0.0;
    if(sortArray && [sortArray count]!=0) {
          FileUpload * f = [[cache getFileUpload] objectForKey:[sortArray objectAtIndex:0]];
        [con sendFileInBackground:f.fileData toUser:f.friendId finished:^(NSString *res) {
            
            NSLog(@"%@", res);
            
        }byteSent:^(float b){
            if (b==1.000000) {
                byte = 1.000000;
                [cache removefileUpload:[sortArray objectAtIndex:0]];
                [sortArray removeObjectAtIndex:0];
            }
            NSLog(@"%@", [NSString stringWithFormat:@"%f", b]);
            
        }withBodyData:f.bodyDic];
//        if (byte != 1.000000) {
//            sleep(1);
//        }
    }
    
}

@end
