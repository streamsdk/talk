//
//  TalkDB.m
//  talk
//
//  Created by wangsh on 13-11-7.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "TalkDB.h"
#import "NSBubbleData.h"
#import "ImageCache.h"

@implementation TalkDB

-(NSString *) dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"talk.sqlite"];
    
}
-(void)initDB {
    
    sqlite3 * database ;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS FILEID (ROW INTEGER PRIMARY KEY AUTOINCREMENT, USERID TEXT, FROMID TEXT,CONTENT TEXT,TIME TEXT,ISMINE INT);";
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
    
    char *update = "INSERT INTO FILEID (USERID, FROMID, CONTENT, TIME ,ISMINE) VALUES (?, ?, ?, ?, ?);";
    
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

-(NSMutableArray *) readInitDB :(NSString *) fromID withOtherID:(NSString *)otherID{
    
    ImageCache * imageCache =  [ImageCache sharedObject];
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:otherID];
    NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
    NSData* myData = [imageCache getImage:pImageId];
    
    NSMutableDictionary *metaData = [imageCache getUserMetadata:fromID];
    NSString *pImageId2 = [metaData objectForKey:@"profileImageId"];
    NSData *otherData = [imageCache getImage:pImageId2];

    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    sqlite3 *database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *sqlQuery = @"SELECT * FROM FILEID";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *userId = (char*)sqlite3_column_text(statement, 1);
            char *fromId =(char*) sqlite3_column_text(statement, 2);
            char *_content = (char*)sqlite3_column_text(statement, 3);
            char *time1  = (char*)sqlite3_column_text(statement, 4);
            int ismine = sqlite3_column_int(statement, 5);
            
            NSString * userID = [[NSString alloc]initWithUTF8String:userId];
            NSString *_fromID = [[NSString alloc]initWithUTF8String:fromId];
            NSString *content  = [[NSString alloc]initWithUTF8String:_content];
            
            NSString * time2 =[[NSString alloc]initWithUTF8String:time1];
             NSString *nameFilePath = [self getCacheDirectory];
            NSArray *array = [[NSArray alloc]initWithContentsOfFile:nameFilePath];
            NSString * _uesrID = nil;
            if (array && [array count]!= 0) {
                _uesrID = [array objectAtIndex:0];
            }
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            NSDate *date = [dateFormatter dateFromString:time2];
            if (([_uesrID isEqualToString:userID] && [_fromID isEqualToString:fromID])||([_uesrID isEqualToString:_fromID] && [fromID isEqualToString:userID])) {
                if (ismine == 0) {
                    NSBubbleData * data = [[NSBubbleData alloc]initWithText:content date:date type:BubbleTypeMine];
                    if(myData)
                        data.avatar = [UIImage imageWithData:myData];
                    [dataArray addObject:data];
                }else {
                     NSBubbleData * data = [[NSBubbleData alloc]initWithText:content date:date type:BubbleTypeSomeoneElse];
                    if(otherID)
                        data.avatar = [UIImage imageWithData:otherData];
                    [dataArray addObject:data];
                }
            }
            
            
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);

    
    return dataArray;
}
-(NSString*)getCacheDirectory
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
}



@end
