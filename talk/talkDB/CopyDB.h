//
//  CopyDB.h
//  talk
//
//  Created by wangsh on 14-3-15.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface CopyDB : NSObject

-(void) initDB;

-(void)insertContent:(NSString *)content withTime:(NSString *)time;

-(NSString *)readContentCopyDB:(NSString *) time;

@end
