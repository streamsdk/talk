//
//  CopyHandler.m
//  talk
//
//  Created by wangsh on 14-3-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "CopyPhotoHandler.h"
#import "ImageCache.h"
#import "HandlerUserIdAndDateFormater.h"
#import "TalkDB.h"
#import <arcstreamsdk/JSONKit.h>
#import "NSBubbleData.h"
#import "STreamXMPP.h"
#import "CopyDB.h"
@implementation CopyPhotoHandler


-(void) sendPhoto:(UIImage *)image withdate:(NSDate *)date forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withFileType:(NSString *)type{
    ImageCache * imagecache = [ImageCache sharedObject];
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    TalkDB *talk = [[TalkDB alloc]init];
    NSString * contents =[[UIPasteboard generalPasteboard] string];
    NSData *jsonData = [contents dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *chatDic = [decoder objectWithData:jsonData];
    NSString *fileId=[chatDic objectForKey:@"fileId"];
    NSString *path ;
    NSDate * nowdate =[NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if (fileId==nil) return;
    if ([type isEqualToString:@"photo"]) {
        path=[chatDic objectForKey:@"pboto"];
        NSBubbleData *bubble = [NSBubbleData dataWithImage:image date:nowdate type:BubbleTypeMine path:path];
        if (myData)
            bubble.avatar = [UIImage imageWithData:myData];
        [bubbleData addObject:bubble];
    }
    if ([type isEqualToString:@"video"]) {
        path = [chatDic objectForKey:@"filepath"];
        NSBubbleData * bdata = [NSBubbleData dataWithImage:image withTime:nil withType:@"video" date:date type:BubbleTypeMine withVidePath:path withJsonBody:@""];
        if (myData)
            bdata.avatar = [UIImage imageWithData:myData];
        [bubbleData addObject:bdata];

    }
    if ([type isEqualToString:@"voice"]) {
        path = [chatDic objectForKey:@"audiodata"];
        NSString * audiotime = [chatDic objectForKey:@"time"];
        [bodyDic setObject:audiotime forKey:@"duration"];
        NSData *data =[NSData dataWithContentsOfFile:path];
        NSBubbleData *bubble = [NSBubbleData dataWithtimes:audiotime date:date type:BubbleTypeSomeoneElse withData:data];
        if (myData)
            bubble.avatar = [UIImage imageWithData:myData];
        [bubbleData addObject:bubble];

    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:chatDic forKey:[imagecache getFriendID]];
    NSString *content = [dict JSONString];
    [talk insertDBUserID:[handler getUserID] fromID:[imagecache getFriendID] withContent:content withTime:[dateFormatter stringFromDate:nowdate] withIsMine:0];
    CopyDB *db = [[CopyDB alloc]init];
    [db insertContent:contents withTime:[dateFormatter stringFromDate:nowdate]];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    
    [bodyDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [bodyDic setObject:type forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    [bodyDic setObject:fileId forKey:@"fileId"];
    NSString *body =[bodyDic JSONString];
    STreamXMPP * con = [STreamXMPP sharedObject];
    [con sendFileMessage:[imagecache getFriendID] withFileId:fileId withMessage:body];
}

@end
