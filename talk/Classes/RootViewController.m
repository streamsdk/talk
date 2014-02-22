//
//  RootViewController.m
//  talk
//
//  Created by wangsh on 13-12-5.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "RootViewController.h"
#import "CreateUI.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "MyFriendsViewController.h"
//#import "TwitterConnect.h"
//#import "TwitterViewController.h"
@interface RootViewController ()

@end

#define TOPHEIGHT 64
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
@implementation RootViewController

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
    
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    if (IS_IPHONE5)
        [imageview setImage:[UIImage imageNamed:@"flash1136.png"]];
    else
        [imageview setImage:[UIImage imageNamed:@"flash960.png"]];
    imageview.userInteractionEnabled = YES;
    [self.view addSubview:imageview];
    
    UIButton * loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(0, self.view.frame.size.height -180, self.view.frame.size.width, 60)];
    [loginBtn setTitle:@"LOG IN" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:[UIColor redColor]];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:loginBtn];
    
    UIButton * signupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupBtn setFrame:CGRectMake(0, self.view.frame.size.height -100, self.view.frame.size.width, 60)];
    [signupBtn setTitle:@"SIGN UP" forState:UIControlStateNormal];
    signupBtn.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [signupBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signupBtn setBackgroundColor:[UIColor greenColor]];
    [signupBtn addTarget:self action:@selector(singUp) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:signupBtn];
    
   /* UIImageView * view =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line.png"]];
    [view setFrame:CGRectMake(0, self.view.frame.size.height -80, self.view.frame.size.width, 20)];
    [imageview addSubview:view];
    UILabel * label =[[UILabel alloc]initWithFrame:CGRectMake(105, self.view.frame.size.height -85, 130, 30)];
    label.text = @"Or Login with";
    label.font =[UIFont fontWithName:@"Chalkduster" size:14.0f];
    label.backgroundColor = [UIColor clearColor];
    [imageview addSubview:label];
    
    UIButton * twitterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterBtn setFrame:CGRectMake(0, self.view.frame.size.height -50, self.view.frame.size.width, 38)];
    [twitterBtn setTitle:@"Twitter" forState:UIControlStateNormal];
    twitterBtn.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:18.0f];
    [twitterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [twitterBtn setBackgroundColor:[UIColor colorWithRed:0/255 green:172/255 blue:2337/255 alpha:1.0]];
    [twitterBtn addTarget:self action:@selector(twitterBtn) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:twitterBtn];*/
    
}
/*-(void)twitterBtn{
    NSLog(@"");
    
    TwitterConnect * twitter = [[TwitterConnect alloc]init];
    ACAccountStore  *accountStore = [[ACAccountStore alloc] init];
    [twitter setAccountStore:accountStore];
    [twitter fetchFellowerAndFollowing:@"15Slogn"];
   
    TwitterViewController *twitterVC = [[TwitterViewController alloc]init];
    [self.navigationController pushViewController:twitterVC animated:YES];

}*/
-(void) login {
  
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}
-(void) singUp {
    SignUpViewController *signupVC = [[SignUpViewController alloc]init];
    [self.navigationController pushViewController:signupVC animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
