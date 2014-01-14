//
//  TwitterDB.h
//  talk
//
//  Created by wangsh on 14-1-14.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface TwitterDB : NSObject

-(void) initDB;

-(void)insertDBUserID:(NSString *)userID fromID:(NSString *)fromID withContent:(NSString *)content withTime:(NSString *)time withIsMine:(int)isMine;

@end
