//
//  UIImageViewController.m
//  talk
//
//  Created by wangsh on 13-12-16.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "UIImageViewController.h"
@interface UIImageViewController ()

@end
#define IMAGE_TAG 2000
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
    imageview.tag = IMAGE_TAG;
    [self.view addSubview:imageview];
  
    UIButton * backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, 60, 60)];
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleTapGesture) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:backButton];

}
-(void) handleTapGesture
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
    }];
}
-(void)handleTappressGesture{
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
