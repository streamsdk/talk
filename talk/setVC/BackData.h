//
//  BackData.h
//  talk
//
//  Created by wangsh on 13-12-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackData : NSObject
+ (BackData *)sharedObject;

-(void) setImage:(UIImage *)img;

-(UIImage *) getImage;

@end
