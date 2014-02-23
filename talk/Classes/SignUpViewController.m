//
//  SignUpViewController.m
//  talk
//
//  Created by wangshuai on 13-11-12.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SignUpViewController.h"
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/StreamPush.h>
#import "LoginViewController.h"
#import "CreateUI.h"
#import "ImageCache.h"
#import "MBProgressHUD.h"
#import "FileCache.h"
#import "MyFriendsViewController.h"
#import "RootViewController.h"
#import "DownloadAvatar.h"


@interface SignUpViewController ()<UIActionSheetDelegate>
{
    UIActionSheet* actionSheet;
}
@end

@implementation SignUpViewController

@synthesize userName,password,surePassword;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) back {
    self.navigationController.navigationBarHidden = YES;
    RootViewController * rvc =[[RootViewController alloc]init];
    [self.navigationController pushViewController:rvc animated:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"sign up";
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.hidesBottomBarWhenPushed = YES;
    
    UIBarButtonItem * leftitem = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftitem;
    
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
//    [bgView setImage:[UIImage imageNamed:@"bg.png"]];
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];

    CreateUI *createUI = [[CreateUI alloc]init];
    CGRect viewFrame =self.view.frame;
    CGFloat height =80;

    userName = [createUI setTextFrame:CGRectMake(20,height, viewFrame.size.width-40, 40)];
    userName.keyboardType = UIKeyboardTypeAlphabet;
    userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [userName setAutocorrectionType:UITextAutocorrectionTypeNo];
    [userName setSpellCheckingType:UITextSpellCheckingTypeYes];
    userName.delegate = self;
    [userName becomeFirstResponder];
    userName.placeholder = @"Input User Name";
    [bgView addSubview:userName];
    
    height = height+userName.frame.size.height +10;
    password = [createUI setTextFrame:CGRectMake(20, height , viewFrame.size.width-40, 40)];
    password.keyboardType = UIKeyboardTypeAlphabet;
    [password setSecureTextEntry:YES];
    password.delegate = self;
    password.placeholder = @"input password";
    [bgView addSubview:password];
    
    height = height +password.frame.size.height+10;
    surePassword = [createUI setTextFrame:CGRectMake(20, height ,viewFrame.size.width-40, 40)];
    surePassword.keyboardType = UIKeyboardTypeAlphabet;
    [surePassword setSecureTextEntry:YES];
    surePassword.delegate = self;
    surePassword.placeholder = @"input password again";
    [bgView addSubview:surePassword];
    
    height = height +surePassword.frame.size.height+10;
    UIButton *signUpButton = [createUI setButtonFrame:CGRectMake(20, height , viewFrame.size.width-40, 50) withTitle:@"SIGN UP"];
    [signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signUpButton setBackgroundColor:[UIColor greenColor]];
    [signUpButton addTarget:self action:@selector(signUpUser) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:signUpButton];

}
- (void)addAsFriend:(NSString *)myUserName withFriend:(NSString *)friendUserName{
    
    
    STreamObject *myObject = [[STreamObject alloc] init];
    [myObject setObjectId:friendUserName];
    [myObject addStaff:@"status" withObject:@"friend"];
    [myObject setCategory:myUserName];
    [myObject updateInBackground];
    
    
    STreamObject *friendObject = [[STreamObject alloc] init];
    [friendObject setObjectId:myUserName];
    [friendObject setCategory:friendUserName];
    [friendObject addStaff:@"status" withObject:@"friend"];
    [friendObject updateInBackground];
    
}


- (void)addAsFriendRequest:(NSString *)myUserName withFriend:(NSString *)friendUserName{
    
    STreamObject *myObject = [[STreamObject alloc] init];
    [myObject setObjectId:friendUserName];
    [myObject addStaff:@"status" withObject:@"request"];
    [myObject setCategory:myUserName];
    [myObject updateInBackground];
    
    
    STreamObject *friendObject = [[STreamObject alloc] init];
    [friendObject setObjectId:myUserName];
    [friendObject setCategory:friendUserName];
    [friendObject addStaff:@"status" withObject:@"request"];
    [friendObject updateInBackground];
    
    
}



-(void )signUpUser {
    [userName resignFirstResponder];
    NSString *username = userName.text;
    username = [username lowercaseString];
    NSString *pword = password.text;
    NSString *secondWord = surePassword.text;
    if (username && pword && [secondWord isEqualToString:pword]) {
        
        STreamUser *user = [[STreamUser alloc] init];
        NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
        [metaData setValue:username forKey:@"name"];
        [metaData setValue:pword forKey:@"password"];
        [metaData setValue:@"" forKey:@"profileImageId"];
        NSString *token = [STreamPush getToken];
        if (token){
            [metaData setValue:token forKey:@"token"];
        }
        
        DownloadAvatar *downloadAvatar = [[DownloadAvatar alloc]init];
        __block NSString * error;
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"this user name is existing in your system" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.labelText = @"loading friends...";
        [self.view addSubview:HUD];
        [HUD showAnimated:YES whileExecutingBlock:^{
            [user signUp:username withPassword:pword withMetadata:metaData];
            
            error = [user errorMessage];
            if ([error isEqualToString:@""]){
                STreamObject * history = [[STreamObject alloc]init];
                [history setObjectId:[username stringByAppendingString:@"messaginghistory"]];
                [history createNewObject:^(BOOL succeed, NSString *objectId) {
                    if (succeed)
                        NSLog(@"succeed");
                    else
                        NSLog(@"failed");
                }];
                
                STreamCategoryObject * sto = [[STreamCategoryObject alloc]initWithCategory:username];
                [sto createNewCategoryObject:^(BOOL succeed, NSString *response){
                    
                    if (succeed)
                        NSLog(@"succeed");
                    else
                        NSLog(@"failed");
                }];
//                NSString *nameFilePath = [self getCacheDirectory];
//                NSArray * nameArray = [[NSArray alloc]initWithObjects:username,pword, nil];
//                [nameArray writeToFile:nameFilePath atomically:YES];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:username forKey:@"username"];
                [userDefaults setObject:pword forKey:@"password"];
                //杨蕊 请检查这里为什么要log in, 有必要吗？？？？？
//                [user logIn:username withPassword:pword];
                
                [user loadUserMetadata:username response:^(BOOL succeed, NSString *error){
                    if ([error isEqualToString:username]){
                        NSMutableDictionary *dic = [user userMetadata];
                        ImageCache *imageCache = [ImageCache sharedObject];
                        [imageCache saveUserMetadata:username withMetadata:dic];
                        [downloadAvatar loadAvatar:username];
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
    }else{
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"User name or password error" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
         [alertView show];
    }
    
        NSLog(@"");
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(NSString*)getCacheDirectory
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
