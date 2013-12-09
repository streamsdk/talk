//
//  PlayerData.m
//  talk
//
//  Created by wangsh on 13-12-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "PlayerData.h"
static NSString * _videPath;

@implementation PlayerData

+(PlayerData *) sharedObject{
    static PlayerData *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[PlayerData alloc] init];
        
    });
    
    return sharedInstance;
    
}
-(void) setPlayerData:(NSString *)string{
    
    _videPath = string;
}
-(NSString *) getPlayerData {
    return _videPath;
}

@end
