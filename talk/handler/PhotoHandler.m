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
#import "ACKMessageDB.h"
#import "ImageCache.h"
#import "FileUpload.h"
@interface PhotoHandler()

@end
@implementation PhotoHandler


@synthesize controller;

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
    
    ImageCache * cache = [ImageCache sharedObject];
    FileUpload * file = [[FileUpload alloc]init];
    [file setFriendId:sendID];
    [file setFileData:data];
    [file setBodyDic:bodyDic];
    [cache setFileUpload:file withTime:[dateFormatter stringFromDate:date]];
    NSArray * key = [[cache getFileUpload]allKeys];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    NSMutableArray *myArray=[[NSMutableArray alloc]initWithCapacity:0];
    if (key && [key count]!=0) {
        for (NSString * k in key) {
            [dict setObject:k forKey:@"time"];
            [myArray addObject:dict];
        }
    }
    NSMutableArray *dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    [dataArray addObjectsFromArray:myArray];
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc]initWithKey:@"time" ascending:YES];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    NSArray *keyArray=[dataArray sortedArrayUsingDescriptors:sortDescriptors];
    NSMutableArray *sortArray = [[NSMutableArray alloc]init];
    if (keyArray && [keyArray count]!=0) {
        for (int i=0; i<[keyArray count]; i++) {
           [sortArray addObject:[[keyArray objectAtIndex:i] objectForKey:@"time"]];
        }
    }

    ACKMessageDB *ack = [[ACKMessageDB alloc]init];
    [ack insertDB:[NSString stringWithFormat:@"%lld", milliseconds] withUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    STreamXMPP *con = [STreamXMPP sharedObject];
    if(sortArray && [sortArray count]!=0) {
        __block float byte=0.0;
        FileUpload * f = [[cache getFileUpload] objectForKey:[sortArray objectAtIndex:0]];
        [con sendFileInBackground:f.fileData toUser:f.friendId finished:^(NSString *res){
            NSLog(@"res:%@",res);
        }byteSent:^(float b){
            if (b==1.000000) {
                byte = 1.000000;
                [cache removefileUpload:[sortArray objectAtIndex:0]];
                [sortArray removeObjectAtIndex:0];
                
            }
            NSLog(@"byteSent:%f",b);
        }withBodyData:f.bodyDic];
//        if (byte != 1.000000) {
//            sleep(1);
//        }    
    }
}

-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
