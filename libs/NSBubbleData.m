//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//

#import "NSBubbleData.h"

#define BIG_IMG_WIDTH  300.0
#define BIG_IMG_HEIGHT 300.0

@implementation NSBubbleData

#pragma mark - Properties

@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;
@synthesize audioPlayer;
@synthesize audioData;
@synthesize videoData;
@synthesize _videoPath;
@synthesize _videotime;
@synthesize _videodate;
@synthesize delegate;
@synthesize _image;
@synthesize disappearImage;
@synthesize disappearTime;
@synthesize disappearPath;
@synthesize senddate;

#pragma mark - Lifecycle

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_date release];
	_date = nil;
    [_view release];
    _view = nil;
    
    self.avatar = nil;

    [super dealloc];
}
#endif

#pragma mark - Text bubble

const UIEdgeInsets textInsetsMine = {5, 10, 11, 17};
const UIEdgeInsets textInsetsSomeone = {5, 15, 11, 10};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text date:date type:type];
#endif    
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
    UIFont *font = [UIFont systemFontOfSize:18.0f];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:label date:date type:type insets:insets];
}

#pragma mark - Image bubble no time

const UIEdgeInsets imageInsetsMine = {11, 13, 16, 22};
const UIEdgeInsets imageInsetsSomeone = {11, 18, 16, 14};

#pragma mark - Custom view photo

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image date:date type:type];
#endif    
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
    _image = image;
    bigImageSize = image.size;
    CGSize size = image.size;
    /*if (size.width > 200)
    {
        image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(100, 100)];
        size = image.size;
    }*/
    image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(100, 100)];
    size = image.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tappressGesutre=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bigToImage)];
    tappressGesutre.numberOfTouchesRequired=1;
    [imageView addGestureRecognizer:tappressGesutre];
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets];
}
#pragma mark -Custom image view  have time 

-(id) initWithImage:(UIImage *)image withImageTime:(NSString *)time withPath:(NSString *)path date:(NSDate *)date withType:(NSBubbleType) type{
    disappearImage= image;
    disappearTime = time;
    disappearPath = path;
    senddate = date;
    
    NSString * text =@"我抛了一张会消失的图片";
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, size.height, size.width, size.height)];
    
    button.titleLabel.frame =CGRectMake(0, 0, size.width, size.height*2);
    button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    button.contentVerticalAlignment = UIControlContentHorizontalAlignmentRight;
    button.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
    
    UIImageView * view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height*2)];
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    [view addSubview:button];
    
    if ([time isEqualToString:@"-1"]) {
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitle:@"已取消" forState:UIControlStateNormal];
        view.userInteractionEnabled = NO;

    }else{
        view.userInteractionEnabled = YES;
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitle:@"点击查看" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(lookImageClicked) forControlEvents:UIControlEventTouchUpInside];
    }

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookImageClicked)];
    [view addGestureRecognizer:tap];
#if !__has_feature(objc_arc)
    [button autorelease];
    [label autorelease];
    [view autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:view date:date type:type insets:insets];
}
+ (id) dataWithImage:(UIImage *)image withImageTime:(NSString *)time withPath:(NSString *)path date:(NSDate *)date withType:(NSBubbleType) type{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image withImageTime:time withPath:path date:date withType:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image withImageTime:time withPath:path date:date withType:type];
#endif
}

#pragma mark - Custom view audio
- (id)initWithTimes:(NSString *)times date:(NSDate *)date type:(NSBubbleType)type withData:(NSData *)data {
    audioData = data;
    UIImage *image = [UIImage imageNamed:@"video.png"];
    CGSize size = image.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width+35, size.height)];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(player:)];
    [imageView addGestureRecognizer:tap];
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(35, 0, size.width, size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(player:) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:button];
    
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = times;
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    [imageView addSubview:label];
#if !__has_feature(objc_arc)
    [button autorelease];
    [imageview autorelease];
    [lable autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets];

}
+ (id)dataWithtimes:(NSString *)times date:(NSDate *)date type:(NSBubbleType)type withData:(NSData *)data{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithTimes:times date:date type:type withData:data] autorelease];
#else
    return [[NSBubbleData alloc] initWithTimes:times date:date type:type withData:data];
#endif

}
#pragma mark - Custom view video
- (id)initWithImage:(UIImage *)image withData:(NSData *)data withTime:(NSString *)time withType:(NSString *)video date:(NSDate *)date type:(NSBubbleType)type withVidePath:(NSString *)videoPath{
    videoData = data;
    _videotime = time;
    _videoPath = videoPath;
    _videodate = date;
    CGSize size = image.size;
    /*if (size.width > 200)
    {
        image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(100, 100)];
        size = image.size;
    }*/
    if (!time) {
        image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(100, 100)];
        size = image.size;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        imageView.image = image;
        imageView.layer.cornerRadius = 5.0;
        imageView.layer.masksToBounds = YES;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerVideo)];
        [imageView addGestureRecognizer:tap];
        
        UIImageView * imagevideo = [[UIImageView alloc]initWithFrame:CGRectMake(size.width - 30, size.height-30,30, 30)];
        [imagevideo setImage:[UIImage imageNamed:@"video1.png"]];
        [imageView addSubview:imagevideo];
        UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
        return [self initWithView:imageView date:date type:type insets:insets];

    }else{
        NSString * text =@"我抛了一段会消失的视频";
        UIFont *font = [UIFont systemFontOfSize:16.0f];
        CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = (text ? text : @"");
        label.font = font;
        label.backgroundColor = [UIColor clearColor];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, size.height, size.width, size.height)];
        
        button.titleLabel.frame =CGRectMake(0, 0, size.width, size.height*2);
        button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        button.contentVerticalAlignment = UIControlContentHorizontalAlignmentRight;
        button.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
        
        UIImageView * view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height*2)];
        view.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        [view addSubview:button];
        
        if ([time isEqualToString:@"-1"]) {
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button setTitle:@"已取消" forState:UIControlStateNormal];
            view.userInteractionEnabled = NO;
            
        }else{
            view.userInteractionEnabled = YES;
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [button setTitle:@"点击查看" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(playerVideo) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerVideo)];
        [view addGestureRecognizer:tap];
        
        UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
        return [self initWithView:view date:date type:type insets:insets];
    }
}
+ (id)dataWithImage:(UIImage *)image withData:(NSData *)data withTime:(NSString *)time withType:(NSString *)video date:(NSDate *)date type:(NSBubbleType)type withVidePath:(NSString *)videoPath{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image withData:data withTime:time withType:video date:date type:type withVidePath:videoPath] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image withData:data withTime:time withType:video date:date type:type withVidePath:videoPath];
#endif
}
#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date type:type insets:insets] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date type:type insets:insets];
#endif    
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets  
{
    self = [super init];
    if (self)
    {
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
#else
        _view = view;
        _date = date;
#endif
        _type = type;
        _insets = insets;
    }
    return self;
}

-(void)player :(id) sender{
    
    NSError *error=nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    audioPlayer.delegate = self;
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    
    [player stop];
    //播放结束时执行的动作
}

-(void)playerVideo {

    [delegate playerVideo:_videoPath withTime:_videotime withDate:_videodate];
   
}
-(void) bigToImage {

    [delegate bigImage:_image];
}
-(void)  lookImageClicked{
    [delegate  disappearImage:disappearImage withDissapearTime:disappearTime withDissapearPath:disappearPath withSendOrReceiveTime:senddate];
}
#pragma mark scaled image
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
