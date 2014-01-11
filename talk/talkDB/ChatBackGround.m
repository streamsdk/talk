//
//  ChatBackGround.m
//  talk
//
//  Created by wangsh on 14-1-11.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "ChatBackGround.h"

@implementation ChatBackGround

-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"chatBackGround.sqlite"];
    
}
-(void)initDB {
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS ChatBackGround (ROW INTEGER PRIMARY KEY AUTOINCREMENT, USERID TEXT, FRIENDID TEXT,PATH TEXT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }
    
}
-(NSString *) readChatBackGround:(NSString *)userID withFriendID:(NSString *)friendID{
    NSString * path;
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT FRIENDID,PATH FROM ChatBackGround WHERE USERID='%@' and FRIENDID='%@'",userID,friendID];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
            char * id  = (char*)sqlite3_column_text(statement,0);
            NSString *_path = [[NSString alloc]initWithUTF8String:id];
        path = _path;
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);

    return path;
}

-(void) updateDB:(NSString *)userID withFriendID:(NSString *)friendID withImagePth:(NSString *)path{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * update = [NSString stringWithFormat:@"UPDATE ChatBackGround SET PATH='%@' WHERE USERID='%@' AND FRIENDID='%@'",path,userID,friendID];
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [update UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        
        sqlite3_bind_text(stmt, 1, [path UTF8String], -1, NULL);
        
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    sqlite3_close(database);

    
}
@end
