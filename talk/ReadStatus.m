//
//  ReadStatus.m
//  talk
//
//  Created by wangsh on 14-4-3.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "ReadStatus.h"
#import "HandlerUserIdAndDateFormater.h"
#import "FriendStatusDB.h"
#import <arcstreamsdk/STreamObject.h>
#import "ImageCache.h"
@implementation ReadStatus

-(NSMutableDictionary *) getFriendStatus{
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSMutableDictionary *statusDict = [[NSMutableDictionary alloc]init];
    FriendStatusDB * friendStatusDB = [[FriendStatusDB alloc]init];
    statusDict = [friendStatusDB readStatus:[handle getUserID]];
    if ([statusDict count]==0) statusDict = [friendStatusDB readStatus:[handle getUserID]];
    return statusDict;
}
-(void)readFriendsStatus:(NSString *)friend{
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    FriendStatusDB * friendStatusDB = [[FriendStatusDB alloc]init];
    ImageCache * imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata=[imageCache getUserMetadata:friend];
    NSString *status =[userMetadata objectForKey:@"status"];
    if (status==nil || [status isEqualToString:@""]) {
        status = @"Hey,there! I am using CoolChat!";
    }
    NSString * name = [friendStatusDB readfriend:friend];
    if ([name isEqualToString:[handle getUserID]]) {
        [friendStatusDB updateDB:[handle getUserID] withFriendID:friend withStatus:status];
    }else{
        [friendStatusDB insertStatus:[handle getUserID] friend:friend status:status];
    }
//    return status;
}
@end
