//
//  EditStatusViewController.m
//  talk
//
//  Created by wangsh on 14-3-28.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "EditStatusViewController.h"
#import "StatusViewController.h"
#import "HandlerUserIdAndDateFormater.h"
#import "StatusDB.h"
@interface EditStatusViewController ()
{
    UITextView *myUITextView;
}
@end

@implementation EditStatusViewController

@synthesize status;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) save {
    /*NSLog(@"save");
    NSString * str = myUITextView.text;
    if (![str isEqualToString:status]) {
        HandlerUserIdAndDateFormater *handle =[HandlerUserIdAndDateFormater sharedObject];
        StatusDB * statusDb=[[StatusDB alloc]init];
        [statusDb insertStatus:status withUser:[handle getUserID]];
    }*/
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Your Status";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    myUITextView  = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, self.view.frame.size.width-20, 220.0f)];
    myUITextView.text = status;
    [myUITextView becomeFirstResponder];
    myUITextView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:myUITextView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
