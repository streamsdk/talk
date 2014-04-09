//
//  TalkDB.m
//  talk
//
//  Created by wangsh on 13-11-7.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "TalkDB.h"
#import "UIImageViewController.h"
#import "ImageCache.h"
#import <arcstreamsdk/JSONKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CopyDB.h"
#import <arcstreamsdk/STreamFile.h>
#import "HandlerUserIdAndDateFormater.h"
#import "DownloadVoice.h"
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
-(void)readAvatar:(NSString *)user withFriend:(NSString *)friend{
    ImageCache * imageCache =  [ImageCache sharedObject];
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:user];
    NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
    myData = [imageCache getImage:pImageId];
    
    NSMutableDictionary *metaData = [imageCache getUserMetadata:friend];
    NSString *pImageId2 = [metaData objectForKey:@"profileImageId"];
    otherData = [imageCache getImage:pImageId2];
}
-(NSMutableArray *) readInitDB :(NSString *) _userID withOtherID:(NSString *)_friendID withCount:(int)count{
    DownloadVoice * download = [[DownloadVoice alloc]init];
    fileCount = 0;
    readCount = 0;
    ImageCache * imageCache =  [ImageCache sharedObject];
    [self readAvatar:_userID withFriend:_friendID];

    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    sqlite3 *database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
   /* sqlite3_stmt * st;
    NSString * str =@"select count(*) from FILEID";
    if (sqlite3_prepare_v2(database, [str UTF8String], -1, &st, nil) == SQLITE_OK) {
        
        NSLog(@"");
    }
    NSString * sqlQuery =@"SELECT * FROM FILEID ORDER BY TIME DESC LIMIT 10 OFFSET 10";*/
//    NSString * sqlQuery = [NSString stringWithFormat:@"SELECT * FROM FILEID WHERE USERID='%@' and FROMID='%@' ORDER BY TIME DESC LIMIT %d OFFSET 0",_userID,_friendID,count];
    NSString *sqlQuery = @"SELECT * FROM FILEID ORDER BY TIME DESC";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *userId = (char*)sqlite3_column_text(statement, 1);
            char *friendId =(char*) sqlite3_column_text(statement, 2);
            char *_content = (char*)sqlite3_column_text(statement, 3);
            char *time1  = (char*)sqlite3_column_text(statement, 4);
            int ismine = sqlite3_column_int(statement, 5);
            
            NSString * userID = [[NSString alloc]initWithUTF8String:userId];
            NSString *friendID = [[NSString alloc]initWithUTF8String:friendId];
            NSString *jsonstring = [[NSString alloc]initWithUTF8String:_content];
            NSString * time2 =[[NSString alloc]initWithUTF8String:time1];
            NSDictionary *ret = [jsonstring objectFromJSONString];
            NSDictionary * chatDic = [ret objectForKey:friendID];
        
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSDate *date = [dateFormatter dateFromString:time2];
            if ([userID isEqualToString:_userID] && [friendID isEqualToString:_friendID]) {
                readCount=readCount+1;
                if (ismine == 0) {
                    NSArray * keys = [chatDic allKeys];
                    for (NSString * key in keys) {
                        if ([key isEqualToString:@"messages"]) {
                            NSBubbleData * data = [[NSBubbleData alloc]initWithText:[chatDic objectForKey:@"messages"] date:date type:BubbleTypeMine];
                            if(myData)
                                data.avatar = [UIImage imageWithData:myData];
                            [dataArray addObject:data];
                        }else if ([key isEqualToString:@"filepath"]) {
                            NSString * time = [chatDic objectForKey:@"duration"];
                            UIImage *fileImage = [self getVideoImage:[chatDic objectForKey:@"filepath"]];
                            NSBubbleData *bdata = [NSBubbleData dataWithImage:fileImage withTime:time withType:@"video" date:date type:BubbleTypeMine withVidePath:[chatDic objectForKey:@"filepath"] withJsonBody:@""];
                            if(myData)
                                bdata.avatar = [UIImage imageWithData:myData];
                            [dataArray addObject:bdata];
                            fileCount = fileCount+1;
                           
                        }else if ([key isEqualToString:@"photo"]) {
                            NSData * data =[NSData dataWithContentsOfFile:[chatDic objectForKey:@"photo"]];
                            NSString * time = [chatDic objectForKey:@"time"];
                            NSBubbleData * bubbledata;
                            if (!time)
                                bubbledata = [NSBubbleData dataWithImage:[UIImage imageWithData:data] date:date type:BubbleTypeMine path:[chatDic objectForKey:@"photo"]];
                            else
                                bubbledata = [NSBubbleData dataWithImage:[UIImage imageWithData:data] withImageTime:time withPath:[chatDic objectForKey:@"photo"]date:date withType:BubbleTypeMine];;
                            if(myData)
                                bubbledata.avatar = [UIImage imageWithData:myData];
                            [dataArray addObject:bubbledata];
                            fileCount = fileCount+1;
                            
                        }else if ([key isEqualToString:@"audiodata"]){
                            NSError * err = nil;
                            NSString * time = [chatDic objectForKey:@"time"];
                            NSString * dataPath = [chatDic objectForKey:@"audiodata"];
                            NSData * audioData = [NSData dataWithContentsOfFile:dataPath options: 0 error:&err];
                            NSBubbleData *bubble = [NSBubbleData dataWithtimes:time date:date type:BubbleTypeMine withData:audioData];
                            NSFileManager * fileManager = [NSFileManager defaultManager];
                            NSArray * array = [[NSArray alloc]initWithObjects:[chatDic objectForKey:@"fileId"],[chatDic objectForKey:@"audiodata"],bubble, nil];
                            if (![fileManager fileExistsAtPath:dataPath]) {
                                [download performSelectorInBackground:@selector(downloadVoice:) withObject:array];
                            }
                            if (myData)
                                bubble.avatar = [UIImage imageWithData:myData];
                            [dataArray addObject:bubble];
                            fileCount = fileCount+1;
                            
                        }else if ([key isEqualToString:@"address"]){
                            NSMutableDictionary * addressDict = [chatDic objectForKey:@"address"];
                            NSString * address = [addressDict objectForKey:@"address"];
                            NSString * latitude = [addressDict objectForKey:@"latitude"];
                            NSString * longitude = [addressDict objectForKey:@"longitude"];
                            NSString *path = [addressDict objectForKey:@"path"];
                            UIImage *image = [UIImage imageWithContentsOfFile:path];
                            NSBubbleData *bubble = [NSBubbleData dataWithAddress:address latitude:[latitude floatValue] longitude:[longitude floatValue] withImage:image date:date type:BubbleTypeMine path:path];
                            if (myData)
                                bubble.avatar = [UIImage imageWithData:myData];
                            [dataArray addObject:bubble];
                            fileCount = fileCount+1;
                        }

                    }
                   
                }else if(ismine == 1){
                    NSArray * keys = [chatDic allKeys];
                    for (NSString * key in keys) {
                        if ([key isEqualToString:@"messages"]) {
                            NSBubbleData * data = [[NSBubbleData alloc]initWithText:[chatDic objectForKey:@"messages"] date:date type:BubbleTypeSomeoneElse];
                            if(otherData)
                                data.avatar = [UIImage imageWithData:otherData];
                            [dataArray addObject:data];
                        }else if ([key isEqualToString:@"tidpath"]) {
//                            NSURL *url = [NSURL fileURLWithPath:[chatDic objectForKey:@"video"]];
//                            MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url];
//                            player.shouldAutoplay = NO;
//                            UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
                            NSData * data =[NSData dataWithContentsOfFile:[chatDic objectForKey:@"tidpath"]];;
                            UIImage *fileImage = [UIImage imageWithData:data];
                            NSString * time = [chatDic objectForKey:@"duration"];
                            NSString * body = [chatDic JSONString];
                            NSBubbleData *bdata = [NSBubbleData dataWithImage:fileImage withTime:time  withType:@"video" date:date type:BubbleTypeSomeoneElse withVidePath:[chatDic objectForKey:@"tidpath"] withJsonBody:body];
                            if(otherData)
                                bdata.avatar = [UIImage imageWithData:otherData];
                            [dataArray addObject:bdata];
                            fileCount = fileCount+1;
                            

                          }if ([key isEqualToString:@"filepath"]) {
                            /*NSURL *url = [NSURL fileURLWithPath:[chatDic objectForKey:@"filepath"]];
                            MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url];
                            player.shouldAutoplay = NO;
                            UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];*/
//                            NSData * data =[NSData dataWithContentsOfFile:[chatDic objectForKey:@"filepath"]];;
//                            UIImage *fileImage = [UIImage imageWithData:data];
                              UIImage *fileImage = [self getVideoImage:[chatDic objectForKey:@"filepath"]];
                              NSString * time = [chatDic objectForKey:@"duration"];
                              NSString * body = [chatDic JSONString];
                              NSBubbleData *bdata = [NSBubbleData dataWithImage:fileImage withTime:time  withType:@"video" date:date type:BubbleTypeSomeoneElse withVidePath:[chatDic objectForKey:@"filepath"] withJsonBody:body];
                              if(otherData)
                                  bdata.avatar = [UIImage imageWithData:otherData];
                              [dataArray addObject:bdata];
                              fileCount = fileCount+1;
                            
                        }else if ([key isEqualToString:@"photo"]) {
                            NSData * data =[NSData dataWithContentsOfFile:[chatDic objectForKey:@"photo"]];
                            NSString * time = [chatDic objectForKey:@"time"];
                            NSBubbleData * bubbledata;
                            if (!time)
                                bubbledata = [NSBubbleData dataWithImage:[UIImage imageWithData:data] date:date type:BubbleTypeSomeoneElse path:[chatDic objectForKey:@"photo"]];
                            else
                                bubbledata = [NSBubbleData dataWithImage:[UIImage imageWithData:data] withImageTime:time withPath:[chatDic objectForKey:@"photo"] date:date withType:BubbleTypeSomeoneElse];
                            if(otherData)
                                bubbledata.avatar = [UIImage imageWithData:otherData];
                            [dataArray addObject:bubbledata];
                            fileCount = fileCount+1;
                            
                        }else if ([key isEqualToString:@"audiodata"]) {
                            NSError * err = nil;
                            NSString * time = [chatDic objectForKey:@"time"];
                            NSString * dataPath = [chatDic objectForKey:@"audiodata"];
                            NSFileManager * fileManager = [NSFileManager defaultManager];
                            NSData * audioData = [NSData dataWithContentsOfFile:dataPath options: 0 error:&err];
                            NSBubbleData *bubble = [NSBubbleData dataWithtimes:time date:date type:BubbleTypeSomeoneElse withData:audioData];
                            NSArray * array = [[NSArray alloc]initWithObjects:[chatDic objectForKey:@"fileId"],[chatDic objectForKey:@"audiodata"],bubble, nil];
                            if (![fileManager fileExistsAtPath:dataPath]) {
                                [download performSelectorInBackground:@selector(downloadVoice:) withObject:array];
                            }
                            if (otherData)
                                bubble.avatar = [UIImage imageWithData:otherData];
                            [dataArray addObject:bubble];
                            fileCount = fileCount+1;
                            
                            break;
                        }else if ([key isEqualToString:@"address"]){
                            NSMutableDictionary * addressDict = [chatDic objectForKey:@"address"];
                            NSString * address = [addressDict objectForKey:@"address"];
                            NSString * latitude = [addressDict objectForKey:@"latitude"];
                            NSString * longitude = [addressDict objectForKey:@"longitude"];
                            NSString *path = [addressDict objectForKey:@"path"];
                            UIImage *image = [UIImage imageWithContentsOfFile:path];
                            NSBubbleData *bubble = [NSBubbleData dataWithAddress:address latitude:[latitude floatValue] longitude:[longitude floatValue] withImage:image date:date type:BubbleTypeSomeoneElse path:path];
                            if (otherData)
                                bubble.avatar = [UIImage imageWithData:otherData];
                            [dataArray addObject:bubble];
                            fileCount = fileCount+1;
                        }
                        
                
                    }
                }
            }
            if (fileCount==count) {
                [imageCache saveRaedAllCount:[NSNumber numberWithInt:readCount] withuserID:_friendID];
                sqlite3_finalize(statement);
                sqlite3_close(database);
                return dataArray;
            }
        }
            
    }
    [imageCache saveRaedAllCount:[NSNumber numberWithInt:readCount] withuserID:_friendID];
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return dataArray;
}
-(void) updateDB:(NSDate*)date withContent:(NSString *)content{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString * time = [dateFormatter stringFromDate:date];
    NSString * update = [NSString stringWithFormat:@"UPDATE FILEID SET CONTENT='%@' WHERE TIME='%@'",content,time];
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [update UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        
        sqlite3_bind_text(stmt, 1, [content UTF8String], -1, NULL);
        
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    sqlite3_close(database);
}

-(void) deleteDB :(NSString *) _userID withOtherID:(NSString *)_friendID{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * delete = [NSString stringWithFormat:@"DELETE FROM FILEID  WHERE USERID='%@' and FROMID='%@'",_userID,_friendID];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [delete UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSLog(@"");
        }
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
}

-(void) deleteDB :(NSString *)time{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * delete = [NSString stringWithFormat:@"DELETE FROM FILEID  WHERE TIME='%@'",time];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [delete UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSLog(@"");
        }
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);

}
-(NSString *) readDB:(NSDate *)date{
    NSString *content = nil;
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString * time = [dateFormatter stringFromDate:date];
    NSString * sqlQuery = [NSString stringWithFormat:@"SELECT CONTENT FROM FILEID WHERE TIME='%@'",time];
    //    NSString *sqlQuery = @"SELECT * FROM FILEID";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char * _content  = (char*)sqlite3_column_text(statement,0);
            NSString * contents =[[NSString alloc]initWithUTF8String:_content];
            content = contents;
        }
    }
    return content;
    
}
-(NSInteger)allDataCount:(NSString *) _userID withOtherID:(NSString *)_friendID{
    NSInteger  count=0;
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString * sqlQuery = @"SELECT USERID,FROMID FROM FILEID";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *userId = (char*)sqlite3_column_text(statement, 0);
            char *friendId =(char*) sqlite3_column_text(statement, 1);
            NSString * userID = [[NSString alloc]initWithUTF8String:userId];
            NSString *friendID = [[NSString alloc]initWithUTF8String:friendId];
            if ([userID isEqualToString:_userID]&&[friendID isEqualToString:_friendID]) {
                count=count+1;
            }
            
        }
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return count;

}
-(UIImage *)getVideoImage:(NSString *)videoPath
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
    
}
@end
