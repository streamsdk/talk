//
//  ReadStatus.h
//  talk
//
//  Created by wangsh on 14-4-3.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadStatus : NSObject

-(NSMutableDictionary *) getFriendStatus;

-(void)readFriendsStatus:(NSString *)friend;

@end
