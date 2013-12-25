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
@implementation MessageHandler

- ( void)receiveMessage:(NSString *)receiveMessage forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
    if ([fromID isEqualToString:sendID]) {
        NSBubbleData *sendBubble = [NSBubbleData dataWithText:receiveMessage date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        if (otherData)
            sendBubble.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:sendBubble];
    }
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    TalkDB * db = [[TalkDB alloc]init];
    NSString * userID = [handler getUserID];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:receiveMessage forKey:@"messages"];
    [jsonDic setObject:friendDict forKey:fromID];
    NSString  *str = [jsonDic JSONString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date =[NSDate dateWithTimeIntervalSinceNow:0];
    NSString * str2 = [dateFormatter stringFromDate:date];
    [db insertDBUserID:userID fromID:fromID withContent:str withTime:str2 withIsMine:1];

}

-(void) sendMessage :(NSString *)messages forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
    NSBubbleData *sendBubble = [NSBubbleData dataWithText:messages date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    if (myData)
        sendBubble.avatar = [UIImage imageWithData:myData];
    [bubbleData addObject:sendBubble];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con sendMessage:sendID withMessage:messages];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:messages forKey:@"messages"];
    [jsonDic setObject:friendDict forKey:sendID];
    NSString  *str = [jsonDic JSONString];
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
}
@end
