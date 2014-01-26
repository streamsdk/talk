//
//  ImageViewController.h
//  RefreshDemo
//
//  Created by wangsh on 14-1-3.
//  Copyright (c) 2014年 wangsh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendProtocol.h"
#import "MyView.h"
#import <QuartzCore/QuartzCore.h>
@interface ImageViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate>
{
    NSArray *timeArray;
    UIActionSheet* actionSheet;
    
}
@property (nonatomic,strong) UIImage * image;
@property (nonatomic,assign) id <SendProtocol> imageSendProtocol;
@property (strong,nonatomic)  MyView *drawView;
@end
