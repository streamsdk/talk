//
//  FriendStatusDB.m
//  talk
//
//  Created by wangsh on 14-3-31.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "FriendStatusDB.h"

@implementation FriendStatusDB

-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"friendStatus.sqlite"];
    
}
-(void)initDB {
    
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS FRIENDSTATUS (USER TEXT,FRIEND TEXT,STATUS TEXT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }
    
    
}


-(void)insertStatus:(NSString *)user friend:(NSString *)friend status:(NSString *)status{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    char *insert = "INSERT INTO FRIENDSTATUS (USER, FRIEND, STATUS) VALUES (?, ?, ?);";
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, insert, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [user UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [friend UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [status UTF8String], -1, NULL);
    }
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    sqlite3_close(database);

}

-(NSMutableDictionary *)readStatus:(NSString *)user{
    NSMutableDictionary *statusDict = [[NSMutableDictionary alloc]init];
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * sqlQuery = [NSString stringWithFormat:@"SELECT FRIEND, STATUS FROM FRIENDSTATUS WHERE USER='%@'",user];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char * _friend  = (char*)sqlite3_column_text(statement,0);
            NSString * friendname =[[NSString alloc]initWithUTF8String:_friend];
            char * _status  = (char*)sqlite3_column_text(statement,1);
            NSString * status =[[NSString alloc]initWithUTF8String:_status];
            [statusDict setObject:status forKey:friendname];
        }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return statusDict;
}

-(NSString *)readfriend:(NSString *)user{
    NSString *friendName = nil;
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * sqlQuery = [NSString stringWithFormat:@"SELECT FRIEND FROM FRIENDSTATUS WHERE USER='%@'",user];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char * _friend  = (char*)sqlite3_column_text(statement,0);
            NSString * friend =[[NSString alloc]initWithUTF8String:_friend];
            friendName = friend;
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return friendName;

}
-(void) updateDB:(NSString *)userID withFriendID:(NSString *)friendID withStatus:(NSString *)status {
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * update = [NSString stringWithFormat:@"UPDATE FRIENDSTATUS SET STATUS='%@' WHERE USERID='%@' AND FRIENDID='%@'",status,userID,friendID];
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [update UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        
        sqlite3_bind_text(stmt, 1, [status UTF8String], -1, NULL);
        
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    sqlite3_close(database);
    
}

@end
