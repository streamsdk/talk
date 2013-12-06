//
//  PlayerView.m
//  talk
//
//  Created by wangshuai on 13-11-13.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView
@synthesize pvc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
}
-(void)playVideo:(NSURL *)url{
    
    pvc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentViewController:pvc animated:YES completion:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}
//播放结束事件

-(void)moviePlayBackDidFinish:(NSNotification *)notification
{
    [pvc dismissViewControllerAnimated:YES completion:NULL];
}

@end
