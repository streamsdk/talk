//
//  Maphandler.h
//  talk
//
//  Created by wangsh on 14-3-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaHandler.h"
@protocol MapDeleage <NSObject>

-(void)reloadMapView;

@end

@interface Maphandler : MediaHandler

@property (nonatomic,assign) BOOL  isfromUploadDB;

@property (nonatomic,retain) NSString  *mappath;

@property (nonatomic,retain) NSDate * uploadDate;

@property (assign)id<MapDeleage>delegate;

- (void)receiveAddress:(NSString *)receiveAddress latitude:(float)latitude longitude:(float)longitude withImage:(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID;

-(void) sendAddress :(NSString *)address latitude:(float)latitude longitude:(float)longitude withImage:(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID;

@end
