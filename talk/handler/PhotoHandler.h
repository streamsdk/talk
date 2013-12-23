//
//  PhotoHandler.h
//  talk
//
//  Created by wangshuai on 13-12-22.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerDelegate.h"

@interface PhotoHandler : NSObject<PlayerDelegate>

@property(nonatomic, strong)UIViewController *controller;

- (NSMutableDictionary *)receiveFile:(NSData *)data forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID;

-(void) sendPhoto :(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID;

@end
