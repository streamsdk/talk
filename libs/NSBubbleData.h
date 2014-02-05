//
//  NSBubbleData.h
//
//  Created by Alex Barinov

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import<UIKit/UIKit.h>
#import "PlayerDelegate.h"



typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

@interface NSBubbleData : NSObject <AVAudioPlayerDelegate>
{
    UIView *background;
    CGSize bigImageSize;
}
@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSBubbleType type;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic ,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) NSData * audioData;
@property (nonatomic,retain) NSString * _videoPath;
@property (nonatomic,retain) NSString * _videotime;
@property (nonatomic,retain) NSDate * _videodate;
@property (nonatomic,strong) UIImage *_image;
@property (nonatomic,strong) UIImage *disappearImage;
@property (nonatomic,retain) NSString *disappearTime;
@property (nonatomic,retain) NSString *disappearPath;
@property (nonatomic,retain) NSDate *senddate;
@property (assign,nonatomic) id <PlayerDelegate> delegate;

//message
- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;

//no time image
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;

//have time image
-(id) initWithImage:(UIImage *)image withImageTime:(NSString *)time withPath:(NSString *)path date:(NSDate *)date withType:(NSBubbleType) type;
+(id) dataWithImage:(UIImage *)image withImageTime:(NSString *)time withPath:(NSString *)path date:(NSDate *)date withType:(NSBubbleType) type;



//audio
- (id)initWithTimes:(NSString *)times date:(NSDate *)date type:(NSBubbleType)type withData:(NSData *)data;
+ (id)dataWithtimes:(NSString *)times date:(NSDate *)date type:(NSBubbleType)type withData:(NSData *)data;

//video
//withData:(NSData *)data
- (id)initWithImage:(UIImage *)image  withTime:(NSString *)time withType:(NSString *)video date:(NSDate *)date type:(NSBubbleType)type withVidePath:(NSString *)videoPath;
+ (id)dataWithImage:(UIImage *)image  withTime:(NSString *)time withType:(NSString *)video date:(NSDate *)date type:(NSBubbleType)type withVidePath:(NSString *)videoPath;


- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;

@end
