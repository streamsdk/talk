//
//  DownloadDB.h
//  talk
//
//  Created by wangsh on 14-2-14.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface DownloadDB : NSObject

-(void) initDB;

-(void) insertDownloadDB:(NSString *)userId fileID:(NSString *)fileId withBody:(NSString *)body withFrom:(NSString *)fromID withTime:(NSString *)time;

-(NSMutableArray *) readDownloadDB;

-(void) deleteDownloadDBFromFileID:(NSString *) fileID;

-(NSString *)readDownloadDBFromFileID:(NSString *) fileID;

-(void) deleteDownloadDBFileID:(NSString *) time;

-(NSString *)readDownloadDBFileID:(NSString *) time;
@end
