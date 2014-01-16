//
//  AddDB.h
//  talk
//
//  Created by wangsh on 13-12-27.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface AddDB : NSObject

-(void) initDB;

-(void)insertDB:(NSString *)userID withFriendID:(NSString *)friendID withStatus:(NSString *)status;

-(NSMutableDictionary *) readDB:(NSString *)userID;

-(void) deleteDB:(NSString * )friendID;

-(void) deleteDB;

-(void) updateDB:(NSString *)userID withFriendID:(NSString *)friendID withStatus:(NSString *)status;

@end
