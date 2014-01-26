//
//  DisappearImageController.m
//  talk
//
//  Created by wangsh on 14-1-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "DisappearImageController.h"
#import "TalkDB.h"
#import "HandlerUserIdAndDateFormater.h"
#import "ImageCache.h"
#import <arcstreamsdk/JSONKit.h>

#define IMAGE_TAG 1000
#define BUTTON_TAG 2000
@interface DisappearImageController ()
{
    NSTimer *timer;
}
@end

@implementation DisappearImageController
@synthesize disappearTime,disappearImage,disappearPath,date;

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
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView*imageView=[[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.tag = IMAGE_TAG;
    [imageView setImage:disappearImage];
    [self.view addSubview:imageView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = BUTTON_TAG;
    [button setFrame:CGRectMake(260, 100, 50, 50)];
    [button setBackgroundImage:[UIImage imageNamed:@"message_count.png"] forState:UIControlStateNormal];
    [button setTitle:disappearTime forState:UIControlStateNormal];
    [imageView addSubview:button];
    
    [timer setFireDate:[NSDate distantPast]];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(doTimer) userInfo:nil repeats:YES];
}
-(void)doTimer
{
   
    UIButton *button = (UIButton *)[self.view viewWithTag:BUTTON_TAG];
    int  time=[disappearTime intValue];
    time--;
    disappearTime = [NSString stringWithFormat:@"%d",time];
    [button setTitle:disappearTime forState:UIControlStateNormal];
    if (time==1) {
        ImageCache * cache = [ImageCache  sharedObject];
        TalkDB * talkDB = [[TalkDB alloc]init];
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
        [friendDict setObject:@"-1" forKey:@"time"];
        [friendDict setObject:disappearPath forKey:@"photo"];
        [jsonDic setObject:friendDict forKey:[cache getFriendID]];
        NSString  *str = [jsonDic JSONString];
        [talkDB updateDB:date withContent:str];
        [timer setFireDate:[NSDate distantFuture]];
        [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
        }];
    
    }
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
