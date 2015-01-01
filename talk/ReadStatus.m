//
//  ReadStatus.m
//  talk
//
//  Created by wangsh on 14-4-3.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "ReadStatus.h"
#import "HandlerUserIdAndDateFormater.h"
#import <arcstreamsdk/STreamObject.h>
#import "ImageCache.h"
#import <arcstreamsdk/STreamUser.h>
#import "AddDB.h"
@implementation ReadStatus

-(void)loadAllMetaData{
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * addDB = [[AddDB alloc]init];
    NSMutableDictionary * addDict = [addDB readDB:[handle getUserID]];
    NSArray * array = [addDict allKeys];
    for (NSString * friendID in array) {
        [self saveData:friendID];
        [self performSelectorInBackground:@selector(saveData:) withObject:friendID ];
    }
    
}
-(void) saveData:(NSString *)friendID {
    STreamUser *user = [[STreamUser alloc] init];
    ImageCache *imageCache = [ImageCache sharedObject];
    [user loadUserMetadata:friendID];
    if ([user userMetadata])
       [imageCache saveUserMetadata:friendID withMetadata:[user userMetadata]];
    
    /*[user loadUserMetadata:friendID response:^(BOOL succeed, NSString *error){
        if ([error isEqualToString:friendID]){
            NSMutableDictionary *dic = [user userMetadata];
            [allMetaData setObject:dic forKey:friendID];
             [imageCache saveUserMetadata:friendID withMetadata:dic];
        }
    }];*/

}
-(NSString *) readStatus:(NSString *)fromID {
    NSString * status = nil;
    ImageCache *imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:fromID];
    status = [userMetaData objectForKey:@"status"];
    if (status==nil || [status isEqualToString:@""])status = @"Hey there! I am using CoolChat";
    return status;
}

@end
