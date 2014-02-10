//
//  ACKMessageDB.m
//  talk
//
//  Created by wangsh on 14-2-6.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "ACKMessageDB.h"

@implementation ACKMessageDB

-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"ack.sqlite"];
    
}
-(void)initDB {
    
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS ACK (ROW INTEGER PRIMARY KEY AUTOINCREMENT, ID TEXT, USERID TEXT, FROMID TEXT,CONTENT TEXT,TIME TEXT,ISMINE INT);";
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }
    
}
-(void)insertDB:(NSString *)id withUserID:(NSString *)userID fromID:(NSString *)fromID withContent:(NSString *)content withTime:(NSString *)time withIsMine: (int)isMine{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    char *update = "INSERT INTO ACK (ID, USERID, FROMID, CONTENT, TIME ,ISMINE) VALUES (?, ?, ?, ?, ?, ?);";
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [id UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [userID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [fromID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [content UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [time UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 6, isMine);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_finalize(stmt);
    sqlite3_close(database);

}
-(NSMutableArray *) readDb{
    NSMutableArray *ackArray = [[NSMutableArray alloc]init];
    sqlite3 *database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *sqlQuery = @"SELECT CONTENT, FROMID FROM ACK";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *_content = (char*)sqlite3_column_text(statement,0);
            char *_friendId = (char*)sqlite3_column_text(statement,1);
            NSString * friendId = [[NSString alloc]initWithUTF8String:_friendId];
            NSString * json = [[NSString alloc]initWithUTF8String:_content];
            NSMutableString *string = [[NSMutableString alloc]init];
            [string appendString:friendId];
            [string appendString:@"~∞§"];
            [string appendString:json];
            
            [ackArray addObject:string];
            
           /* NSArray * array = [string componentsSeparatedByString:@"~∞§"];
            NSString *id = [array objectAtIndex:0];
            NSMutableString *  s= [[NSMutableString alloc]init];
            [s appendString:id];
            [s appendString:@"messaginghistory"];*/
        }
    }
    return  ackArray;
}
-(void) deleteDB:(NSString *) id{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //    select distinct * from ADDFRIENDS
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM ACK WHERE ID='%@'",id];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        NSLog(@"delete");
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);

}
-(void) deleteDB {
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //    select distinct * from ADDFRIENDS
    NSString * sql =@"DELETE FROM ACk";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        NSLog(@"delete");
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);

}
@end
