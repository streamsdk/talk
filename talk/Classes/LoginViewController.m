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
#import "CreateUI.h"
#import "SignUpViewController.h"
#import "RootViewController.h"
#import "MyFriendsViewController.h"
#import "ImageCache.h"
#import "MBProgressHUD.h"
#import "ImageCache.h"
#import "FileCache.h"
#import <arcstreamsdk/STreamFile.h>
#import "DownloadAvatar.h"
#import "DownloadAvatar.h"

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
-(void) back {

    RootViewController *rvc = [[RootViewController alloc]init];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:rvc animated:YES];

//    self.navigationController.navigationBarHidden = YES;
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Log In";
     self.navigationController.navigationBarHidden = NO;
    
    self .navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftitem = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftitem;
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
//    [imageview setImage:[UIImage imageNamed:@"bg.png"]];
    imageview.userInteractionEnabled = YES;
    [self.view addSubview:imageview];
    CreateUI * createUI = [[CreateUI alloc]init];
    
    CGRect frame = CGRectMake(20, 80, self.view.frame.size.width-40, 50);
    userNameText = [createUI setTextFrame:frame];
    userNameText.delegate = self;
    [userNameText becomeFirstResponder];
    userNameText.keyboardType = UIKeyboardTypeAlphabet;
    userNameText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [userNameText setAutocorrectionType:UITextAutocorrectionTypeNo];
    [userNameText setSpellCheckingType:UITextSpellCheckingTypeYes];
    [imageview addSubview:userNameText];
    
    password = [createUI setTextFrame:CGRectMake(20,150, self.view.frame.size.width-40, 50)];
    
    password.delegate = self;
    [password setSecureTextEntry:YES];
    password.keyboardType = UIKeyboardTypeAlphabet;
    [imageview addSubview:password];
    
    UIButton *loginButton = [createUI setButtonFrame:CGRectMake(20, 220, self.view.frame.size.width-40, 50) withTitle:@"LOG IN"];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setBackgroundColor:[UIColor blackColor]];
    [loginButton addTarget:self action:@selector(loginUser) forControlEvents:UIControlEventTouchUpInside];
    [imageview addSubview:loginButton];
    
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    if (array && [array count]!=0){
        userNameText.text = [array objectAtIndex:0];
        password.text = [array objectAtIndex:1];
    }else{
        userNameText.placeholder = @"user name";
        password.placeholder = @"password";
    }
    

}
-(NSString*)getCacheDirectory
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
}
-(void) loginUser {
    
    [userNameText resignFirstResponder];
    STreamUser *user = [[STreamUser alloc]init];
    NSString *userName = userNameText.text;
    userName = [userName lowercaseString];
    NSString *passWord = password.text;
//    NSString *nameFilePath = [self getCacheDirectory];
//    NSArray * nameArray = [[NSArray alloc]initWithObjects:userName,passWord, nil];
    __block NSString * error;
    DownloadAvatar *downloadAvatar = [[DownloadAvatar alloc]init];
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"user does not exist or password wrong" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    if (userName && ([userName length] != 0) && passWord &&([passWord length]!= 0)) {
        
        __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.labelText = @"log you in, Please wait...";
        [self.view addSubview:HUD];
        [HUD showAnimated:YES whileExecutingBlock:^{
             [user logIn:userName withPassword:passWord];
            NSLog(@"%@",[user errorMessage]);
            error = [user errorMessage];
            if ([[user errorMessage] length] == 0) {
                 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:userName forKey:@"username"];
                [userDefaults setObject:passWord forKey:@"password"];
//                [nameArray writeToFile:nameFilePath atomically:YES];
                STreamUser *user = [[STreamUser alloc] init];
                [user loadUserMetadata:userName response:^(BOOL succeed, NSString *error){
                    if ([error isEqualToString:userName]){
                        NSMutableDictionary *dic = [user userMetadata];
                        ImageCache *imageCache = [ImageCache sharedObject];
                        [imageCache saveUserMetadata:userName withMetadata:dic];
                        [downloadAvatar loadAvatar:userName];
                    }
                }];
                
            }
        }completionBlock:^{
            if ([error length] == 0) {
                MyFriendsViewController *myFriendVC = [[MyFriendsViewController alloc]init];
                [self.navigationController pushViewController:myFriendVC animated:YES];
            }else{
                [alertView show];
            }
           
            [HUD removeFromSuperview];
            HUD = nil;
        }];

    }else {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"please input user name or password" delegate:self cancelButtonTitle:@"TRY AGAIN" otherButtonTitles:nil, nil];
        [alertView show];
    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
