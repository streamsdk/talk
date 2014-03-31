//
//  FriendStatusDB.h
//  talk
//
//  Created by wangsh on 14-3-31.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface FriendStatusDB : NSObject

-(void) initDB;

-(void)insertStatus:(NSString *)user friend:(NSString *)friend status:(NSString*)status;

-(NSMutableDictionary *)readStatus:(NSString *)user;

-(NSString *)readfriend:(NSString *)user;

-(void) updateDB:(NSString *)userID withFriendID:(NSString *)friendID withStatus:(NSString *)status;
@end
