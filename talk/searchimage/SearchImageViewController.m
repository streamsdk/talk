//
//  SearchImageView.m
//  talk
//
//  Created by wangsh on 14-4-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "SearchImageViewController.h"
#import <arcstreamsdk/JSONKit.h>
#import "MainController.h"
@interface SearchImageViewController ()
{
    MainController *mainVC;
}
@end

@implementation SearchImageViewController
@synthesize searchBar = _searchBar;
@synthesize scrollerView;
@synthesize activityIndicatorView;
@synthesize imageSendProtocol;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) back {
    [_searchBar resignFirstResponder];
    
    [self dismissViewControllerAnimated:NO completion:NULL];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    mainVC = [[MainController alloc]init];
    [self setImageSendProtocol:mainVC];
	UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    topView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    [self.view addSubview:topView];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frameBack = CGRectMake(10, 25, 45, 40);
    [backButton setFrame:frameBack];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,20, self.view.frame.size.width, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Image Search";
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:label];
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 40)];
    _searchBar.delegate = self;
    _searchBar.barStyle=UIBarStyleDefault;
    _searchBar.placeholder=@"Image Search";
    _searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self.view addSubview:_searchBar];
    scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 105, self.view.frame.size.width, self.view.frame.size.height-105)];
    scrollerView.backgroundColor = [UIColor clearColor];
    scrollerView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scrollerView.showsHorizontalScrollIndicator = NO;
    scrollerView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollerView];
    activityIndicatorView = [[UIActivityIndicatorView alloc]init];
    [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    //    [self performSelectorInBackground:@selector(downloadImage:) withObject:nil];
}
#pragma mark searchBarDelegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *q = searchBar.text;
    NSString * s =[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&imgsz=small|medium|large|xlarge&rsz=8&as_filetype=jpg&start=0",q];
    s =[s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:s ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error==nil) {
                                   JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
                                   NSDictionary *json = [decoder objectWithData:data];
                                   NSArray *results = [[json objectForKey:@"responseData"] objectForKey:@"results"];
                                   [self performSelectorInBackground:@selector(downloadImage:) withObject:results];
                                   NSLog(@"%@",results);
                               }
                           }];
    
}
-(void)downloadImage:(NSArray *)array {
    for (int i = 0; i< 8; i++) {
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 200*i+10*(i+1), 200, 200)];
        imageView.userInteractionEnabled = YES;
        
        [scrollerView addSubview:imageView];
        [activityIndicatorView startAnimating];
        activityIndicatorView.frame = CGRectMake(imageView.frame.size.width/2, imageView.frame.size.height/2, 20, 20);
        [activityIndicatorView setCenter:CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2)];
        [imageView addSubview:activityIndicatorView];
        NSDictionary * results = [array objectAtIndex:i];
        NSString * unescapedUrl= [results objectForKey:@"unescapedUrl"];
        NSURL * url = [NSURL URLWithString:unescapedUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error==nil) {
                                       UIImage *image = [UIImage imageWithData:data];
                                       imageView.image = image;
                                       [scrollerView setContentSize:CGSizeMake(320, 210*(i+1))];
                                       UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendImage:)];
                                       recognizer.numberOfTouchesRequired = 1;
                                       recognizer.numberOfTapsRequired = 1;
                                       [imageView addGestureRecognizer:recognizer];
                                   }
                                   [activityIndicatorView stopAnimating];
                               }];
        //        UIImage * image = [UIImage imageNamed:@"bg6.png"];
        //        UIImageView *view = [[UIImageView alloc]initWithImage:image];
        //        view.userInteractionEnabled = YES;
        //        [view setFrame:CGRectMake(60, 200*i+10*(i+1), 200, 200)];
        //        [scrollerView addSubview:view];
        //
        //        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendImage:)];
        //        recognizer.numberOfTouchesRequired = 1;
        //        recognizer.numberOfTapsRequired = 1;
        //        [view addGestureRecognizer:recognizer];
        //        [scrollerView setContentSize:CGSizeMake(320, 210*(i+1))];
        
    }
    
}
-(void)sendImage:(UITapGestureRecognizer *)sender{
    [_searchBar resignFirstResponder];
    UIImageView *imageview = (UIImageView *)sender.view;
    [imageSendProtocol sendImages:UIImageJPEGRepresentation(imageview.image, 1.0) withTime:nil];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
