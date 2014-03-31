//
//  StatusDB.m
//  talk
//
//  Created by wangsh on 14-3-28.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "MyStatusDB.h"

@implementation MyStatusDB

-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"status.sqlite"];
    
}
-(void)initDB {
    
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS STATUSDB (ROW INTEGER PRIMARY KEY AUTOINCREMENT,USER TEXT,STATUS TEXT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }
    
    
}
-(void)insertStatus:(NSString *)status withUser:(NSString *)user{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    char *insert = "INSERT INTO STATUSDB (USER, STATUS) VALUES (?, ?);";
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, insert, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [status UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [user UTF8String], -1, NULL);
        
    }
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    sqlite3_close(database);
}

-(NSMutableArray *)readStatus:(NSString *)user{
    NSMutableArray *statusArray = [[NSMutableArray alloc]init];
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * sqlQuery = @"SELECT DISTINCT STATUS,USER FROM STATUSDB ORDER BY ROW DESC";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char * _user  = (char*)sqlite3_column_text(statement,0);
            NSString * username =[[NSString alloc]initWithUTF8String:_user];
            char * _status  = (char*)sqlite3_column_text(statement,1);
            NSString * status =[[NSString alloc]initWithUTF8String:_status];
            if ([user isEqualToString:username]) {
                [statusArray addObject:status];
            }
        }
    }
    return statusArray;
}

@end
