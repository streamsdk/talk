//
//  PlayerData.h
//  talk
//
//  Created by wangsh on 13-12-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerData : NSObject

+ (PlayerData *)sharedObject;

-(void) setPlayerData:(NSString * )string;

-(NSString *) getPlayerData;

@end
