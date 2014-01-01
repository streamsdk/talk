//
//  SliderSwitch.h
//  talk
//
//  Created by wangsh on 14-1-1.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SliderSwitch;

@protocol SliderSwitchDelegate <NSObject>

@optional
- (void)slideView:(SliderSwitch *)slideSwitch switchChangedAtIndex:(NSInteger)index;

@end

@interface SliderSwitch : UIView
{
    UILabel *_labelOne, *_labelTwo,* _labelThree;
    UIButton *_toggleButton;
}

@property (nonatomic) NSInteger labelCount;
@property (nonatomic, assign) id<SliderSwitchDelegate> delegate;

- (void)initSliderSwitch;
- (void)setSliderSwitchBackground:(UIImage *)image;
- (void)setLabelOneText:(NSString *)text;
- (void)setLabelTwoText:(NSString *)text;
- (void)setLabelThreeText:(NSString *)text;
@end
