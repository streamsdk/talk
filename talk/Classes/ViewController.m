//
//  ViewController.m
//  xmppdemo
//
//  Created by wang shuai on 27/06/2013.
//  Copyright (c) 2013 streamsdk. All rights reserved.
//

#import "ViewController.h"
#import "STreamXMPP.h"
#import <arcstreamsdk/STreamSession.h>
#import <arcstreamsdk/STreamFile.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  

    
    [STreamSession authenticate:@"0093D2FD61600099DE1027E50C6C3F8D" secretKey:@"4EF482C15D849D04BA5D7BC940526EA3"
                      clientKey:@"01D901D6EFBA42145E54F52E465F407B" response:^(BOOL succeed, NSString *response){
                          
        if (succeed){
                              
            STreamXMPP *con = [STreamXMPP sharedObject];
            [con connect:@"test2" withPassword:@"111"];
            //[con sendMessage:@"test2" withMessage:@"hello from test1"];
            [con setXmppDelegate:self];
        }
                          
    }];
    
    [NSThread sleepForTimeInterval:5];
   
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didAuthenticate{
    
//    STreamXMPP *con = [STreamXMPP sharedObject];
//    [con sendMessage:@"test2" withMessage:@"hello from test1"];

    
    NSString *dataStr = @"this is the data to be send to want";
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con sendFileInBackground:data toUser:@"test2" finished:^(NSString *res){
    
        NSLog(@"%@", res);
        
    }byteSent:^(float b){
        
        NSLog(@"%@", [NSString stringWithFormat:@"%1.6f", b]);
    } withBodyData:@"nil"];
  
     NSLog(@"");
}

- (void)didReceiveFile:(NSString *)fileId{
    STreamFile *sf = [[STreamFile alloc] init];
    NSData *data = [sf downloadAsData:fileId];
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", dataStr);
    
}

- (void)didReceiveRosterItems:(NSMutableArray *)rosterItem{
    NSLog(@"");
}

- (void)didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"message :%@",message);
}

- (void)didNotAuthenticate:(DDXMLElement *)error{
    
  NSLog(@"");
}

- (void)didReceivePresence:(XMPPPresence *)presence{
 
    NSString *presenceType = [presence type];
    if ([presenceType isEqualToString:@"subscribe"]){
//        STreamXMPP *con = [STreamXMPP sharedObject];
    //    [con se];
    }
    if ([presenceType isEqualToString:@"available"]){
        NSLog(@"");
    }
    if ([presenceType isEqualToString:@"unavailable"]){
        NSLog(@"");
    }
   // STreamSDKXMPPConnection *con = [STreamSDKXMPPConnection sharedObject];
   // [con sendSubscribed:presence];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
