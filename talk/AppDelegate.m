//
//  AppDelegate.m
//  talk
//
//  Created by wangshuai on 13-10-20.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MainController.h"
#import "LoginViewController.h"
#import "RootViewController.h"
#import "PlayerViewController.h"

#import <arcstreamsdk/STreamSession.h>
#import "TalkDB.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:247.0/255.0 green:229.0/255.0 blue:227.0/255.0 alpha:1.0]];
    TalkDB * talkDB = [[TalkDB alloc ]init];
    [talkDB initDB];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
   
    
    [STreamSession authenticate:@"0093D2FD61600099DE1027E50C6C3F8D" secretKey:@"4EF482C15D849D04BA5D7BC940526EA3"
                      clientKey:@"01D901D6EFBA42145E54F52E465F407B" response:^(BOOL succeed, NSString *response){
                          
                          if (succeed){

                          }
                          
                      }];
    [NSThread sleepForTimeInterval:5];
    RootViewController * rootVC = [[RootViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rootVC];
    [self.window setRootViewController:nav];

    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}
-(void) showPlayerView {
    
    PlayerViewController * player = [[PlayerViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:player];
    [self.window setRootViewController:nav];
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
