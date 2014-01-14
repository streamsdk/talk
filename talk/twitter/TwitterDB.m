//
//  TwitterDB.m
//  talk
//
//  Created by wangsh on 14-1-14.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "TwitterDB.h"

@implementation TwitterDB

-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"twitter.sqlite"];
    
}
-(void)initDB {
    
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS TWITTER (ROW INTEGER PRIMARY KEY AUTOINCREMENT, USERID TEXT, FROMID TEXT,CONTENT TEXT,TIME TEXT,ISMINE INT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }
    
}

-(void) insertDBUserID:(NSString *)userID fromID:(NSString *)fromID withContent:(NSString *)content withTime:(NSString *)time withIsMine:(int)isMine {
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    char *update = "INSERT INTO TWITTER (USERID, FROMID, CONTENT, TIME ,ISMINE) VALUES (?, ?, ?, ?, ?);";
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [userID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [fromID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [content UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [time UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 5, isMine);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_finalize(stmt);
    sqlite3_close(database);
    
    
}

@end
