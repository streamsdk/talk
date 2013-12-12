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

@interface SignUpViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate>
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
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    [bgView setImage:[UIImage imageNamed:@"background.png"]];
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
    if (userName && password && [secondWord isEqualToString:secondWord]) {
        
        STreamUser *user = [[STreamUser alloc] init];
        NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
        [metaData setValue:username forKey:@"name"];
        [metaData setValue:pword forKey:@"password"];
        [user signUp:userName.text withPassword:pword withMetadata:metaData];
        
        NSString *error = [user errorMessage];
        if ([error isEqualToString:@""]){
            STreamCategoryObject * sto = [[STreamCategoryObject alloc]initWithCategory:username];
            [sto createNewCategoryObject:^(BOOL succeed, NSString *response){
                
                if (succeed)
                    NSLog(@"succeed");
                else
                    NSLog(@"failed");
              }];
        }else{
            
            UIAlertView * view  = [[UIAlertView alloc]initWithTitle:@"" message:@"用户名或密码错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [view show];
        }
        
        //avatar
        STreamObject * so = [[STreamObject alloc]init];
        [so setObjectId:[username stringByAppendingString:@"Avatar"]];
        [so addStaff:@"avatar" withObject:@"nil"];
        [so createNewObject:^(BOOL succeed, NSString *objectId) {
            if (succeed) {
                NSLog(@"objectId:%@",objectId);
            }
        }];

        LoginViewController * loginVC = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    
        NSLog(@"");
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
