//
//  LoginViewController.h
//  talk
//
//  Created by wangsh on 13-11-10.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>


@property (nonatomic,strong) UITextField * userNameText;

@property (nonatomic,strong) UITextField * password;


@end
