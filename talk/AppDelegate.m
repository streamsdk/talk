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
#import "FileCache.h"
#import <arcstreamsdk/STreamFile.h>
#import "TalkDB.h"
#import "AddDB.h"
#import "SearchDB.h"
#import "ChatBackGround.h"
#import "ImageCache.h"
#import "STreamXMPP.h"
//#import "TwitterConnect.h"

@implementation AppDelegate

-(void) showFriendsView{
    MyFriendsViewController * friends = [[MyFriendsViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:friends];
    [self.window setRootViewController:nav];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:247.0/255.0 green:229.0/255.0 blue:227.0/255.0 alpha:1.0]];
    TalkDB * talkDB = [[TalkDB alloc ]init];
    [talkDB initDB];
    AddDB * addDb = [[AddDB alloc]init];
    [addDb initDB];
    SearchDB * searchDB=  [[SearchDB alloc]init];
    [searchDB initDB];
    ChatBackGround * chat = [[ChatBackGround alloc]init];
    [chat initDB];
    
    /*TwitterConnect * twitter = [[TwitterConnect alloc]init];
    ACAccountStore  *accountStore = [[ACAccountStore alloc] init];
    [twitter setAccountStore:accountStore];
    [twitter fetchFellowerAndFollowing:@"15Slogn"];*/
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

           //    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
     /*[STreamSession authenticate:@"0093D2FD61600099DE1027E50C6C3F8D" secretKey:@"4EF482C15D849D04BA5D7BC940526EA3"
                      clientKey:@"01D901D6EFBA42145E54F52E465F407B" response:^(BOOL succeed, NSString *response){
                          
                          if (succeed){

                          }
                          
                      }];*/
    
    
    [STreamSession authenticate:@"7E95CF60694890DCD4CEFBF79BC3BAE4" secretKey:@"73B7C757A511B1574FDF63B3FEB638B7"
                      clientKey:@"4768674EDC06477EC63AEEF8FEAB0CF8" response:^(BOOL succeed, NSString *response){
                          
                          if (succeed){
                              
                          }
                          
                      }];

    [NSThread sleepForTimeInterval:5];
    
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString *loginName = nil;
    if (array && [array count]!=0)
        loginName= [array objectAtIndex:0];
    if (loginName) {
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:loginName response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:loginName]){
                NSMutableDictionary *dic = [user userMetadata];
                ImageCache *imageCache = [ImageCache sharedObject];
                [imageCache saveUserMetadata:loginName withMetadata:dic];
            }
        }];

        ImageCache *imageCache = [ImageCache sharedObject];
        if ([imageCache getUserMetadata:loginName]!=nil) {
            NSMutableDictionary *userMetaData = [imageCache getUserMetadata:loginName];
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

        [self showFriendsView];
    }else{
        RootViewController * rootVC = [[RootViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rootVC];
        [self.window setRootViewController:nav];
    }

   

    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
