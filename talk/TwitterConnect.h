//
//  TwitterConnect.h
//  talk
//
//  Created by wangshuai on 11/01/2014.
//  Copyright (c) 2014 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TwitterConnect : NSObject

-(void)fetchFellowerAndFollowing:(NSString *)userName;
-(void)fetchAccounts:(NSString *)userName;

@property (nonatomic) ACAccountStore *accountStore;

@end
