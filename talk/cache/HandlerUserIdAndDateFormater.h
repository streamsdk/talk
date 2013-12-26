//
//  HandlerUserIdAndDateFormater.h
//  talk
//
//  Created by wangsh on 13-12-23.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandlerUserIdAndDateFormater : NSObject

+(HandlerUserIdAndDateFormater *)sharedObject;

-(NSString *)getUserID;

-(NSString *)getUserIDPassword;

-(NSString *)getPath;

@end
