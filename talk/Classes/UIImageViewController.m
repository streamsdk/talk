//
//  UIImageViewController.m
//  talk
//
//  Created by wangsh on 13-12-16.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "UIImageViewController.h"
#import "MainController.h"

@interface UIImageViewController ()

@end

@implementation UIImageViewController
@synthesize image;
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
    UIImageView *imageview  = [[UIImageView alloc]initWithFrame:self.view.frame];
    [imageview setImage:image];
    imageview.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longpressGesutre=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongpressGesture)];
    longpressGesutre.minimumPressDuration=1;
    longpressGesutre.allowableMovement=15;
    longpressGesutre.numberOfTouchesRequired=1;
    [imageview addGestureRecognizer:longpressGesutre];
    [self.view addSubview:imageview];
}
-(void) handleLongpressGesture {
    MainController *mainVC = [[MainController alloc]init]; 
    [self.navigationController pushViewController:mainVC animated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
