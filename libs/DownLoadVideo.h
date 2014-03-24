//
//  DownLoadVideo.h
//  talk
//
//  Created by wangsh on 14-3-24.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIBubbleTableViewCell.h"
@interface DownLoadVideo : NSObject
@property (nonatomic,retain) NSDictionary * dict;
@property (nonatomic,retain) NSDate * date;
@property (nonatomic,strong) UIButton * button;
@property (nonatomic,strong) UIBubbleTableViewCell * cell;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;
@end
