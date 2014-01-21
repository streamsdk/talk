//
//  DisPalayerViewController.m
//  talk
//
//  Created by wangsh on 14-1-11.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "DisPlayerViewController.h"
#import <arcstreamsdk/JSONKit.h>
#import "ImageCache.h"
#import "TalkDB.h"
@interface DisPlayerViewController ()

@end

@implementation DisPlayerViewController
@synthesize moviePlayer,defaultFrame;
@synthesize videopath,time,date;

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
    self.title =@"VideoPlayer";
    //create a player
    self.moviePlayer = [[ALMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.moviePlayer.view.alpha = 0.f;
    self.moviePlayer.delegate = self; //IMPORTANT!
    
    //create the controls
    ALMoviePlayerControls *movieControls;
    if (time) {
        movieControls= [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.moviePlayer style:ALMoviePlayerControlsStyleDefault save:NO];
        ImageCache * cache = [ImageCache  sharedObject];
        TalkDB * talkDB = [[TalkDB alloc]init];
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
        [friendDict setObject:@"-1" forKey:@"time"];
        [friendDict setObject:videopath forKey:@"video"];
        [jsonDic setObject:friendDict forKey:[cache getFriendID]];
        NSString  *str = [jsonDic JSONString];
        [talkDB updateDB:date withContent:str];
    }
    else{
        movieControls= [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.moviePlayer style:ALMoviePlayerControlsStyleDefault save:YES];
        [movieControls setVideoPath:videopath];
    }
//    movieControls.delegate = self;
    [movieControls setBarColor:[UIColor colorWithRed:195/255.0 green:29/255.0 blue:29/255.0 alpha:0.5]];
    [movieControls setTimeRemainingDecrements:YES];

    //assign controls
    [self.moviePlayer setControls:movieControls];
    [self.view addSubview:self.moviePlayer.view];
    
    [self.moviePlayer setContentURL:[NSURL fileURLWithPath:videopath]];
    
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self configureViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.moviePlayer.view.alpha = 1.f;
        } completion:^(BOOL finished) {
            
            
        }];
    });
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(moviePlayerPreloadFinish:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:moviePlayer];

}
-(void)moviePlayerPreloadFinish:(NSNotificationCenter *)notificationCenter{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)configureViewForOrientation:(UIInterfaceOrientation)orientation {
    CGFloat videoWidth = 0;
    CGFloat videoHeight = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        videoWidth = 700.f;
        videoHeight = 535.f;
    } else {
        videoWidth = self.view.frame.size.width;
        videoHeight =self.view.frame.size.height;
    }
    
    self.defaultFrame = CGRectMake(0, 0, videoWidth, videoHeight);
    
    if (self.moviePlayer.isFullscreen)
        return;
    
    [self.moviePlayer setFrame:self.defaultFrame];
}

- (void)moviePlayerWillMoveFromWindow {
   
    [self dismissViewControllerAnimated:YES completion:^{
        if (![self.view.subviews containsObject:self.moviePlayer.view]){
            [self.view addSubview:self.moviePlayer.view];
        }
        [self.moviePlayer setFrame:self.defaultFrame];
    }];
  
}
- (void)movieTimedOut {
    NSLog(@"VIDEO TIMED OUT");
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self configureViewForOrientation:toInterfaceOrientation];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
