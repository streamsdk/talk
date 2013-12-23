//
//  PhotoHandler.m
//  talk
//
//  Created by wangshuai on 13-12-22.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "PhotoHandler.h"
#import "NSBubbleData.h"
#import "PlayerDelegate.h"
#import "UIImageViewController.h"
#import "TalkDB.h"
#import "STreamXMPP.h"
#import <arcstreamsdk/JSONKit.h>

@interface PhotoHandler() <PlayerDelegate>{}


@end



@implementation PhotoHandler


@synthesize controller;

- (NSMutableDictionary *)receiveFile:(NSData *)data forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
   
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    if ([fromID isEqualToString:sendID]) {
        UIImage * image = [UIImage imageWithData:data];
        NSBubbleData * bubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        if (otherData)
            bubble.avatar = [UIImage imageWithData:otherData];
        bubble.delegate = self;
        [bubbleData addObject:bubble];
    }
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *photoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.png", [formater stringFromDate:[NSDate date]]];
    [data writeToFile:photoPath atomically:YES];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:photoPath forKey:@"photo"];
    [jsonDic setObject:friendDict forKey:sendID];

    return jsonDic;
    
    
}

-(NSString *)getUserID{
    
    NSString * userID =nil;
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    if (array && [array count]!=0) {
        
        userID = [array objectAtIndex:0];
    }
    return userID;
}

-(void) sendPhoto :(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID{
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    NSData * data = UIImageJPEGRepresentation(image, 0.7);
    UIImage * _image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width*0.7, image.size.height*0.7)];
    NSBubbleData * bubbledata = [NSBubbleData dataWithImage:_image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    if (myData) {
        bubbledata.avatar = [UIImage imageWithData:myData];
    }
    [bubbleData addObject:bubbledata];
    
    bubbledata.delegate = self;
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *photoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.png", [formater stringFromDate:[NSDate date]]];
    [data writeToFile:photoPath atomically:YES];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:photoPath forKey:@"photo"];
    [jsonDic setObject:friendDict forKey:sendID];
    NSString  *str = [jsonDic JSONString];
    
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [db insertDBUserID:[self getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con sendFileInBackground:data toUser:sendID finished:^(NSString *res){
        NSLog(@"res:%@",res);
    }byteSent:^(float b){
        NSLog(@"byteSent:%f",b);
    }withBodyData:@"photo"];

}

-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)bigImage:(UIImage *)image{
    UIImageViewController * iView = [[UIImageViewController alloc]init];
    iView.image = image;
    iView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [controller presentViewController:iView animated:YES completion:nil];
}

-(void) playerVideo:(NSString *)path{
    
    
}




@end
