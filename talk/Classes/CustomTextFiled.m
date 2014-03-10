//
//  CustomTextFiled.m
//  talk
//
//  Created by wangsh on 14-3-9.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "CustomTextFiled.h"
#import <arcstreamsdk/JSONKit.h>
#import "ImageCache.h"
#import "CopyPhotoHandler.h"
#import "AppDelegate.h"
#import "HandlerUserIdAndDateFormater.h"

@implementation CustomTextFiled

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)showMenu:(id)cell{
    [self becomeFirstResponder];
    UIMenuController * menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.bounds inView:self];
    [menu setMenuVisible: YES animated: YES];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(cut:)){
        return NO;
    }
    else if(action == @selector(copy:)){
        return NO;
    }
    else if(action == @selector(paste:)){
        return YES;
    }
    else if(action == @selector(select:)){
        return NO;
    }
    else if(action == @selector(selectAll:)){
        return NO;
    }
    else
    {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)paste:(id)sender{
    NSString * contents =[[UIPasteboard generalPasteboard] string];
    NSData *jsonData = [contents dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *chatDic = [decoder objectWithData:jsonData];
    NSString *photopath=[chatDic objectForKey:@"photo"];
    NSString * videopath = [chatDic objectForKey:@"filepath"];
    UIImage *copyImage;
    if (photopath!=nil || videopath!= nil) {
        if (photopath)
            copyImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:photopath]];
        if (videopath)
            copyImage = APPDELEGATE.image;
        CustomAlertView * alertView = [[CustomAlertView alloc]init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300,200)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.frame.size.width-120)/2, 10, 120, 160)];
        [imageView setImage:copyImage];
        [view addSubview:imageView];
        [alertView setContainerView:view];
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Send", nil]];
        [alertView setDelegate:self];
        [alertView setUseMotionEffects:true];
        [alertView show];
        [self resignFirstResponder];
    }else{
        self.text = contents;
    }
}

- (void)drawRect:(CGRect)rect
{
    UITapGestureRecognizer *copyGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [self addGestureRecognizer:copyGesture];
} 
-(void) showAlertview {
    }
- (void)customButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex =%d",buttonIndex);
    CopyPhotoHandler * cHandler =[[CopyPhotoHandler alloc]init];
    if (buttonIndex == 1) {
        [alertView close];
        NSString * contents =[[UIPasteboard generalPasteboard] string];
        NSData *jsonData = [contents dataUsingEncoding:NSUTF8StringEncoding];
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        NSDictionary *chatDic = [decoder objectWithData:jsonData];
        NSString *photopath=[chatDic objectForKey:@"photo"];
        NSString * videopath = [chatDic objectForKey:@"filepath"];
        UIImage *image;
        NSString * type;
        if (photopath){
            type = @"photo";
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:photopath]];
        }
        if (videopath){
            type = @"video";
            image = APPDELEGATE.image;
        }
        ImageCache * imageCache = [ImageCache sharedObject];
        HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
        NSMutableDictionary *userMetaData = [imageCache getUserMetadata:[handler getUserID]];
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        NSData *myData = [imageCache getImage:pImageId];
        [cHandler sendPhoto:image withdate:APPDELEGATE.date forBubbleDataArray:APPDELEGATE.array forBubbleMyData:myData withFileType:type];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"send" object:nil];
    }
    
}@end
