//
//  NSBubbleData.h
//
//  Created by Alex Barinov

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


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
@property (nonatomic,strong) NSData * videoData;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
- (id)initWithTimes:(NSString *)times date:(NSDate *)date type:(NSBubbleType)type withData:(NSData *)data;
+ (id)dataWithtimes:(NSString *)times date:(NSDate *)date type:(NSBubbleType)type withData:(NSData *)data;
- (id)initWithImage:(UIImage *)image withData:(NSData *)data withType:(NSString *)video date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image withData:(NSData *)data withType:(NSString *)video date:(NSDate *)date type:(NSBubbleType)type;
@end
