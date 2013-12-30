//
//  AddDB.m
//  talk
//
//  Created by wangsh on 13-12-27.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "AddDB.h"
#import "HandlerUserIdAndDateFormater.h"
@implementation AddDB


-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"addfriends.sqlite"];
    
}
-(void)initDB {
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS ADDFRIENDS (ROW INTEGER PRIMARY KEY AUTOINCREMENT, USERID TEXT, FRIENDID TEXT,STATUS TEXT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }

}
-(void)insertDB:(NSString *)userID withFriendID:(NSString *)friendID withStatus:(NSString *)status {
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    char *update = "INSERT INTO ADDFRIENDS (USERID, FRIENDID, STATUS) VALUES (?, ?, ?);";
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [userID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [friendID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [status UTF8String], -1, NULL);
       
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_finalize(stmt);
    sqlite3_close(database);

}
//NSString *sqlQuery = [NSString stringWithFormat:@"SELECT TIME,USERID FROM FILEID WHERE USERID = %@",friendId];
-(NSMutableDictionary *) readDB:(NSString *)userID {
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT FRIENDID,STATUS,USERID FROM ADDFRIENDS WHERE USERID='%@'",userID];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char * id  = (char*)sqlite3_column_text(statement,0);
            char * sta = (char *)sqlite3_column_text(statement, 1);
            NSString * _friendID =[[NSString alloc]initWithUTF8String:id];
            NSString *_status = [[NSString alloc]initWithUTF8String:sta];
            [addDict setObject:_status forKey:_friendID];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return addDict;

}
-(void) deleteDB {
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
//    select distinct * from ADDFRIENDS
    NSString * sql =@"DELETE FROM ADDFRIENDS";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
       
        NSLog(@"delete");
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
}

//
-(void) updateDB:(NSString *)userID withFriendID:(NSString *)friendID withStatus:(NSString *)status {
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * update = [NSString stringWithFormat:@"UPDATE ADDFRIENDS SET STATUS='%@' WHERE USERID='%@' AND FRIENDID='%@'",status,userID,friendID];
    
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
