//
//  ImageViewController.h
//  RefreshDemo
//
//  Created by wangsh on 14-1-3.
//  Copyright (c) 2014年 wangsh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate>
{
    NSArray *timeArray;
    UIActionSheet* actionSheet;
}
@property (nonatomic,strong) UIImage * image;

@end
