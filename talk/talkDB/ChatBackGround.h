//
//  ChatBackGround.h
//  talk
//
//  Created by wangsh on 14-1-11.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface ChatBackGround : NSObject

-(void) initDB;

-(void)insertDB:(NSString *)userID withFriendID:(NSString *)friendID withImagePth:(NSString *)path;

-(NSString *) readChatBackGround:(NSString *)userID withFriendID:(NSString *)friendID;

-(void) updateDB:(NSString *)userID withFriendID:(NSString *)friendID withImagePth:(NSString *)path;

-(void) deleteDB:(NSString *)userID withFriendID:(NSString *)friendID;
@end
