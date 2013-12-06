//
//  SignUpViewController.h
//  talk
//
//  Created by wangshuai on 13-11-12.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate>
{
   
}
@property (nonatomic,strong) UITextField *userName;
@property (nonatomic,strong) UITextField *password;
@property (nonatomic,strong) UITextField *surePassword;
@end
