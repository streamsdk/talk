//
//  TwitterConnect.m
//  talk
//
//  Created by wangshuai on 11/01/2014.
//  Copyright (c) 2014 wangshuai. All rights reserved.
//

#import "TwitterConnect.h"

@implementation TwitterConnect

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchAccounts:(NSString *)userName{
    
    if ([self userHasAccessToTwitter]) {
        
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
        
        for (ACAccount *acc in twitterAccounts){
            
            
            
        }
    }
}



- (void)fetchFellowerAndFollowing:(NSString *)userName{
    
    
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                
                NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
                NSDictionary *params = @{@"screen_name" : userName};
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                [request setAccount:[twitterAccounts lastObject]];
                [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                    if (responseData) {
                        if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                            
                            NSError *jsonError;
                            NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                            if (timelineData) {
                                //NSLog(@"Timeline Response: %@\n", timelineData);
                                
                                NSArray *users = [timelineData objectForKey:@"users"];
                                for (NSDictionary *user in users){
                                    NSString *name = [user objectForKey:@"name"];
                                    NSString *screenName = [user objectForKey:@"screen_name"];
                                    NSString *userId = [user objectForKey:@"id"];
                                    NSString *profileUrl = [user objectForKey:@"profile_image_url"];
                                    
                                    NSLog(@"follower name: %@", name);
                                    NSLog(@"follower screen name: %@", screenName);
                                    NSLog(@"follower user id: %@", userId);
                                    NSLog(@"follower profile url: %@", profileUrl);
                                }
                            }
                            else {
                                // Our JSON deserialization went awry
                                NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                            }
                        }
                        else {
                            // The server did not respond ... were we rate-limited?
                            NSLog(@"The response status code is %d", urlResponse.statusCode);
                        }
                    }
                }];
                
            }
        }];
    }
    
}



@end
