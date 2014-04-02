//
//  Voice.h
//  talk
//
//  Created by wangsh on 13-11-5.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
@interface Voice : NSObject

@property(nonatomic,retain) NSString * recordPath;
@property(nonatomic) float recordTime;
@property (nonatomic,strong) MBProgressHUD * HUD;

-(NSString*)getCurrentTimeString;

-(NSString*)getCacheDirectory;

-(void) startRecordWithPath;

-(void) stopRecordWithCompletionBlock:(void (^)())completion;

-(void) cancelled;

@end
