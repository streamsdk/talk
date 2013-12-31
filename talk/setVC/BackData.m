//
//  BackData.m
//  talk
//
//  Created by wangsh on 13-12-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "BackData.h"

static UIImage *image;
@implementation BackData

+ (BackData *)sharedObject{
    
    static BackData *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[BackData alloc] init];
        
    });
    
    return sharedInstance;
}

-(void) setImage:(UIImage *)img{
    image = img;
}
-(UIImage *)getImage {
    return image;
}

@end
