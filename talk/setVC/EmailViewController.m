//
//  EmailViewController.m
//  talk
//
//  Created by wangsh on 14-1-15.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "EmailViewController.h"
#import "ImageCache.h"
#import "HandlerUserIdAndDateFormater.h"
#import <arcstreamsdk/STreamUser.h>

#define NEWEMAILTEXTFILED_TAG 1000
@interface EmailViewController ()

@end

@implementation EmailViewController

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
    self.title = @"set email";
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    ImageCache * imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata=[imageCache getUserMetadata:[handle getUserID]];
    NSString *email=[userMetadata objectForKey:@"Email"];
    if (!email) {
        email= @"email is null";
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(10, 80, self.view.frame.size.width-20, 180)];
    view.backgroundColor = [UIColor whiteColor];
    [view.layer setBorderColor:[[UIColor lightGrayColor]CGColor]];
    [view.layer setBorderWidth:2.0];
    [view.layer setCornerRadius:7.0];
    [self.view addSubview:view];
    UILabel *oldEmail = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 80, 40)];
    oldEmail.text = @"oldEmail:";
    oldEmail.backgroundColor = [UIColor clearColor];
    oldEmail.textAlignment = NSTextAlignmentRight;
    [view addSubview:oldEmail];
    
    UITextField *oldE= [[UITextField alloc]initWithFrame:CGRectMake(95, 30, 200, 40)];
    oldE.text = email;
    oldE.borderStyle = UITextBorderStyleRoundedRect;
    oldE.enabled = NO;
    oldE.backgroundColor = [UIColor clearColor];
    [view addSubview:oldE];
    
    UILabel *newEmail = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 80, 40)];
    newEmail.text = @"newEmail:";
    newEmail.backgroundColor = [UIColor clearColor];
    newEmail.textAlignment = NSTextAlignmentRight;
    [view addSubview:newEmail];
    
   UITextField* newEmailTextField = [[UITextField alloc]initWithFrame:CGRectMake(95, 100, 200, 40)];
    [newEmailTextField becomeFirstResponder];
    newEmailTextField.tag = NEWEMAILTEXTFILED_TAG;
    newEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
    [view addSubview:newEmailTextField];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done)];
}
-(void)Done{
    
    UITextField* newEmailField= (UITextField*)[self.view viewWithTag:NEWEMAILTEXTFILED_TAG];
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSString *email = newEmailField.text;
    if (![email isEqualToString:@""] && [email length]!=0) {
        ImageCache * imageCache = [ImageCache sharedObject];
        NSMutableDictionary *userMetadata=[imageCache getUserMetadata:[handle getUserID]];
        [userMetadata  setObject:email forKey:@"Email"];
        [imageCache saveUserMetadata:[handle getUserID] withMetadata:userMetadata];
        STreamUser *user = [[STreamUser alloc]init];
        [user updateUserMetadata:[handle getUserID] withMetadata:userMetadata];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
