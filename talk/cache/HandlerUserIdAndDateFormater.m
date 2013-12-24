//
//  HandlerUserIdAndDateFormater.m
//  talk
//
//  Created by wangsh on 13-12-23.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "HandlerUserIdAndDateFormater.h"

@implementation HandlerUserIdAndDateFormater
+(HandlerUserIdAndDateFormater *)sharedObject {
    static HandlerUserIdAndDateFormater *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[HandlerUserIdAndDateFormater alloc] init];
       
    });
    
    return sharedInstance;
    
}

-(NSString *)getUserID{
    
    NSString * userID =nil;
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    if (array && [array count]!=0) {
        
        userID = [array objectAtIndex:0];
    }
    return userID;
}
-(NSString *)getPath {
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@", [formater stringFromDate:[NSDate date]]];
    return path;
}

@end
