//
//  LoadAllMetaData.m
//  talk
//
//  Created by wangsh on 14-4-10.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "LoadAllMetaData.h"
#import "HandlerUserIdAndDateFormater.h"
#import <arcstreamsdk/STreamObject.h>
#import "ImageCache.h"
#import <arcstreamsdk/STreamUser.h>
#import "AddDB.h"
@implementation LoadAllMetaData

-(void)loadAllMetaData{
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * addDB = [[AddDB alloc]init];
    NSMutableDictionary * addDict = [addDB readDB:[handle getUserID]];
    NSArray * array = [addDict allKeys];
    for (NSString * friendID in array) {
        [self performSelectorInBackground:@selector(saveData:) withObject:friendID ];
    }
    
}
-(void) saveData:(NSString *)friendID {
    STreamUser *user = [[STreamUser alloc] init];
    ImageCache *imageCache = [ImageCache sharedObject];
    NSMutableDictionary * allMetaData = [[NSMutableDictionary alloc]initWithCapacity:0];
    [user loadUserMetadata:friendID response:^(BOOL succeed, NSString *error){
        if ([error isEqualToString:friendID]){
            NSMutableDictionary *dic = [user userMetadata];
            [allMetaData setObject:dic forKey:friendID];
            [imageCache saveUserMetadata:friendID withMetadata:dic];
        }
    }];
    
}

@end
