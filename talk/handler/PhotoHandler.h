//
//  PhotoHandler.h
//  talk
//
//  Created by wangshuai on 13-12-22.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaHandler.h"

@interface PhotoHandler : MediaHandler

@property (nonatomic,retain) NSString  *type;

@property (nonatomic,retain) NSString  *photopath;

@property(nonatomic, strong)UIViewController *controller;

@property (nonatomic,retain) NSDate * uploadDate;

- (void)receiveFile:(NSData *)data withPath:(NSString *)path forBubbleDataArray:(NSMutableArray *)bubbleData withTime:(NSString *)time forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID withDate:(NSDate *)date;

-(void) sendPhoto :(NSData *)data forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID withTime:(NSString *)time;

@end
