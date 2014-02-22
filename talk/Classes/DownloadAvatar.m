//
//  DownloadAvatar.m
//  talk
//
//  Created by wangsh on 14-2-19.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "DownloadAvatar.h"
#import <arcstreamsdk/STreamSession.h>
#import <arcstreamsdk/STreamUser.h>
#import "ImageCache.h"
#import "FileCache.h"
@implementation DownloadAvatar

-(void)loadAvatar:(NSString *) userID {
   
    ImageCache *imageCache = [ImageCache sharedObject];
    FileCache * filecache = [FileCache sharedObject];
    if ([imageCache getUserMetadata:userID]!=nil) {
        NSMutableDictionary *userMetaData = [imageCache getUserMetadata:userID];
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if (pImageId!=nil && ![pImageId isEqualToString:@""] &&[imageCache getImage:pImageId]==nil){
            NSString *urlString = [STreamSession getFileObjectDownloadUrl:pImageId];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                                       NSLog(@"response = %@, error = %@",response,error);
                                       if (data && [data length] != 0){
                                          [imageCache selfImageDownload:data withFileId:pImageId];
                                          [filecache writeFileDoc:pImageId withData:data];
                                       }
                                   }];

        }
    }else{
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:userID response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:userID]){
                NSMutableDictionary *dic = [user userMetadata];
                ImageCache *imageCache = [ImageCache sharedObject];
                [imageCache saveUserMetadata:userID withMetadata:dic];
            }
        }];
    }

}

-(UIImage *)readAvatar:(NSString *)userID {
    UIImage * avatarImg = [UIImage imageNamed:@"noavatar.png"];
    ImageCache *imageCache = [ImageCache sharedObject];
    if ([imageCache getUserMetadata:userID]!=nil) {
        NSMutableDictionary *userMetaData = [imageCache getUserMetadata:userID];
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if (pImageId!=nil && ![pImageId isEqualToString:@""] &&[imageCache getImage:pImageId]!=nil){
            avatarImg = [UIImage imageWithData: [imageCache getImage:pImageId]];
        }else{
             avatarImg = [UIImage imageNamed:@"noavatar.png"];
        }
    }else{
        avatarImg= [UIImage imageNamed:@"noavatar.png"];
    }
    return avatarImg;
}
@end
