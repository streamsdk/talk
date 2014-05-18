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
#import <arcstreamsdk/STreamFile.h>
#import "ImageCache.h"
#import "FileCache.h"
@implementation DownloadAvatar

-(UIImage *)loadAvatar:(NSString *) userID {
    __block UIImage *avatarImage = [UIImage imageNamed:@"noavatar.png"];
    ImageCache *imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:userID];
    if (userMetaData!=nil) {
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if (pImageId!=nil && ![pImageId isEqualToString:@""] &&[imageCache getImage:pImageId]==nil){
            FileCache *fileCache = [FileCache sharedObject];
            STreamFile *file = [[STreamFile alloc] init];
            [file downloadAsData:pImageId downloadedData:^(NSData *imageData, NSString *oId) {
                if ([pImageId isEqualToString:oId] && [imageData length] != 0){
                    [imageCache selfImageDownload:imageData withFileId:pImageId];
                    [fileCache writeFileDoc:pImageId withData:imageData];
                    avatarImage = [UIImage imageWithData: [imageCache getImage:pImageId]];
                }
            }];
            
        }else{
            if (pImageId!=nil && ![pImageId isEqualToString:@""])
                avatarImage = [UIImage imageWithData: [imageCache getImage:pImageId]];
        }
    }
    return avatarImage;
}


@end
