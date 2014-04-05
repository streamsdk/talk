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
#import "MyStatusDB.h"
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamUser.h>
#import "ImageCache.h"
@interface EditStatusViewController ()<UITextViewDelegate>
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
    NSLog(@"save");
    NSString * str = myUITextView.text;
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 && status==nil){
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    if (![str isEqualToString:status]) {
        if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
            str = status;
        StatusViewController * statusVC =[[StatusViewController alloc]init];
        [statusVC setRow:0];
        [statusVC setStatus:str];
        HandlerUserIdAndDateFormater *handle =[HandlerUserIdAndDateFormater sharedObject];
        MyStatusDB * statusDb=[[MyStatusDB alloc]init];
        [statusDb insertStatus:str withUser:[handle getUserID]];
        ImageCache * imageCache = [ImageCache sharedObject];
        NSMutableDictionary *userMetadata=[imageCache getUserMetadata:[handle getUserID]];
        [userMetadata setObject:str forKey:@"status"];
        STreamUser *user =[[STreamUser alloc]init];
        [imageCache saveUserMetadata:[handle getUserID] withMetadata:userMetadata];
        [user updateUserMetadata:[handle getUserID] withMetadata:userMetadata];
        

    }
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"Your Status (%d)",130-[status length]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    myUITextView  = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, self.view.frame.size.width-20, 220.0f)];
    myUITextView.text = status;
    [myUITextView becomeFirstResponder];
    myUITextView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:myUITextView];
    myUITextView.delegate = self;
}

-(void)textViewDidChange:(UITextView *)textView{
    NSInteger number = [textView.text length];
    if (number > 130) {
        NSRange rg = {0,130};
        textView.text = [textView.text substringWithRange:rg];
        
        number=130;
    }
   self.title = [NSString stringWithFormat:@"Your Status (%d)",130-number];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
