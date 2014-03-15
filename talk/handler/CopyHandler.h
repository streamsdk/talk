//
//  CopyHandler.h
//  talk
//
//  Created by wangsh on 14-3-15.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CopyHandler : NSObject

-(void) sendFile:(UIImage *)image withdate:(NSDate *)date forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withFileType:(NSString *)type;

@end
