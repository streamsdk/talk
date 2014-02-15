//
//  PhotoHandler.m
//  talk
//
//  Created by wangshuai on 13-12-22.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "PhotoHandler.h"
#import "NSBubbleData.h"
#import "UIImageViewController.h"
#import "TalkDB.h"
#import "STreamXMPP.h"
#import <arcstreamsdk/JSONKit.h>
#import <arcstreamsdk/STreamFile.h>
#import "HandlerUserIdAndDateFormater.h"
#import "DisappearImageController.h"
#import "ACKMessageDB.h"
#import "ImageCache.h"
#import "FilesUpload.h"
#import "AppDelegate.h"
#import "UploadDB.h"

@interface PhotoHandler()

@end
@implementation PhotoHandler


@synthesize controller;
@synthesize type;
-(void)receiveFile:(NSData *)data withPath:(NSString *)path forBubbleDataArray:(NSMutableArray *)bubbleData withTime:(NSString *)time forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];

    if ([fromID isEqualToString:sendID]) {
        UIImage * image = [UIImage imageWithData:data];
        NSBubbleData * bubble;
        if (time) {
             bubble = [NSBubbleData dataWithImage:image withImageTime:time withPath:path date:[handler getDate] withType:BubbleTypeSomeoneElse];
        }else{
            bubble = [NSBubbleData dataWithImage:image date:[handler getDate] type:BubbleTypeSomeoneElse];
        }
        if (otherData) {
            bubble.avatar = [UIImage imageWithData:otherData];
        }
        [bubbleData addObject:bubble];
    }
    
}

-(void) sendPhoto :(NSData *)data forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID withTime:(NSString *)time{
    
//    UIImage * _image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width*0.7, image.size.height*0.7)];
//     NSData * data = UIImageJPEGRepresentation(_image, 0.7);
    UIImage *image = [UIImage imageWithData:data];
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    
    NSString *photoPath = [[handler getPath] stringByAppendingString:@".png"];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSBubbleData * bubble;
    if (time)
        bubble = [NSBubbleData dataWithImage:image withImageTime:time withPath:photoPath date:date withType:BubbleTypeMine];
    else
        bubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    if (myData) {
        bubble.avatar = [UIImage imageWithData:myData];
    }
     [bubbleData addObject:bubble];
    
    [data writeToFile:photoPath atomically:YES];
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    if (time)
        [friendDict setObject:time forKey:@"time"];
    [friendDict setObject:photoPath forKey:@"photo"];
    [jsonDic setObject:friendDict forKey:sendID];
    NSString  *str = [jsonDic JSONString];
    
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
  
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if (time)
        [bodyDic setObject:time forKey:@"duration"];
    [bodyDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [bodyDic setObject:@"photo" forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    if ([type isEqualToString:@"photo"]) {
        type = nil;
    }else{
        UploadDB * uploadDb = [[UploadDB alloc]init];
        [uploadDb insertUploadDB:[handler getUserID] filePath:photoPath withTime:time withFrom:sendID withType:@"photo"];
    }
    
    
    ImageCache * cache = [ImageCache sharedObject];
    NSMutableArray * fileArray = [cache getFileUpload];
    FilesUpload * file = [[FilesUpload alloc]init];
    [file setTime:[NSString stringWithFormat:@"%lld", milliseconds]];
    [file setFilepath:photoPath];
    [file setBodyDict:bodyDic];
    [file setUserId:sendID];
    if (fileArray != nil && [fileArray count] != 0) {
        [cache addFileUpload:file];
        return;
    }
    [cache addFileUpload:file];
    [self fileUpload:fileArray];
    
}
-(void) fileUpload :(NSMutableArray *)file{
    
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    FilesUpload * f = [file objectAtIndex:0];
    ImageCache * cache  =[ImageCache sharedObject];
    NSData * data = [NSData dataWithContentsOfFile:f.filepath];
    
    STreamFile *sf = [[STreamFile alloc] init];
    STreamXMPP *con = [STreamXMPP sharedObject];
    
    [sf postData:data finished:^(NSString *res){
        if ([res isEqualToString:@"ok"]){
           [f.bodyDict setObject:[sf fileId] forKey:@"fileId"];
           NSString *bodyJsonData = [f.bodyDict JSONString];
           NSLog(@"body json data: %@", bodyJsonData);
            ACKMessageDB *ack = [[ACKMessageDB alloc]init];
             NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            [ack insertDB:f.time withUserID:[handler getUserID] fromID:f.userId withContent:bodyJsonData withTime:[dateFormatter stringFromDate:date] withIsMine:0];
            UploadDB * uploadDb = [[UploadDB alloc]init];
            [uploadDb deleteUploadDBFromFilepath:f.filepath];
            
           [con sendFileMessage:f.userId withFileId:[sf fileId] withMessage:bodyJsonData];
        }
        
        [cache removeFileUpload:f];
        NSMutableArray * fileArray = [cache getFileUpload];
        if (fileArray != nil && [fileArray count] != 0) {
            [self fileUpload:fileArray];
        }
        
    }byteSent:^(float bytes){
        APPDELEGATE.progressView.hidden = NO;
        APPDELEGATE.progressView.progress = bytes;
        [APPDELEGATE.activityIndicatorView startAnimating];
        APPDELEGATE.label.hidden = NO;
        APPDELEGATE.label.text = [NSString stringWithFormat:@"%.0f%%",bytes*100];
        if (bytes == 1.000000) {
            APPDELEGATE.progressView.hidden = YES;
            APPDELEGATE.label.hidden = YES;
            [APPDELEGATE.activityIndicatorView stopAnimating];
        }

        NSLog(@"byteSent:%f", bytes);
    }];
    
}

@end
