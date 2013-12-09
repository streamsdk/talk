//
//  PlayerViewController.m
//  talk
//
//  Created by wangsh on 13-12-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerData.h"
@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    PlayerData * data = [PlayerData sharedObject];
    NSString * _mp4Path = [data getPlayerData];
    MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost/private%@", _mp4Path]]];
    NSLog(@"%@",[NSString stringWithFormat:@"file://localhost/private%@", _mp4Path]);
    [self presentViewController:playerView animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
