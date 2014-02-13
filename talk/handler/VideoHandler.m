//
//  VideoHandler.m
//  talk
//
//  Created by wangshuai on 13-12-23.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "VideoHandler.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSBubbleData.h"
#import "TalkDB.h"
#import "STreamXMPP.h"
#import <arcstreamsdk/JSONKit.h>
#import "HandlerUserIdAndDateFormater.h"
#import "ACKMessageDB.h"
#import "FilesUpload.h"
#import "ImageCache.h"
#import <arcstreamsdk/STreamFile.h>
#import "AppDelegate.h"
#import "Progress.h"

@implementation VideoHandler

@synthesize controller,videoPath;
@synthesize delegate;

- (void)receiveVideoFile:(NSData *)data forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withVideoTime:(NSString *)time withSendId:(NSString *)sendID withFromId:(NSString *)fromID {
    
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    
    NSString * mp4Path = [handler getVideopath];
   
    if ([fromID isEqualToString:sendID]) {
        NSURL *url = [NSURL fileURLWithPath:mp4Path];
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url];
        player.shouldAutoplay = NO;
        UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        img = fileImage;
        NSBubbleData *bdata = [NSBubbleData dataWithImage:fileImage withTime:time withType:@"video" date:[handler getDate] type:BubbleTypeSomeoneElse withVidePath:mp4Path];
        if (otherData)
            bdata.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:bdata];
        
    }

}
-(void)sendVideoforBubbleDataArray:(NSMutableArray *)bubbleData withVideoTime:(NSString *)time forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID
{
    _bubbleData = bubbleData;
    _myData = myData;
    _sendID = sendID;
    _time = time;
    [self encodeToMp4];
}
- (void)encodeToMp4
{
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoPath options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
   // NSString*  _mp4Quality = AVAssetExportPresetMediumQuality;
    NSString*  _mp4Quality =AVAssetExportPresetHighestQuality;
    if ([compatiblePresets containsObject:_mp4Quality]) {
        
        UIAlertView *_alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"Waiting.."];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.frame = CGRectMake(140,
                                    80,
                                    CGRectGetWidth(_alert.frame),
                                    CGRectGetHeight(_alert.frame));
        [_alert addSubview:activity];
        [activity startAnimating];
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:_mp4Quality];
        HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
        
        _mp4Path = [[handler getPath] stringByAppendingString:@".mp4"];
        
        exportSession.outputURL = [NSURL fileURLWithPath: _mp4Path];
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    [_alert dismissWithClickedButtonIndex:0 animated:NO];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[[exportSession error] localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    [_alert dismissWithClickedButtonIndex:0
                                                 animated:YES];
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Successful!");
                    [self performSelectorOnMainThread:@selector(convertFinish:) withObject:nil waitUntilDone:NO];
                    break;
                default:
                    break;
            }
        }];
        date = [NSDate dateWithTimeIntervalSinceNow:0];
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoPath];
        player.shouldAutoplay = NO;
//        NSData *videoData = [NSData dataWithContentsOfFile:_mp4Path];
        UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        NSBubbleData * bdata = [NSBubbleData dataWithImage:fileImage withTime:_time withType:@"video" date:date type:BubbleTypeMine withVidePath:_mp4Path];
        if (_myData)
            bdata.avatar = [UIImage imageWithData:_myData];
        [_bubbleData addObject:bdata];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"AVAsset doesn't support mp4 quality"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}
#pragma mark - private Method

- (NSInteger) getFileSize:(NSString*) path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue]/1024;
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

- (CGFloat) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (void) convertFinish:(UIImage *)fileImage
{
//    NSInteger size = [self getFileSize:_mp4Path];
//    CGFloat f = [self getVideoDuration:videoPath];
//    MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoPath];
//    player.shouldAutoplay = NO
//    UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
     NSData *videoData = [NSData dataWithContentsOfFile:_mp4Path];
    [self sendVideo:fileImage withData:videoData withVideoTime:_time];
}

-(void) sendVideo:(UIImage *)image withData:(NSData *)videoData withVideoTime:(NSString *)time{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    if (time)
        [friendDict setObject:time forKey:@"time"];
    [friendDict setObject:_mp4Path forKey:@"video"];
    //[friendDict setObject:[videoPath absoluteString] forKey:@"video"];
    
    [jsonDic setObject:friendDict forKey:_sendID];
    NSString  *str = [jsonDic JSONString];
    
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];

    [db insertDBUserID:[handler getUserID] fromID:_sendID withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:0];
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    
    if (time)
        [bodyDic setObject:time forKey:@"duration"];
    [bodyDic setObject:@"video" forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];
    [bodyDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
    
    ImageCache *cache = [ImageCache sharedObject];
    NSMutableArray *fileArray = [cache getFileUpload];
    
    FilesUpload * file = [[FilesUpload alloc]init];
    [file setTime:[NSString stringWithFormat:@"%lld", milliseconds]];
    [file setFilepath:_mp4Path];
    [file setBodyDict:bodyDic];
    [file setUserId:_sendID];
    
    if (fileArray!=nil && [fileArray count]!=0) {
        [cache setFileUpload:file];
        FilesUpload * f =[fileArray objectAtIndex:0];
        long long ftime = [f.time longLongValue];
        long long t = milliseconds/1000.0 - ftime/1000.0;
        if ((milliseconds/1000.0 - ftime/1000.0)<8) {
            return;
        }
        
    }
    [cache setFileUpload:file];
    [self fileUpload:fileArray];
    [delegate reloadTable];

}
-(void) fileUpload :(NSMutableArray *)file{
    
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    FilesUpload * f =[file objectAtIndex:0];
    NSData *videoData = [NSData dataWithContentsOfFile:f.filepath];
    ImageCache *cache = [ImageCache sharedObject];

    STreamFile *sf = [[STreamFile alloc] init];
    STreamXMPP *con = [STreamXMPP sharedObject];
    [sf postData:videoData finished:^(NSString *res){
        if ([res isEqualToString:@"ok"]){
            [f.bodyDict setObject:[sf fileId] forKey:@"fileId"];
            NSString *bodyJsonData = [f.bodyDict JSONString];
            NSLog(@"body json data: %@", bodyJsonData);
            ACKMessageDB *ack = [[ACKMessageDB alloc]init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            [ack insertDB:f.time withUserID:[handler getUserID] fromID:f.userId withContent:bodyJsonData withTime:[dateFormatter stringFromDate:date] withIsMine:0];

            [con sendFileMessage:f.userId withFileId:[sf fileId] withMessage:bodyJsonData];
        }
        
        [cache removeFileUpload:f];
        NSMutableArray * fileArray = [cache getFileUpload];
        if (fileArray != nil && [fileArray count] != 0) {
            [self fileUpload:fileArray];
        }
        
    }byteSent:^(float bytes){
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        [f setTime:[NSString stringWithFormat:@"%lld", milliseconds]];
        Progress *p = (Progress *)[APPDELEGATE.progressDict objectForKey:f.filepath];
        UIProgressView *progressView= p.progressView;
        UILabel *label = p.label;
        UIActivityIndicatorView *activityIndicatorView = p.activityIndicatorView;
        progressView.hidden = NO;
        progressView.progress = bytes;
        [activityIndicatorView startAnimating];
        label.hidden = NO;
        label.text = [NSString stringWithFormat:@"%.0f%%",bytes*100];
        if (bytes == 1.000000) {
           progressView.hidden = YES;
           label.hidden = YES;
            [activityIndicatorView stopAnimating];
        }
        NSLog(@"byteSent:%f", bytes);
    }];
    
}
@end
