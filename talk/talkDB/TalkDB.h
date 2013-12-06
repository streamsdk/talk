//
//  TalkDB.h
//  talk
//
//  Created by wangsh on 13-11-7.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface TalkDB : NSObject


-(void) initDB;

-(void)insertDBUserID:(NSString *)userID fromID:(NSString *)fromID withContent:(NSString *)content withTime:(NSString *)time withIsMine: (int)isMine;

-(NSMutableArray *) readInitDB : (NSString *)fromID  withOtherID:(NSString *)otherID;
@end
