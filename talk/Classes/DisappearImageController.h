//
//  DisappearImageController.h
//  talk
//
//  Created by wangsh on 14-1-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisappearImageController : UIViewController

@property (nonatomic,strong) UIImage *disappearImage;

@property (nonatomic,retain) NSString *disappearTime;

@property (nonatomic,retain) NSString *disappearPath;

@property (nonatomic,retain) NSDate * date;
@end
