//
//  SearchDB.h
//  talk
//
//  Created by wangsh on 13-12-27.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SearchDB : NSObject

-(void) initDB;

-(void)insertDB:(NSString *)userID withFriendID:(NSString *)friendID;

-(NSMutableArray *) readSearchDB:(NSString *)userID;

@end
