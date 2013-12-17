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
#import <arcstreamsdk/STreamSession.h>
#import <arcstreamsdk/STreamUser.h>
#import "FileCache.h"
#import <arcstreamsdk/STreamFile.h>
#import "TalkDB.h"
#import "ImageCache.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:247.0/255.0 green:229.0/255.0 blue:227.0/255.0 alpha:1.0]];
    TalkDB * talkDB = [[TalkDB alloc ]init];
    [talkDB initDB];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    /*NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString *loginName = nil;
    if (array && [array count]!=0)
        loginName= [array objectAtIndex:0];
    if (loginName) {
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

    }*/
        //    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
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
