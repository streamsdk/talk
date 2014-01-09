//
//  PlayerViewController.h
//  talk
//
//  Created by wangsh on 14-1-9.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMoviePlayerController.h"
@interface PlayerViewController : UIViewController<ALMoviePlayerControllerDelegate>

@property(nonatomic,retain)NSString * videopath;
@property (nonatomic, strong) ALMoviePlayerController *moviePlayer;
@property (nonatomic) CGRect defaultFrame;
@end
