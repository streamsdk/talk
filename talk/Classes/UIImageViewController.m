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

    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(10, 26, 50, 26)];
    [[backButton layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[backButton layer] setBorderWidth:1];
    [[backButton layer] setCornerRadius:4];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleTapGesture) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:backButton];
    
    UIButton * saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake(self.view.frame.size.width-60, 26, 50, 26)];
    [[saveButton layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[saveButton layer] setBorderWidth:1];
    [[saveButton layer] setCornerRadius:4];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveClicked) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:saveButton];

}

-(void) saveClicked {
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:IMAGE_TAG];
    UIImageWriteToSavedPhotosAlbum([imageView image], nil, nil,nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"You have successfully stored in the photo album"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
