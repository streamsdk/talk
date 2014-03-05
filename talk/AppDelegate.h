//
//  AppDelegate.h
//  talk
//
//  Created by wangshuai on 13-10-20.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,strong) UIProgressView * progressView;
@property (nonatomic,strong) UILabel * label;
@property (nonatomic,retain) NSMutableDictionary *progressDict;
@property (nonatomic,retain) NSString * path;
@property (nonatomic,retain) NSMutableArray *deleteArray;
-(void)showFriendsView;

@end
