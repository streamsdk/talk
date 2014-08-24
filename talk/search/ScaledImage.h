//
//  ScaledImage.h
//  talk
//
//  Created by wangsh on 14-4-10.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScaledImage : NSObject

-(UIImage *)imageWithImage:(UIImage *)_image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;

@end
