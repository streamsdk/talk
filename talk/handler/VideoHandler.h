//
//  VideoHandler.h
//  talk
//
//  Created by wangshuai on 13-12-23.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "PlayerDelegate.h"

@protocol reloadTableDeleage <NSObject>

-(void)reloadTable;

@end
@interface VideoHandler : NSObject
{
   
    NSString* _mp4Path;
    NSMutableArray *_bubbleData;
    NSData * _myData;
    NSString *_sendID;

}
@property(nonatomic, strong)UIViewController *controller;
@property (nonatomic,strong) NSURL  *videoPath;
@property (assign)id<reloadTableDeleage>delegate;

- (void)receiveVideoFile:(NSData *)data forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID;

-(void)sendVideoforBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID;

@end
