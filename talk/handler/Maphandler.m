//
//  Maphandler.m
//  talk
//
//  Created by wangsh on 14-3-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "Maphandler.h"
#import <arcstreamsdk/JSONKit.h>
#import "TalkDB.h"
#import "NSBubbleData.h"
#import "STreamXMPP.h"
#import "HandlerUserIdAndDateFormater.h"
#import "UploadDB.h"
#import "ImageCache.h"


@implementation Maphandler
@synthesize isfromUploadDB,mappath,uploadDate;

- (void)receiveAddress:(NSString *)receiveAddress latitude:(float)latitude longitude:(float)longitude withImage:(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    if ([fromID isEqualToString:sendID]) {
        NSBubbleData *sendBubble = [NSBubbleData dataWithAddress:receiveAddress latitude:latitude longitude:longitude withImage:image date:[handler getDate] type:BubbleTypeSomeoneElse path:@""];
        if (otherData)
            sendBubble.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:sendBubble];
    }

}

-(void) sendAddress :(NSString *)address latitude:(float)latitude longitude:(float)longitude withImage:(UIImage *)image forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID{

    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString *mapPath = [[handler getPath] stringByAppendingString:@".png"];
    
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    [bodyDic setObject:address forKey:@"address"];
    [bodyDic setObject:[NSString stringWithFormat:@"%f",latitude] forKey:@"latitude"];
    [bodyDic setObject:[NSString stringWithFormat:@"%f",longitude]  forKey:@"longitude"];
    [bodyDic setObject:@"map" forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    
    ImageCache *cache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata = [cache getUserMetadata:sendID];
    if (userMetadata && [userMetadata objectForKey:@"token"]){
        [bodyDic setObject:[userMetadata objectForKey:@"token"] forKey:@"token"];
    }
    
    NSMutableArray * fileArray = [cache getFileUpload];
    FilesUpload * file = [[FilesUpload alloc]init];
    [file setTime:[NSString stringWithFormat:@"%lld", milliseconds]];
    
    [file setBodyDict:bodyDic];
    [file setUserId:sendID];
    [file setChatId:[NSString stringWithFormat:@"%lld", milliseconds]];
    [file setType:@"map"];
    if (isfromUploadDB) {
        [file setFilepath:mappath];
        [file setDate:uploadDate];
        NSMutableDictionary * addressDict = [[NSMutableDictionary alloc]init];
        [addressDict setObject:address forKey:@"address"];
        [addressDict setObject:mapPath forKey:@"path"];
        [addressDict setObject:[NSString stringWithFormat:@"%f",latitude] forKey:@"latitude"];
        [addressDict setObject:[NSString stringWithFormat:@"%f",longitude]  forKey:@"longitude"];
        [file setJsonDict:addressDict];
        if (fileArray != nil && [fileArray count] != 0) {
            FilesUpload * f =[fileArray objectAtIndex:0];
            long long ftime = [f.time longLongValue];
            if ((milliseconds/1000.0 - ftime/1000.0)<8) {
                [cache addFileUpload:file];
                return;
            }
        }else{
            [cache addFileUpload:file];
        }
        
        [super doFileUpload:fileArray];
        isfromUploadDB = NO;
    }else{
        [file setFilepath:mapPath];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSBubbleData * bubble = [NSBubbleData dataWithAddress:address latitude:latitude longitude:longitude withImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine path:mapPath];
        if (myData) {
            bubble.avatar = [UIImage imageWithData:myData];
        }
        [bubbleData addObject:bubble];
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        [data writeToFile:mapPath atomically:YES];
        
        NSMutableDictionary * jsonDic = [[NSMutableDictionary alloc]init];
        NSMutableDictionary * addressDict = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
        [addressDict setObject:address forKey:@"address"];
        [addressDict setObject:mapPath forKey:@"path"];
        [addressDict setObject:[NSString stringWithFormat:@"%f",latitude] forKey:@"latitude"];
        [addressDict setObject:[NSString stringWithFormat:@"%f",longitude]  forKey:@"longitude"];
        [friendDict setObject:addressDict forKey:@"address"];
        [jsonDic setObject:friendDict forKey:sendID];
        NSString  *str = [jsonDic JSONString];
        
        TalkDB * db = [[TalkDB alloc]init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        [db insertDBUserID:[handler getUserID] fromID:sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
        [file setDate:date];
        [file setJsonDict:addressDict];
        UploadDB * uploadDb = [[UploadDB alloc]init];
        NSString *time=[addressDict JSONString];
        [uploadDb insertUploadDB:[handler getUserID] filePath:mapPath withTime:time withFrom:sendID withType:@"map" withDate:[dateFormatter stringFromDate:date]];
        
        if (fileArray != nil && [fileArray count] != 0) {
            FilesUpload * f =[fileArray objectAtIndex:0];
            long long ftime = [f.time longLongValue];
            if ((milliseconds/1000.0 - ftime/1000.0)<8) {
                [cache addFileUpload:file];
                return;
            }
        }
        [cache addFileUpload:file];
        
        [super doFileUpload:fileArray];
    }
    

    [self.delegate reloadMapView];
}

@end
