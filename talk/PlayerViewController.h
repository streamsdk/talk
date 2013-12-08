//
//  PlayerViewController.h
//  talk
//
//  Created by wangsh on 13-12-8.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
@interface PlayerViewController : UIViewController

-(void) playerVideo:(NSData *)videoData;
@end
