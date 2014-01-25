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
#import "LoginViewController.h"
#import "CreateUI.h"
#import "ImageCache.h"
#import "MBProgressHUD.h"
#import "FileCache.h"
#import "MyFriendsViewController.h"
#import "RootViewController.h"
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
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.hidesBottomBarWhenPushed = YES;
    
    UIBarButtonItem * leftitem = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftitem;
    
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    [bgView setImage:[UIImage imageNamed:@"bg.png"]];
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];

    CreateUI *createUI = [[CreateUI alloc]init];
    CGRect viewFrame =self.view.frame;
    CGFloat height =80;

    userName = [createUI setTextFrame:CGRectMake(20,height, viewFrame.size.width-40, 40)];
    userName.keyboardType = UIKeyboardTypeAlphabet;
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
-(void )signUpUser {
    NSString *username = userName.text;
    NSString *pword = password.text;
    NSString *secondWord = surePassword.text;
    if (username && pword && [secondWord isEqualToString:pword]) {
        
        STreamUser *user = [[STreamUser alloc] init];
        NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
        [metaData setValue:username forKey:@"name"];
        [metaData setValue:pword forKey:@"password"];
        [metaData setValue:@"" forKey:@"profileImageId"];
        [user signUp:username withPassword:pword withMetadata:metaData];
        
        NSString *error = [user errorMessage];
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
            NSString *nameFilePath = [self getCacheDirectory];
            NSArray * nameArray = [[NSArray alloc]initWithObjects:username,pword, nil];
            [nameArray writeToFile:nameFilePath atomically:YES];
            [user logIn:username withPassword:pword];

            if ([[user errorMessage] length] == 0) {
                STreamUser *user = [[STreamUser alloc] init];
                [user loadUserMetadata:username response:^(BOOL succeed, NSString *error){
                    if ([error isEqualToString:username]){
                        NSMutableDictionary *dic = [user userMetadata];
                        ImageCache *imageCache = [ImageCache sharedObject];
                        [imageCache saveUserMetadata:username withMetadata:dic];
                    }
                }];
                sleep(1);
                __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                HUD.labelText = @"loading friends...";
                [self.view addSubview:HUD];
                [HUD showAnimated:YES whileExecutingBlock:^{
                    [self loadAvatar:username];
                }completionBlock:^{
                    [HUD removeFromSuperview];
                    HUD = nil;
                }];
            }
            MyFriendsViewController *myFriendVC = [[MyFriendsViewController alloc]init];
            [self.navigationController pushViewController:myFriendVC animated:YES];
        }else{
            
            UIAlertView * view  = [[UIAlertView alloc]initWithTitle:@"" message:@"User name or password error" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
            [view show];
        }
       
    }
    
        NSLog(@"");
}
-(void) loadAvatar:(NSString *)userID {
    ImageCache *imageCache = [ImageCache sharedObject];
    if ([imageCache getUserMetadata:userID]!=nil) {
        NSMutableDictionary *userMetaData = [imageCache getUserMetadata:userID];
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if ([imageCache getImage:pImageId] == nil && pImageId){
            FileCache *fileCache = [FileCache sharedObject];
            STreamFile *file = [[STreamFile alloc] init];
            if (![imageCache getImage:pImageId]){
                [file downloadAsData:pImageId downloadedData:^(NSData *imageData, NSString *oId) {
                    if ([pImageId isEqualToString:oId]){
                        [imageCache selfImageDownload:imageData withFileId:pImageId];
                        [fileCache writeFileDoc:pImageId withData:imageData];
                    }
                }];
            }
        }
    }
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
