//
//  ViewController.h
//  spike
//
//  Created by wangshuai on 27/02/2014.
//  Copyright (c) 2014 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (IBAction)updatePressed:(id)sender;
- (IBAction)scanPressed:(id)sender;

@end
