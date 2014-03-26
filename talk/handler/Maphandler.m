//
//  Maphandler.m
//  talk
//
//  Created by wangsh on 14-3-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "Maphandler.h"
#import <arcstreamsdk/JSONKit.h>
#import "TalkDB.h"
#import "NSBubbleData.h"
#import "STreamXMPP.h"
#import "HandlerUserIdAndDateFormater.h"
#import "ACKMessageDB.h"
#import "ImageCache.h"


@implementation Maphandler
- (void)receiveAddress:(NSString *)receiveAddress latitude:(float)latitude longitude:(float)longitude withImage:(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    if ([fromID isEqualToString:sendID]) {
        NSBubbleData *sendBubble = [NSBubbleData dataWithAddress:receiveAddress latitude:latitude longitude:longitude withImage:image date:[handler getDate] type:BubbleTypeSomeoneElse];
        if (otherData)
            sendBubble.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:sendBubble];
    }

}

-(void) sendAddress :(NSString *)address latitude:(float)latitude longitude:(float)longitude withImage:(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID{
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString *photoPath = [[handler getPath] stringByAppendingString:@".png"];
    [data  writeToFile:photoPath atomically:YES];
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSBubbleData *sendBubble = [NSBubbleData dataWithAddress:address latitude:latitude longitude:longitude withImage:image date:date type:BubbleTypeMine];
    if (myData)
        sendBubble.avatar = [UIImage imageWithData:myData];
    [bubbleData addObject:sendBubble];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    
    //new message format
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSMutableDictionary *messagesDic = [[NSMutableDictionary alloc] init];
    [messagesDic setObject:address forKey:@"address"];
    [messagesDic setObject:[NSString stringWithFormat:@"%f",latitude] forKey:@"latitude"];
    [messagesDic setObject:[NSString stringWithFormat:@"%f",longitude]  forKey:@"longitude"];
    [messagesDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [messagesDic setObject:@"map" forKey:@"type"];
    [messagesDic setObject:[handler getUserID] forKey:@"from"];
    
    ImageCache *cache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata = [cache getUserMetadata:sendID];
    if (userMetadata && [userMetadata objectForKey:@"token"]){
        [messagesDic setObject:[userMetadata objectForKey:@"token"] forKey:@"token"];
    }
    
    
    NSString *messageSent = [messagesDic JSONString];
    NSMutableDictionary * addressDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [addressDict setObject:address forKey:@"address"];
    [addressDict setObject:photoPath forKey:@"path"];
    [addressDict setObject:[NSString stringWithFormat:@"%f",latitude] forKey:@"latitude"];
    [addressDict setObject:[NSString stringWithFormat:@"%f",longitude]  forKey:@"longitude"];
    [friendDict setObject:addressDict forKey:@"address"];
    [jsonDic setObject:friendDict forKey:sendID];
    NSString  *str = [jsonDic JSONString];
    
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    ACKMessageDB *ack = [[ACKMessageDB alloc]init];
    [ack insertDB:[NSString stringWithFormat:@"%lld", milliseconds] withUserID:[handler getUserID] fromID:sendID withContent:messageSent withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    [con sendMessage:sendID withMessage:messageSent];
}

@end
