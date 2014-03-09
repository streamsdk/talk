//
//  CopyHandler.m
//  talk
//
//  Created by wangsh on 14-3-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "CopyHandler.h"
#import "ImageCache.h"
#import "HandlerUserIdAndDateFormater.h"
#import "TalkDB.h"
#import <arcstreamsdk/JSONKit.h>
#import "NSBubbleData.h"
#import "STreamXMPP.h"

@implementation CopyHandler


-(void) sendPhoto:(UIImage *)image withdate:(NSDate *)date forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData{
    ImageCache * imagecache = [ImageCache sharedObject];
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    TalkDB * talk = [[TalkDB alloc]init];
    NSString * contents =[talk readDB:date];
    NSDictionary *ret = [contents objectFromJSONString];
    NSDictionary * chatDic = [ret objectForKey:[imagecache getFriendID]];
    NSString *fileId=[chatDic objectForKey:@"fileId"];
    NSString *path =[chatDic objectForKey:@"photo"];
    NSDate * nowdate =[NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];;
    if (fileId==nil) return;
    NSBubbleData *bubble = [NSBubbleData dataWithImage:image date:nowdate type:BubbleTypeMine path:path];
    if (myData) {
        bubble.avatar = [UIImage imageWithData:myData];
    }
    [bubbleData addObject:bubble];
    NSString * time = [dateFormatter stringFromDate:nowdate];
    [talk insertDBUserID:[handler getUserID] fromID:[imagecache getFriendID] withContent:contents withTime:[dateFormatter stringFromDate:nowdate] withIsMine:0];
    
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [bodyDic setObject:@"photo" forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    [bodyDic setObject:fileId forKey:@"fileId"];
    NSString *body =[bodyDic JSONString];
    STreamXMPP * con = [STreamXMPP sharedObject];
    [con sendFileMessage:[imagecache getFriendID] withFileId:fileId withMessage:body];
}
@end
