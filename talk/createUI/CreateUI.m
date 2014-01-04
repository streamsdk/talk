//
//  CreateUI.m
//  talk
//
//  Created by wangsh on 13-11-7.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "CreateUI.h"
#import <QuartzCore/QuartzCore.h>

@implementation CreateUI

-(UIButton *)setButtonFrame:(CGRect)frame withTitle:(NSString *)title{
     
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    button.autoresizingMask =  UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    if (![title isEqualToString:@"nil"]) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:229.0/255.0 blue:227.0/255.0 alpha:1.0]];
    }
    return button;
}
-(UITextField *)setTextFrame:(CGRect)frame {
    
    textFiled = [[UITextField alloc]initWithFrame:frame];
    textFiled.borderStyle = UITextBorderStyleRoundedRect;
    textFiled.backgroundColor = [UIColor clearColor];
    textFiled.delegate = self;
    [[textFiled layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[textFiled layer] setBorderWidth:1];
    [[textFiled layer] setCornerRadius:4];
    textFiled.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    return textFiled;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textFiled resignFirstResponder];
    return YES;
}
@end
