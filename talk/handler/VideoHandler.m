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
@implementation VideoHandler

@synthesize controller,videoPath;
@synthesize delegate;

- (void)receiveVideoFile:(NSData *)data forBubbleDataArray:(NSMutableArray *)bubbleData forBubbleOtherData:(NSData *) otherData withSendId:(NSString *)sendID withFromId:(NSString *)fromID{
    
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    
    NSString * mp4Path = [handler getVideopath];
    
    if ([fromID isEqualToString:sendID]) {
        NSURL *url = [NSURL fileURLWithPath:mp4Path];
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url];
        player.shouldAutoplay = NO;
        UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        NSBubbleData *bdata = [NSBubbleData dataWithImage:fileImage withData:data withType:@"video" date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse withVidePath:mp4Path];
        bdata.delegate = self;
        if (otherData)
            bdata.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:bdata];
    }

}
-(void)sendVideoforBubbleDataArray:(NSMutableArray *)bubbleData forBubbleMyData:(NSData *) myData withSendId:(NSString *)sendID
{
    _bubbleData = bubbleData;
    _myData = myData;
    _sendID = sendID;
    [self encodeToMp4];
  
}
- (void)encodeToMp4
{
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoPath options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSString*  _mp4Quality = AVAssetExportPresetLowQuality;
    if ([compatiblePresets containsObject:_mp4Quality])
        
    {
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
                    [self performSelectorOnMainThread:@selector(convertFinish) withObject:nil waitUntilDone:NO];
                    break;
                default:
                    break;
            }
        }];
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

- (void) convertFinish
{
//    NSInteger size = [self getFileSize:_mp4Path];
//    CGFloat f = [self getVideoDuration:videoPath];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoPath];
    player.shouldAutoplay = NO;
    NSData *videoData = [NSData dataWithContentsOfFile:_mp4Path];
    UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    [self sendVideo:fileImage withData:videoData];
}

-(void) sendVideo:(UIImage *)image withData:(NSData *)videoData{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    
    NSBubbleData * bdata = [NSBubbleData dataWithImage:image withData:videoData withType:@"video" date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine withVidePath:_mp4Path];
    bdata .delegate = self;
    if (_myData)
        bdata.avatar = [UIImage imageWithData:_myData];
    [_bubbleData addObject:bdata];
    
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:_mp4Path forKey:@"video"];
    [jsonDic setObject:friendDict forKey:_sendID];
    NSString  *str = [jsonDic JSONString];
    
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];

    [db insertDBUserID:[handler getUserID] fromID:_sendID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@"video" forKey:@"type"];
    [bodyDic setObject:[handler getUserID] forKey:@"from"];

    
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con sendFileInBackground:videoData toUser:_sendID finished:^(NSString *res){
        NSLog(@"res:%@",res);
    }byteSent:^(float b){
        NSLog(@"byteSent:%f",b);
    }withBodyData:bodyDic];
    
    [delegate reloadTable];

}
-(void)bigImage:(UIImage *)image{
    NSLog(@"");
}

-(void) playerVideo:(NSString *)path{
    NSURL * url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController* pView = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [controller presentViewController:pView animated:YES completion:NULL];

    
}

@end
