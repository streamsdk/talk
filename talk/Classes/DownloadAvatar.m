//
//  DownloadAvatar.m
//  talk
//
//  Created by wangsh on 14-2-19.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "DownloadAvatar.h"
#import <arcstreamsdk/STreamSession.h>
#import "ImageCache.h"

@implementation DownloadAvatar

-(void)loadAvatar:(NSString *) userID {
   
    ImageCache *imageCache = [ImageCache sharedObject];
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
                                          [imageCache selfImageDownload:data withFileId:pImageId];
                                   }];

        }
    }

}
@end
