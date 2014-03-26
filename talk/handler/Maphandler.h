//
//  Maphandler.h
//  talk
//
//  Created by wangsh on 14-3-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Maphandler : NSObject

- (void)receiveAddress:(NSString *)receiveAddress latitude:(float)latitude longitude:(float)longitude forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID;

-(void) sendAddress :(NSString *)address latitude:(float)latitude longitude:(float)longitude forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID;

@end
