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
#import "TearmServiceViewController.h"
#import "PrivacyPoolicyViewController.h"
#import "AddDB.h"

@interface SignUpViewController ()<UIActionSheetDelegate>
{
    UIActionSheet* actionSheet;
}
@end

@implementation SignUpViewController

@synthesize userName,password;

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
    self.title = @"Sign Up";
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
    userName.placeholder = @"Enter User Name";
    [bgView addSubview:userName];
    
    height = height+userName.frame.size.height +10;
    password = [createUI setTextFrame:CGRectMake(20, height , viewFrame.size.width-40, 40)];
    password.keyboardType = UIKeyboardTypeAlphabet;
    [password setSecureTextEntry:YES];
    password.delegate = self;
    password.placeholder = @"Enter password";
    [bgView addSubview:password];
    
    height = height +password.frame.size.height+5;
    /*surePassword = [createUI setTextFrame:CGRectMake(20, height ,viewFrame.size.width-40, 40)];
    surePassword.keyboardType = UIKeyboardTypeAlphabet;
    [surePassword setSecureTextEntry:YES];
    surePassword.delegate = self;
    surePassword.placeholder = @"input password again";
    [bgView addSubview:surePassword];*/
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(20, height ,viewFrame.size.width-100, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @"By creating an account,you agree to the";
    [bgView addSubview:label];
    
    UIButton * terms = [UIButton buttonWithType:UIButtonTypeCustom];
    [terms setFrame:CGRectMake(viewFrame.size.width-110, height ,80, 20)];
    [terms setTitle:@"Terms of Use" forState:UIControlStateNormal];
    [terms setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    terms.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    [terms addTarget:self action:@selector(Terms) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:terms];
    
    height = height +label.frame.size.height;
    UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(20, height ,viewFrame.size.width-100, 20)];
    [label2 setBackgroundColor:[UIColor clearColor]];
    label2.font = [UIFont systemFontOfSize:10];
    label2.text = @"and You acknowledge that you have read the";
    [bgView addSubview:label2];
    
    UIButton * privacy = [UIButton buttonWithType:UIButtonTypeCustom];
    [privacy setFrame:CGRectMake(viewFrame.size.width-100, height ,100, 20)];
    [privacy setTitle:@"Privacy Policy." forState:UIControlStateNormal];
    privacy.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    [privacy setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [privacy addTarget:self action:@selector(privacy) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:privacy];

    height = height +label.frame.size.height+10;
    UIButton *signUpButton = [createUI setButtonFrame:CGRectMake(20, height , viewFrame.size.width-40, 50) withTitle:@"SIGN UP"];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setBackgroundColor:[UIColor blackColor]];
    [signUpButton addTarget:self action:@selector(signUpUser) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:signUpButton];

}
-(void) Terms {
    TearmServiceViewController * tearm = [[TearmServiceViewController alloc]init];
    [self.navigationController pushViewController:tearm animated:NO];
}
-(void) privacy{
    PrivacyPoolicyViewController *privacy = [[PrivacyPoolicyViewController alloc] init];
    [self.navigationController pushViewController:privacy animated:YES];
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
    
    AddDB * addDb = [[AddDB alloc]init];
    [addDb insertDB:myUserName withFriendID:friendUserName withStatus:@"friend"];

    
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
    
     AddDB * addDb = [[AddDB alloc]init];
     [addDb insertDB:myUserName withFriendID:friendUserName withStatus:@"request"];
}



-(void )signUpUser {
    [userName resignFirstResponder];
    NSString *username = userName.text;
    username = [username lowercaseString];
    NSString *pword = password.text;
//    NSString *secondWord = surePassword.text;
    if ([self findchar:username]) {
        return;
    }
    if (username!=nil && ![username isEqualToString:@""] && pword!=nil && ![pword  isEqualToString:@""]) {
        
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
        HUD.labelText = @"Adding you as a new user, Please wait...";
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
                
                
                [self addAsFriend:username withFriend:@"coolchat"];
                [self addAsFriendRequest:username withFriend:@"maria"];
                
                STreamObject *myObject = [[STreamObject alloc] init];
                NSMutableString *userid = [[NSMutableString alloc] init];
                [userid appendString:username];
                [userid appendString:@"status"];
                [myObject setObjectId:userid];
                [myObject createNewObject:^(BOOL succeed, NSString *response){}];
                
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
-(BOOL)findchar:(NSString * )name{
    //!*'();:@&=+$,/?%#[]"
    if([name rangeOfString:@" "].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"space is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"!"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character ! is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"*"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character * is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"'"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character ' is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"("].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character ( is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@")"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character ) is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    } if([name rangeOfString:@";"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character ; is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@":"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character : is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"@"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character @ is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"&"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character & is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"="].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character = is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"+"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character + is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"$"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character $ is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@","].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character , is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"/"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character / is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"?"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character ? is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"%"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character % is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"#"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character # is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"["].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character [ is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    if([name rangeOfString:@"]"].location !=NSNotFound)
    {
        UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"" message:@"character ] is not allowed to use as user name" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    
    return NO;
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
