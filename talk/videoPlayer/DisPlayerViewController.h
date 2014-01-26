//
//  DisPalayerViewController.h
//  talk
//
//  Created by wangsh on 14-1-11.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMoviePlayerController.h"

@interface DisPlayerViewController : UIViewController <ALMoviePlayerControllerDelegate>

@property (nonatomic,retain) NSString * videopath;
@property (nonatomic,retain) NSString * time;
@property (nonatomic,retain) NSDate * date;
@property (nonatomic, strong) ALMoviePlayerController *moviePlayer;
@property (nonatomic) CGRect defaultFrame;
@end
