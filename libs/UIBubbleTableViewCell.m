//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov

//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "AppDelegate.h"

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIImageView *avatarImage;


- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;
@synthesize progressView;
@synthesize activityIndicatorView;
@synthesize label;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];
#endif
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;
    
    FileType filetype = self.data.fileType;

    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
#if !__has_feature(objc_arc)
        self.avatarImage = [[[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"headImage.jpg"])] autorelease];
#else
        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"headImage.jpg"])];
#endif
        self.avatarImage.layer.cornerRadius = 9.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
        CGFloat avatarY = self.frame.size.height - 50;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 46, 46);
        [self addSubview:self.avatarImage];
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta;
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
    }

    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    [self.contentView addSubview:self.customView];

    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];

    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }

    self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
    progressView = [[UIProgressView alloc]init];
    progressView.progress =0.0f;
    activityIndicatorView = [[UIActivityIndicatorView alloc]init];
    [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    label = [[UILabel alloc]init];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:10.0f]];
  
//    activityIndicatorView.hidden = YES;
    if (type == BubbleTypeMine) {
        if (filetype == FileImage) {
            progressView .frame = CGRectMake(24, self.contentView.frame.size.height, 90, 8);
            CGAffineTransform transform =CGAffineTransformMakeScale(1.0f,2.0f);
            progressView.transform = transform;
            progressView.hidden = YES;
            [self.contentView addSubview:progressView];
            label.frame = CGRectMake(0, self.contentView.frame.size.height, 60, 30);
            label.hidden = YES;
            [self.contentView addSubview:label];
        }
        if ( filetype == FileVideo) {
            progressView .frame = CGRectMake(24, self.contentView.frame.size.height+25, 90, 8);
            CGAffineTransform transform =CGAffineTransformMakeScale(1.0f,2.0f);
            progressView.transform = transform;
            progressView.hidden = YES;
            label.frame = CGRectMake(0, self.contentView.frame.size.height+10, 60, 30);
            label.hidden = YES;
            [self.contentView addSubview:progressView];
            [self.contentView addSubview:label];
            
        }
        if (filetype == FileDisappear) {
            activityIndicatorView.frame = CGRectMake(60, self.contentView.frame.size.height-10, 20, 20);
            [activityIndicatorView setCenter:CGPointMake(60, self.contentView.frame.size.height-10)];
//            [activityIndicatorView startAnimating];
            [self.contentView addSubview:activityIndicatorView];
            
        }
        if (filetype == FileVoice) {
            activityIndicatorView.frame = CGRectMake(130, self.contentView.frame.size.height-10, 20, 20);
            [activityIndicatorView setCenter:CGPointMake(130, self.contentView.frame.size.height-10)];
//            [activityIndicatorView startAnimating];
            [self.contentView addSubview:activityIndicatorView];
        }

        APPDELEGATE.label = label;
        APPDELEGATE.progressView = progressView;
        APPDELEGATE.activityIndicatorView = activityIndicatorView;

    }
}

@end
