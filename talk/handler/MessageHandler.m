//
//  MessageHandler.m
//  talk
//
//  Created by wangshuai on 13-12-23.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "MessageHandler.h"
#import <arcstreamsdk/JSONKit.h>
#import "TalkDB.h"
#import "NSBubbleData.h"
#import "STreamXMPP.h"
#import "HandlerUserIdAndDateFormater.h"
#import "ACKMessageDB.h"
#import "ImageCache.h"

@implementation MessageHandler

- ( void)receiveMessage:(NSString *)receiveMessage forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    if ([fromID isEqualToString:sendID]) {
        NSBubbleData *sendBubble = [NSBubbleData dataWithText:receiveMessage date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        if (otherData)
            sendBubble.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:sendBubble];
    }

}

-(void) sendMessage :(NSString *)messages forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
    NSBubbleData *sendBubble = [NSBubbleData dataWithText:messages date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    if (myData)
        sendBubble.avatar = [UIImage imageWithData:myData];
    [bubbleData addObject:sendBubble];
  
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    
    //new message format
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSMutableDictionary *messagesDic = [[NSMutableDictionary alloc] init];
    [messagesDic setObject:messages forKey:@"message"];
    [messagesDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [messagesDic setObject:@"text" forKey:@"type"];
    [messagesDic setObject:[handler getUserID] forKey:@"from"];
    
    ImageCache *cache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata = [cache getUserMetadata:sendID];
    if (userMetadata && [userMetadata objectForKey:@"token"]){
        [messagesDic setObject:[userMetadata objectForKey:@"token"] forKey:@"token"];
    }
        
        
    NSString *messageSent = [messagesDic JSONString];

    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:messages forKey:@"messages"];
    [jsonDic setObject:friendDict forKey:sendID];
    NSString  *str = [jsonDic JSONString];
    
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    ACKMessageDB *ack = [[ACKMessageDB alloc]init];
    [ack insertDB:[NSString stringWithFormat:@"%lld", milliseconds] withUserID:[handler getUserID] fromID:sendID withContent:messageSent withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
     [con sendMessage:sendID withMessage:messageSent];
    
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
   
}
-(void) sendFile :(NSString *)messages forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID{
    NSData *jsonData = [messages dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *json = [decoder objectWithData:jsonData];
    NSString * path =nil;
    NSString * type =nil;
    
    if ([json objectForKey:@"photo"]) {
        path =[json objectForKey:@"photo"];
        type = @"photo";
    }else if ([json objectForKey:@"audiodata"]) {
        path =[json objectForKey:@"audiodata"];
        type = @"voice";
    }else{
        return;
    }
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSString *time =[json objectForKey:@"time"];
    if ([time isEqualToString:@"-1"])
        return;
    UIImage *image = [UIImage imageWithData:data];
    NSString * fileId =[json objectForKey:@"fileId"];
    if (fileId==nil || [fileId isEqualToString:@""]) {
        UIAlertView * view = [[UIAlertView alloc]initWithTitle:nil message:@"send Error" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if (time)
        [bodyDic setObject:time forKey:@"duration"];
    [bodyDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [bodyDic setObject:type forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    [bodyDic setObject:fileId forKey:@"fileId"];
    NSString * body = [bodyDic JSONString];
    ACKMessageDB *ack = [[ACKMessageDB alloc]init];
    
    [ack insertDB:[NSString stringWithFormat:@"%lld", milliseconds] withUserID:[handler getUserID] fromID:sendID withContent:body withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setObject:json forKey:sendID];
    NSString * jsonbody = [dict JSONString];
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:jsonbody withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
    [con sendFileMessage:sendID withFileId:fileId withMessage:body];

    if ([json objectForKey:@"audiodata"]) {
        NSBubbleData *bubble = [NSBubbleData dataWithtimes:time date:date type:BubbleTypeMine withData:data];
        if (myData)
            bubble.avatar = [UIImage imageWithData:myData];
        [bubbleData addObject:bubble];
    }
    if ([json objectForKey:@"photo"]) {
        NSBubbleData * bubble;
        if (time)
            bubble = [NSBubbleData dataWithImage:image withImageTime:time withPath:path date:date withType:BubbleTypeMine];
        else
            bubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine path:path];
        if (myData) {
            bubble.avatar = [UIImage imageWithData:myData];
        }
        [bubbleData addObject:bubble];

    }
    
}
@end
