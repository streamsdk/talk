//
//  StatusDB.h
//  talk
//
//  Created by wangsh on 14-3-28.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface StatusDB : NSObject

-(void) initDB;

-(void)insertStatus:(NSString *)status withUser:(NSString *)user;

-(NSMutableArray *)readStatus:(NSString *)user;

@end
