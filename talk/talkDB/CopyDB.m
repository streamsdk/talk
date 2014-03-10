//
//  CopyDB.m
//  talk
//
//  Created by wangsh on 14-3-10.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "CopyDB.h"

@implementation CopyDB

-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"copy.sqlite"];
    
}
-(void)initDB {
    
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS COPYDB (CONTENT TEXT,TIME TEXT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }
    
}

-(void)insertContent:(NSString *)content withTime:(NSString *)time{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    char *update = "INSERT INTO COPYDB (CONTENT, TIME) VALUES (?, ?);";
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [content UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [time UTF8String], -1, NULL);

    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_finalize(stmt);
    sqlite3_close(database);

}

-(NSString *)readContentCopyDB:(NSString *) time{
    NSString *content = nil;
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * sqlQuery = [NSString stringWithFormat:@"SELECT CONTENT FROM COPYDB WHERE TIME='%@'",time];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char * _content  = (char*)sqlite3_column_text(statement,0);
            NSString * contents =[[NSString alloc]initWithUTF8String:_content];
            content = contents;
//             NSLog(@"copy = %@",time);
//            NSLog(@"content = %@",contents);
        }
    }
    return content;

}
@end
