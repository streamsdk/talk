//
//  BrushColorViewController.h
//  talk
//
//  Created by wangsh on 14-1-13.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	ColorPickerActionTextForegroudColor,
	ColorPickerActionTextBackgroundColor
}BrushColorPickerAction;

@interface BrushColorViewController : UIViewController

@property (nonatomic, assign) BrushColorPickerAction action;
@property (nonatomic, strong) UIImageView *colorsImageView;
@property (nonatomic, strong) UIView *selectedColorView;
@property (nonatomic,retain) NSString *textColor;
- (void)doneSelected:(id)sender;
- (void)closeSelected:(id)sender;
@end
