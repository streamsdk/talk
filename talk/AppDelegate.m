//
//  AppDelegate.m
//  talk
//
//  Created by wangshuai on 13-10-20.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "AppDelegate.h"
#import "MainController.h"
#import "LoginViewController.h"
#import "RootViewController.h"
#import "MyFriendsViewController.h"
#import <arcstreamsdk/STreamSession.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamPush.h>
#import "FileCache.h"
#import <arcstreamsdk/STreamFile.h>
#import "TalkDB.h"
#import "AddDB.h"
#import "SearchDB.h"
#import "ACKMessageDB.h"
#import "ChatBackGround.h"
#import "ImageCache.h"
#import "STreamXMPP.h"
#import "DownloadDB.h"
#import "UploadDB.h"
#import "CopyDB.h"
//#import "TwitterConnect.h"

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect {
   
}
@end

@implementation AppDelegate

-(void) showFriendsView{
    MyFriendsViewController * friends = [[MyFriendsViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:friends];
    [self.window setRootViewController:nav];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken{
    
    NSString *tokenAsString = [[[newDeviceToken description]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //NSLog(@"device token: %@", tokenAsString);
    [STreamPush storeToken:tokenAsString];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
   
    
    _progressDict = [[NSMutableDictionary alloc]init];
    _deleteArray = [[NSMutableArray alloc]init];
    _array = [[NSMutableArray alloc]init];
    _date = [[NSDate alloc]init];
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:247.0/255.0 green:229.0/255.0 blue:227.0/255.0 alpha:1.0]];
    NSMutableDictionary *attributes= [[NSMutableDictionary alloc] init];
    
    [attributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [[UINavigationBar appearance]setBarTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance]setTitleTextAttributes:attributes];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    TalkDB * talkDB = [[TalkDB alloc ]init];
    [talkDB initDB];
    AddDB * addDb = [[AddDB alloc]init];
    [addDb initDB];
    SearchDB * searchDB=  [[SearchDB alloc]init];
    [searchDB initDB];
    ChatBackGround * chat = [[ChatBackGround alloc]init];
    [chat initDB];
    ACKMessageDB  *ack = [[ACKMessageDB alloc]init];
    [ack initDB];
    DownloadDB * downloadDB = [[DownloadDB alloc]init];
    [downloadDB initDB];
    //upload
    UploadDB *uploadDb = [[UploadDB alloc]init];
    [uploadDb initDB];
    
    CopyDB * db = [[CopyDB alloc]init];
    [db initDB];
    /*TwitterConnect * twitter = [[TwitterConnect alloc]init];
    ACAccountStore  *accountStore = [[ACAccountStore alloc] init];
    [twitter setAccountStore:accountStore];
    [twitter fetchFellowerAndFollowing:@"15Slogn"];*/
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
   
    [self doAuth];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [UIApplication sharedApplication].applicationIconBadgeNumber=application.applicationIconBadgeNumber-1;
    
    return YES;
}
-(NSString *)auth{
   
    /*[STreamSession setUpServerUrl:@"http://streamsdk.cn/api/"];
    
    [STreamSession authenticate:@"0093D2FD61600099DE1027E50C6C3F8D" secretKey:@"4EF482C15D849D04BA5D7BC940526EA3"
                      clientKey:@"01D901D6EFBA42145E54F52E465F407B" response:^(BOOL succeed, NSString *response){
                          
                          if (succeed){
                              
                          }
                          
                      }];*/
    
    /*
    [STreamSession setUpServerUrl:@"http://streamsdk.com/print/print/"];
     [STreamSession authenticate:@"7E95CF60694890DCD4CEFBF79BC3BAE4" secretKey:@"73B7C757A511B1574FDF63B3FEB638B7"
     clientKey:@"4768674EDC06477EC63AEEF8FEAB0CF8" response:^(BOOL succeed, NSString *response){
     
     if (succeed){
     
     }
     
     }];*/
    
    NSString *res = nil;
    for (int i=0; i < 5; i++){
        
        
//        [STreamSession setUpServerUrl:@"http://streamsdk.com/print/print/"];
        //[STreamSession setUpServerUrl:@"http://192.168.1.17:8081/api/"];
        //res = [STreamSession authenticate:@"7E95CF60694890DCD4CEFBF79BC3BAE4"  secretKey:@"73B7C757A511B1574FDF63B3FEB638B7" clientKey:@"4768674EDC06477EC63AEEF8FEAB0CF8" ];
        //不要用这个,这个是正在运营的
//        res = [STreamSession authenticate:@"A82C2F6E73F3D911F5E424953A1C8E62"  secretKey:@"A3C7D9386C4A4063CDE1B4A8B3820BD2" clientKey:@"C8BB14A1A961E9D391196D9F411B18D8" ];
        
        [STreamSession setUpServerUrl:@"http://streamsdk.cn/api/"];
        res = [STreamSession authenticate:@"0093D2FD61600099DE1027E50C6C3F8D" secretKey:@"4EF482C15D849D04BA5D7BC940526EA3" clientKey:@"01D901D6EFBA42145E54F52E465F407B" ];
        if ([res isEqualToString:@"auth ok"]){
            //NSLog(@"%@", res);
            RootViewController * rootVC = [[RootViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rootVC];
            [self.window setRootViewController:nav];
            break;
        }else{
            sleep(5);
        }
    }
    
    return res;

}
-(void)doAuth
{
    NSString *res = [self auth];
    if ([res isEqualToString:@"auth ok"]){
       /* NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
        NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
        NSString *loginName = nil;
        if (array && [array count]!=0)
            loginName= [array objectAtIndex:0];*/
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * loginName = [userDefaults objectForKey:@"username"];
        if (loginName!=nil && ![loginName isEqualToString:@""]) {
            STreamUser *user = [[STreamUser alloc] init];
            [user loadUserMetadata:loginName response:^(BOOL succeed, NSString *error){
                if ([error isEqualToString:loginName]){
                    NSMutableDictionary *dic = [user userMetadata];
                    ImageCache *imageCache = [ImageCache sharedObject];
                    [imageCache saveUserMetadata:loginName withMetadata:dic];
                }
            }];
            [self showFriendsView];
        }else{
            RootViewController * rootVC = [[RootViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rootVC];
            [self.window setRootViewController:nav];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"网络没有信号" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alert show];
    }
    
}



- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    //NSLog(@"STR: %@", str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //NSLog(@"str %@", [NSString stringWithFormat:@"%d", [userInfo count]]);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{    
    /*if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]){
        [application setKeepAliveTimeout:600 handler:^{
            STreamXMPP *xmpp = [STreamXMPP sharedObject];
            [xmpp disconnect];
        }];
    }*/
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:@""];
   STreamXMPP *xmpp = [STreamXMPP sharedObject];
   [xmpp disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:@"username"];
    if (!username) {
        RootViewController * rootVC = [[RootViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rootVC];
        [self.window setRootViewController:nav];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
