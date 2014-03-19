//
//  TalkDB.h
//  talk
//
//  Created by wangsh on 13-11-7.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "NSBubbleData.h"


@interface TalkDB : NSObject

-(void) initDB;

-(void)insertDBUserID:(NSString *)userID fromID:(NSString *)fromID withContent:(NSString *)content withTime:(NSString *)time withIsMine: (int)isMine;

-(NSMutableArray *) readInitDB :(NSString *) _userID withOtherID:(NSString *)_friendID withCount:(int)count;

-(void) updateDB:(NSDate*)date withContent:(NSString *)content;

-(void) deleteDB :(NSString *) _userID withOtherID:(NSString *)_friendID;

-(void) deleteDB :(NSString *)time;

-(NSString *) readDB:(NSDate *)date;

-(NSInteger)allDataCount:(NSString *) _userID withOtherID:(NSString *)_friendID;
@end
