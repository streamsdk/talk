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

@interface RootViewController ()

@end

#define TOPHEIGHT 64
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
    [imageview setImage:[UIImage imageNamed:@"talk4s.png"]];
    imageview.userInteractionEnabled = YES;
    [self.view addSubview:imageview];
    
    UIButton * loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(0, self.view.frame.size.height -200, self.view.frame.size.width, 70)];
    [loginBtn setTitle:@"LOG IN" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:[UIColor redColor]];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:loginBtn];
    
    UIButton * signupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupBtn setFrame:CGRectMake(0, self.view.frame.size.height -120, self.view.frame.size.width, 70)];
    [signupBtn setTitle:@"SIGN UP" forState:UIControlStateNormal];
    signupBtn.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [signupBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signupBtn setBackgroundColor:[UIColor greenColor]];
    [signupBtn addTarget:self action:@selector(singUp) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:signupBtn];
    
}
-(NSString *) getUserID{
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString *loginName = nil;
    if (array && [array count]!=0)
        loginName= [array objectAtIndex:0];
    
    return loginName;
    
}
-(void) login {
//    NSString * loginName = [self getUserID];
//    if (loginName) {
//        MyFriendsViewController *myFriendVC = [[MyFriendsViewController alloc]init];
//        [self.navigationController pushViewController:myFriendVC animated:YES];
//    }else {
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:loginVC animated:YES];
//    }
  
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
