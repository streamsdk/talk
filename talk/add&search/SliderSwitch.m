//
//  SliderSwitch.m
//  talk
//
//  Created by wangsh on 14-1-1.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "SliderSwitch.h"

#define LabelCount3 self.labelCount == 3
#define kLabelOffset 105
#define kLabelWidth  106
#define kLabelHeight 36

@implementation SliderSwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)initSliderSwitch
{
    _labelOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kLabelWidth, kLabelHeight)];
    _labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(kLabelOffset, 0, kLabelWidth, kLabelHeight)];
    
    [self initLabel:_labelOne withOffsetX:0 andTapSel:@selector(didTapLabelOne)];
    [self initLabel:_labelTwo withOffsetX:(kLabelWidth) andTapSel:@selector(didTapLabelTwo)];
    
    if (_labelCount == 3) {
        _labelThree = [[UILabel alloc] initWithFrame:CGRectMake(kLabelOffset * 2, 0, kLabelWidth, kLabelHeight)];
        [self initLabel:_labelThree withOffsetX:(kLabelOffset * 2) andTapSel:@selector(didTapLabelThree)];
    }
    
    [self initToggleButton];
}

- (void)setSliderSwitchBackground:(UIImage *)image
{
    [self setBackgroundColor:[UIColor colorWithPatternImage:image]];
}

- (void)setLabelOneText:(NSString *)text
{
    _labelOne.text = text;
}

- (void)setLabelTwoText:(NSString *)text
{
    _labelTwo.text = text;
}

- (void)setLabelThreeText:(NSString *)text
{
    _labelThree.text = text;
}

#pragma mark - Private methods

- (void)initLabel:(UILabel *)label withOffsetX:(CGFloat)offset andTapSel:(SEL)sel
{
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:sel];
    [label addGestureRecognizer:tapGesture];
    
    [self addSubview:label];
}

- (void)initToggleButton
{
    _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setToggleButtonImage];
    _toggleButton.alpha = 0.8;
    
    //add drag listener
    [_toggleButton addTarget:self action:@selector(draggingButton:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [_toggleButton addTarget:self action:@selector(finishedDraggingButton:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_toggleButton];
}

- (void)setToggleButtonImage
{
    UIImage *image = [UIImage imageNamed:@"top_tab_active.png"];
    [_toggleButton setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [_toggleButton setBackgroundImage:image forState:UIControlStateNormal];
    [_toggleButton setBackgroundImage:image forState:UIControlStateSelected];
    [_toggleButton setBackgroundImage:image forState:UIControlStateHighlighted];
}

- (void)didTapLabelOne
{
    [UIView animateWithDuration:0.3 animations:^{
        [_toggleButton setFrame:_labelOne.frame];
    } completion:^(BOOL finished) {
        [self.delegate slideView:self switchChangedAtIndex:0];
    }];
}

- (void)didTapLabelTwo
{
    [UIView animateWithDuration:0.3 animations:^{
        [_toggleButton setFrame:_labelTwo.frame];
    } completion:^(BOOL finished) {
        [self.delegate slideView:self switchChangedAtIndex:1];
    }];
}

- (void)didTapLabelThree
{
    [UIView animateWithDuration:0.3 animations:^{
        [_toggleButton setFrame:_labelThree.frame];
    } completion:^(BOOL finished) {
        [self.delegate slideView:self switchChangedAtIndex:2];
    }];
}

//button is dragging
- (void)draggingButton:(UIButton *)button withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:button] anyObject];
    
    // get delta
    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    
    // move button at x axis
    button.center = CGPointMake(button.center.x + delta_x,
                                button.center.y );
    
    if (_labelCount == 3) {
        if (button.frame.origin.x > _labelThree.frame.origin.x) {
            [button setFrame:_labelThree.frame];
        }
    }
    else {
        if (button.frame.origin.x > _labelTwo.frame.origin.x) {
            [button setFrame:_labelTwo.frame];
        }
    }
    
    if (button.frame.origin.x < _labelOne.frame.origin.x) {
        [button setFrame:_labelOne.frame];
    }
}

- (void)finishedDraggingButton:(UIButton *)button withEvent:(UIEvent *)event
{
    CGFloat one = _labelOne.center.x;
    CGFloat two = _labelTwo.center.x;
    CGFloat three = _labelThree.center.x;
    CGFloat b = button.frame.origin.x;
    
    if (b < one) {
        [UIView animateWithDuration:0.3 animations:^{
            [button setFrame:_labelOne.frame];
        } completion:^(BOOL finished) {
            [self.delegate slideView:self switchChangedAtIndex:0];
        }];
    }
    
    if (b >= one && b <= two) {
        [UIView animateWithDuration:0.3 animations:^{
            [button setFrame:_labelTwo.frame];
        } completion:^(BOOL finished) {
            [self.delegate slideView:self switchChangedAtIndex:1];
        }];
    }
    
    if (b > two && b < three) {
        [UIView animateWithDuration:0.3 animations:^{
            [button setFrame:_labelThree.frame];
        } completion:^(BOOL finished) {
            [self.delegate slideView:self switchChangedAtIndex:2];
        }];
    }
}



@end
