//
//  SearchDB.m
//  talk
//
//  Created by wangsh on 13-12-27.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SearchDB.h"
#import "HandlerUserIdAndDateFormater.h"

@implementation SearchDB

-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"searchfriends.sqlite"];
    
}
-(void)initDB {
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS SEARCHFRIENDS (ROW INTEGER PRIMARY KEY AUTOINCREMENT, USERID TEXT, FRIENDID TEXT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }
    
}
-(void) insertDB:(NSString *)userID ewithFriendID:(NSString *)friendID{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    char *update = "INSERT INTO SEARCHFRIENDS (USERID, FRIENDID) VALUES (?, ?);";
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [userID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [friendID UTF8String], -1, NULL);
        
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_finalize(stmt);
    sqlite3_close(database);

}

-(NSMutableArray *) readDB:(NSString *)userID {
    
    NSMutableArray * searchArray = [[NSMutableArray alloc]init];
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT FRIENDID,USERID FROM ADDFRIENDS WHERE USERID = %@",userID];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char * id  = (char*)sqlite3_column_text(statement,0);
            NSString * _friendID =[[NSString alloc]initWithUTF8String:id];
            
            [searchArray addObject:_friendID];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return searchArray;

}
 @end
