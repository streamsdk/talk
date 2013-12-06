//
//  LoginViewController.m
//  talk
//
//  Created by YR_MAC on 13-11-10.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "LoginViewController.h"
#import "MainController.h"
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamFile.h>
#import "CreateUI.h"
#import "STreamXMPP.h"
#import "AllUserViewController.h"
#import "SignUpViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize userNameText,password;


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
    
//    self .navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    [imageview setImage:[UIImage imageNamed:@"background.png"]];
    imageview.userInteractionEnabled = YES;
    [self.view addSubview:imageview];
    CreateUI * createUI = [[CreateUI alloc]init];
    
    CGRect frame = CGRectMake(20, 80, self.view.frame.size.width-40, 50);
    userNameText = [createUI setTextFrame:frame];
    userNameText.placeholder = @"user name";
    userNameText.delegate = self;
    [userNameText becomeFirstResponder];
    userNameText.keyboardType = UIKeyboardTypeAlphabet;
    [imageview addSubview:userNameText];
    
    password = [createUI setTextFrame:CGRectMake(20,150, self.view.frame.size.width-40, 50)];
    password.placeholder = @"password";
    password.delegate = self;
    [password setSecureTextEntry:YES];
    password.keyboardType = UIKeyboardTypeAlphabet;
    [imageview addSubview:password];
    
    UIButton *loginButton = [createUI setButtonFrame:CGRectMake(20, 220, self.view.frame.size.width-40, 40) withTitle:@"LOG IN"];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [loginButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [loginButton setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:229.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [loginButton addTarget:self action:@selector(loginUser) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:loginButton];

    
}
-(NSString*)getCacheDirectory
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
}
-(void) loginUser {
    
    STreamUser *user = [[STreamUser alloc]init];
    NSString *userName = userNameText.text;
    NSString *passWord = password.text;
    NSString *nameFilePath = [self getCacheDirectory];
    NSArray * nameArray = [[NSArray alloc]initWithObjects:userName,passWord, nil];
    [nameArray writeToFile:nameFilePath atomically:YES];
    if (userName && ([userName length] != 0) && passWord &&([passWord length]!= 0)) {
        
        [user logIn:userName withPassword:passWord];
        
        NSLog(@"%@",[user errorMessage]);
        if ([[user errorMessage] length] == 0) {
            
            STreamXMPP *con = [STreamXMPP sharedObject];
            [con connect:userName withPassword:passWord];
            AllUserViewController *userVC = [[AllUserViewController alloc]init];
            [self.navigationController pushViewController:userVC animated:NO];
        } else {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"user does not exist or password error,please sigUp" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"please input user name or password" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
