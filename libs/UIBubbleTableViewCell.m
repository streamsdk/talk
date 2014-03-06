//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov

//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "AppDelegate.h"
#import "TalkDB.h"


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
@synthesize isEdit = _isEdit;
@synthesize selectButton = _selectButton;
@synthesize isClicked = _isClicked;
@synthesize deleteArray = _deleteArray;

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
    _deleteArray = [[NSMutableArray alloc]init];
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_selectButton];
    [_selectButton addTarget:self action:@selector(selectData) forControlEvents:UIControlEventTouchUpInside];
    _selectButton.hidden = YES;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *time = [dateFormatter stringFromDate:self.data.date];
    [_selectButton setImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
    for (NSDate *date in APPDELEGATE.deleteArray) {
        NSString *deleteTime = [dateFormatter stringFromDate:date];
        if ([deleteTime isEqualToString:time]) {
            [_selectButton setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
        }
    }
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];
#endif
        [self addSubview:self.bubbleImage];
    }
    self.bubbleImage.userInteractionEnabled = YES;
    NSBubbleType type = self.data.type;
    
//    FileType filetype = self.data.fileType;

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
        if (self.isEdit) {
            self.selectButton.hidden =NO;
            if (type == BubbleTypeSomeoneElse)
            {
                self.avatarImage.frame = CGRectMake(avatarX+30, avatarY, 46, 46);
            }else{
               self.avatarImage.frame = CGRectMake(avatarX, avatarY, 46, 46);
            }
            
        }else{
            self.selectButton.hidden = YES;
           self.avatarImage.frame = CGRectMake(avatarX, avatarY, 46, 46);
        }

        self.selectButton.frame= CGRectMake(3, avatarY+8, 28, 28);
        [self.contentView addSubview:self.avatarImage];
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta;
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
    }

    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    
    if (self.isEdit) {
        if (type == BubbleTypeSomeoneElse)
        {
            self.customView.frame = CGRectMake(x+30+self.data.insets.left,y+self.data.insets.top, width, height);
        }else{
           self.customView.frame = CGRectMake(x+self.data.insets.left,y+self.data.insets.top, width, height);
        }
        
    }else{
        self.customView.frame = CGRectMake(x+self.data.insets.left,y+self.data.insets.top, width, height);
    }

    [self addSubview:self.customView];

    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];

    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }

    if (self.isEdit) {
        if (type == BubbleTypeSomeoneElse)
        {
            self.bubbleImage.frame = CGRectMake(x+30, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
        }else{
             self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
        }

    }else{
        self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);

    }

    
}
-(void)selectData{
    
    if (YES == _isClicked) {
        [_selectButton setImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
        [APPDELEGATE.deleteArray removeObject:self.data.date];
//        NSString *title = [NSString stringWithFormat:@"%d",[APPDELEGATE.deleteArray count]];
//        if (![title isEqualToString:@"0"])
//            [APPDELEGATE.button setTitle:[NSString stringWithFormat:@"Delete(%@)",title] forState:UIControlStateNormal];
        _isClicked = NO;
    }else{
        [_selectButton setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
        [APPDELEGATE.deleteArray addObject:self.data.date];
//        NSString *title = [NSString stringWithFormat:@"%d",[APPDELEGATE.deleteArray count]];
//        if (![title isEqualToString:@"0"])
//             [APPDELEGATE.button setTitle:[NSString stringWithFormat:@"Delete(%@)",title] forState:UIControlStateNormal];
        _isClicked = YES;
    }
    NSLog(@"selectbutton");
}
@end
