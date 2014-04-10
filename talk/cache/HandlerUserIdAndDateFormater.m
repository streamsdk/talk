//
//  HandlerUserIdAndDateFormater.m
//  talk
//
//  Created by wangsh on 13-12-23.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "HandlerUserIdAndDateFormater.h"
static NSString * _videoPath;
static NSDate * _date;

@implementation HandlerUserIdAndDateFormater
+(HandlerUserIdAndDateFormater *)sharedObject {
    static HandlerUserIdAndDateFormater *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[HandlerUserIdAndDateFormater alloc] init];
        _date =[[NSDate alloc]init];
       
    });
    
    return sharedInstance;
    
}

-(NSString *)getUserID{
    
    /*NSString * userID =nil;
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    if (array && [array count]!=0) {
        
        userID = [array objectAtIndex:0];
    }
    return userID;*/
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * userId = [userDefaults objectForKey:@"username"];
    return userId;
}
-(NSString *)getUserIDPassword{
    
    /*NSString * password =nil;
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    if (array && [array count]!=0) {
        
        password = [array objectAtIndex:1];
    }
    return password;*/
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * password = [userDefaults objectForKey:@"password"];
    return password;
}

-(NSString *)getPath {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss.SSS"];
    NSString *path =  [ourDocumentPath stringByAppendingFormat:@"/out-%@", [formater stringFromDate:[NSDate date]]];
    return path;
}
-(void) videoPath:(NSString *)video{
    
    _videoPath =video;
}

-(NSString *)getVideopath{
    
    return _videoPath;
}
-(void) setDate:(NSDate *)date{
    
    _date = date;
}

-(NSDate *)getDate{
    return _date;
}
@end
