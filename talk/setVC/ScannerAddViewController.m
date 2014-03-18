//
//  ScannerAddViewController.m
//  talk
//
//  Created by wangsh on 14-3-17.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "ScannerAddViewController.h"
#import "HandlerUserIdAndDateFormater.h"
#import "ImageCache.h"
#import "DownloadAvatar.h"
#import "MBProgressHUD.h"
#import "AddDB.h"
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/JSONKit.h>
#import "STreamXMPP.h"
#import "SearchDB.h"
#import "SettingViewController.h"
@interface ScannerAddViewController ()

@end

@implementation ScannerAddViewController

@synthesize name;
@synthesize status;

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
    self.view.backgroundColor = [UIColor lightGrayColor];
    DownloadAvatar * down = [[DownloadAvatar alloc]init];
    [down loadAvatar:name];
    UIImage * icon = [down readAvatar:name];
    CGFloat height = 100;
    UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, height,100, 100)];
    CALayer *l = [imageview layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:8.0];
    imageview.image = icon;
    [self.view addSubview:imageview];
    
    height = height+ imageview.frame.size.height + 10;
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 60)];
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor =[UIColor clearColor];
    label.text = name;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];

    height = height+ label.frame.size.height + 10;
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake((self.view.frame.size.width-120)/2, height, 120, 40)];
    [button setTitle:@"Add" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blackColor]];
    CALayer *ll = [button layer];
    [ll setMasksToBounds:YES];
    [ll setCornerRadius:8.0];
//    [button setImage:[UIImage imageNamed:@"addfriend.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frameBack = CGRectMake(10, 20, 50, 40);
    [backButton setFrame:frameBack];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}
-(void)back{
    [[[[[UIApplication sharedApplication]delegate] window]rootViewController]dismissViewControllerAnimated:NO completion:NULL];
}
-(void)addFriends {
    NSString * str;
    if (status)     str = [NSString stringWithFormat:@"Do you want to add %@ as a friend?",name];
    else str =[NSString stringWithFormat:@"Are you sure the invitation sent to %@?",name];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    alert.delegate = self;
    [alert show];
}
-(void)add{
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * db = [[AddDB alloc]init];
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"add friend ...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [db updateDB:[handle getUserID] withFriendID:name withStatus:@"friend"];
        STreamObject * so = [[STreamObject alloc]init];
        [so setCategory:[handle getUserID]];
        [so setObjectId:name];
        [so addStaff:@"status" withObject:@"friend"];
        [so updateInBackground];
        
        STreamObject *my = [[STreamObject alloc]init];
        [my setCategory:name];
        [my setObjectId:[handle getUserID]];
        [my addStaff:@"status" withObject:@"friend"];
        [my updateInBackground];
        
        STreamXMPP *con = [STreamXMPP sharedObject];
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        [jsonDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
        [jsonDic setObject:@"friend" forKey:@"type"];
        [jsonDic setObject:[handle getUserID] forKey:@"username"];
        [jsonDic setObject:name forKey:@"friendname"];
        NSString *jsonSent = [jsonDic JSONString];
        [con sendMessage:name withMessage:jsonSent];
        
    }completionBlock:^{
        [[[[[UIApplication sharedApplication]delegate] window]rootViewController]dismissViewControllerAnimated:NO completion:NULL];
        [HUD removeFromSuperview];
        HUD = nil;
    }];

}
-(void) sendRequest{
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName= [handler getUserID];
    STreamObject * so = [[STreamObject alloc]init];
    [so setCategory:loginName];
    [so setObjectId:name];
    [so addStaff:@"status" withObject:@"sendRequest"];
    [so updateInBackground];
    
    STreamObject *my = [[STreamObject alloc]init];
    [my setCategory:name];
    [my setObjectId:loginName];
    [my addStaff:@"status" withObject:@"request"];
    [my updateInBackground];
    
    SearchDB * db = [[SearchDB alloc]init];
    //    [myTableview reloadData];
    NSMutableArray *sendData=[db  readSearchDB:[handler getUserID]];
    if (![sendData containsObject:name]) {
        [db insertDB:[handler getUserID] withFriendID:name];
    }
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    [jsonDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [jsonDic setObject:@"request" forKey:@"type"];
    [jsonDic setObject:loginName forKey:@"username"];
    [jsonDic setObject:name forKey:@"friendname"];
    NSString *jsonSent = [jsonDic JSONString];
    [con sendMessage:name withMessage:jsonSent];
    [[[[[UIApplication sharedApplication]delegate] window]rootViewController]dismissViewControllerAnimated:NO completion:NULL];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if ([status isEqualToString:@"request"]) {
            [self add];
        }else{
            [self sendRequest];
        }
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
