//
//  TearmServiceViewController.m
//  talk
//
//  Created by wangsh on 14-1-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "TearmServiceViewController.h"

@interface TearmServiceViewController ()

@end

@implementation TearmServiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Terms of Service";
    UIWebView * webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    [self.view addSubview: webView];
    NSString *urlString = @"http://streamsdk.com/coolchat/termsofuse.html";
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
