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

@synthesize delegate;
- ( void)receiveMessage:(NSString *)receiveMessage forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];

    if ([fromID isEqualToString:sendID]) {
        NSBubbleData *sendBubble = [NSBubbleData dataWithText:receiveMessage date:[handler getDate] type:BubbleTypeSomeoneElse];
        if (otherData)
            sendBubble.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:sendBubble];
    }

}

-(void) sendMessage :(NSString *)messages forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    NSDate *date = [handler getDate];
    NSBubbleData *sendBubble = [NSBubbleData dataWithText:messages date:date type:BubbleTypeMine];
    if (myData)
        sendBubble.avatar = [UIImage imageWithData:myData];
    [bubbleData addObject:sendBubble];
  
    
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
    
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    
    [delegate reloadTableCell];
     [con sendMessage:sendID withMessage:messageSent];
    
   
}

@end
