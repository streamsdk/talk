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
#import "HandlerUserIdAndDateFormater.h"
#import "DisappearImageController.h"

@interface PhotoHandler()

@end



@implementation PhotoHandler


@synthesize controller;

-(void)receiveFile:(NSData *)data withPath:(NSString *)path forBubbleDataArray:(NSMutableArray *)bubbleData withTime:(NSString *)time forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    
    if ([fromID isEqualToString:sendID]) {
        UIImage * image = [UIImage imageWithData:data];
        NSBubbleData * bubble;
        if (time) {
             bubble = [NSBubbleData dataWithImage:image withImageTime:time withPath:path date:[NSDate dateWithTimeIntervalSinceNow:0] withType:BubbleTypeSomeoneElse];
        }else{
            bubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        }
        if (otherData) {
            bubble.avatar = [UIImage imageWithData:otherData];
        }
        [bubbleData addObject:bubble];
    }
    
}

-(void) sendPhoto :(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID withTime:(NSString *)time{
    
    UIImage * _image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width*0.7, image.size.height*0.7)];
     NSData * data = UIImageJPEGRepresentation(_image, 0.7);
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    
    NSString *photoPath = [[handler getPath] stringByAppendingString:@".png"];
    
    NSBubbleData * bubble;
    if (time)
        bubble = [NSBubbleData dataWithImage:image withImageTime:time withPath:photoPath date:[NSDate dateWithTimeIntervalSinceNow:0] withType:BubbleTypeMine];
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
    [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    if (time)
        [bodyDic setObject:time forKey:@"duration"];
    [bodyDic setObject:@"photo" forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con sendFileInBackground:data toUser:sendID finished:^(NSString *res){
        NSLog(@"res:%@",res);
    }byteSent:^(float b){
        NSLog(@"byteSent:%f",b);
    }withBodyData:bodyDic];

}

-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
