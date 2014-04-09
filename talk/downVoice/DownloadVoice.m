//
//  DownloadVoice.m
//  talk
//
//  Created by wangsh on 14-4-9.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "DownloadVoice.h"
#import "NSBubbleData.h"
#import <arcstreamsdk/STreamFile.h>

@implementation DownloadVoice

-(void) downloadVoice:(NSArray *)array{
    ImageCache * imagecache =[ImageCache sharedObject];
    __block NSBubbleData * bubble;
    STreamFile * sf = [[STreamFile alloc]init];
    NSString * fileId = [array objectAtIndex:0];
    [imagecache saveVoiceFile:array withfileID:fileId];
    [sf downloadAsData:fileId downloadedData:^(NSData *data, NSString *objectId) {
        NSArray * _array = [imagecache getVoiceFile:objectId];
        [data writeToFile:[_array objectAtIndex:1] atomically:YES];
        bubble = [_array lastObject];
        bubble.audioData = data;
        [imagecache removeVoiceFile:objectId];
    }];
}
@end
