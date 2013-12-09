//
//  SegmentedControl.h
//  talk
//
//  Created by wangsh on 13-12-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentedControl;

typedef enum : NSUInteger
{
    SegmentedControlModeSticky,
    SegmentedControlModeButton
} SegmentedControlMode;

@protocol SegmentedControlDelegate <NSObject>

@optional
- (void)segmentedViewController:(SegmentedControl *)segmentedControl touchedAtIndex:(NSUInteger)index;

@end

@interface SegmentedControl : UIView

@property (nonatomic, assign) id<SegmentedControlDelegate> delegate;

@property (nonatomic, strong) NSArray *buttonsArray;


@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, strong) UIImage *separatorImage;


@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) SegmentedControlMode segmentedControlMode;


@end
