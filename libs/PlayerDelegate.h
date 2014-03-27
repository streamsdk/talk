//
//  PlayerDelegate.h
//  talk
//
//  Created by wangshuai on 13-12-22.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerDelegate <NSObject>

-(void) playerVideo:(NSString *)path withTime:(NSString *)time withDate:(NSDate *)date;

-(void)bigImage:(UIImage *)image;

-(void) disappearImage:(UIImage *)image withDissapearTime:(NSString *)time withDissapearPath:(NSString *)path withSendOrReceiveTime:(NSDate *)date;

-(void)copyImage:(UIImage *)image withdate:(NSDate *)date withView:(UIImageView *)imageview withBubbleType:(BOOL)isMine;

-(void)copyVideo:(UIImage *)image withdate:(NSDate *)date withView:(UIImageView *)imageview withPath:(NSString *)path withBubbleType:(BOOL)isMine;
-(void)copyAudiodate:(NSDate *)date withView:(UIImageView *)imageview withAudioTime:(NSString *)time withBubbleType:(BOOL)isMine;

-(void) showLocation:(NSString *)address latitude:(float)latitude longitude:(float)longitude;

@end
