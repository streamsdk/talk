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
#import "ScaledImage.h"
#import "ImageCache.h"
@interface SearchImageViewController ()
{
    MainController *mainVC;
    NSInteger allPage;
    UIView * lowView;
    BOOL isSearch;
    UIAlertView * alertView;
    ImageCache *imagecache;
}
@end

@implementation SearchImageViewController
@synthesize searchBar = _searchBar;
@synthesize activityIndicatorView;
@synthesize imageSendProtocol;
@synthesize tableView = _tableView;
@synthesize pageCount,dataArray,reloading = _reloading,name,footActivityIndicatorView;
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
    isSearch = NO;
    _reloading = NO;
    pageCount = 0;
    imagecache = [ImageCache sharedObject];
    dataArray = [imagecache getSearchImage];
//    dataArray = [[NSMutableArray alloc]init];
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
    activityIndicatorView = [[UIActivityIndicatorView alloc]init];
    [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
 
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 105, self.view.frame.size.width, self.view.frame.size.height-105)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator=NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
     lowView= [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width, 30)];
    lowView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    [self.view addSubview:lowView];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]init];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activity.frame = CGRectMake(lowView.frame.size.width/2, lowView.frame.size.height/2, 20, 20);
    [activity setCenter:CGPointMake(lowView.frame.size.width/2, lowView.frame.size.height/2)];
    [lowView addSubview:activity];
    [activity startAnimating];
    lowView.hidden = YES;
   alertView=[[UIAlertView alloc]initWithTitle:nil message:@"download error" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
}
#pragma mark tableviewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellName = @"cellname";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = 10000;
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((cell.frame.size.width-300)/2,10, 300, 300)];
        imageView.image = [UIImage imageNamed:@"photog150.png"];
        imageView .tag = 10000;
        imageView.userInteractionEnabled = YES;
        [cell.contentView addSubview:imageView];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendImage:)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        [imageView addGestureRecognizer:recognizer];
        activityIndicatorView.frame = CGRectMake(imageView.frame.size.width/2, imageView.frame.size.height/2, 20, 20);
        [activityIndicatorView setCenter:CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2)];
        [imageView addSubview:activityIndicatorView];
    }
    UIImageView * imageView = (UIImageView *)[cell.contentView viewWithTag:10000];
    imageView.image = [dataArray objectAtIndex:indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 320;
}
#pragma mark searchBarDelegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [dataArray removeAllObjects];
    [imagecache removeSearchImage];
     lowView.hidden = NO;
    pageCount = 0;
    name = searchBar.text;
    [self loadJsonData:name withCount:pageCount];
    
}
//load jsondata
-(void)loadJsonData:(NSString *)str withCount:(NSInteger)page{
   isSearch = YES;
    
    NSString * s =[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&imgsz=small|medium|large|xlarge&rsz=8&as_filetype=jpg&start=%d",name,pageCount*8];
    s =[s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:s ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error==nil) {
                                   JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
                                   NSDictionary *json = [decoder objectWithData:data];
                                   allPage = [[[[[[json objectForKey:@"responseData"] objectForKey:@"cursor"] objectForKey:@"pages"] lastObject] objectForKey:@"start"] integerValue];
                                
                                   NSArray *results = [[json objectForKey:@"responseData"] objectForKey:@"results"];
                                   [self performSelectorInBackground:@selector(downloadImage:) withObject:results];
//                                   NSLog(@"%@",results);
                               }else{
                                   [alertView show];
                                    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(alertDismiss) userInfo:nil repeats:NO];
                                   
                               }
                               isSearch = NO;
                               lowView.hidden= YES;
                           }];
}
-(void)alertDismiss{
    [alertView dismissWithClickedButtonIndex:0 animated:NO];
}
// doenload image
-(void)downloadImage:(NSArray *)array {
//    array = [[NSArray alloc]initWithObjects:@"bg1.png",@"bg2.jpg",@"bg3.jpg",@"bg4.png",@"bg5.png",@"bg6.png",@"bg7.png",@"bg8.jpg",@"bg9.png",@"bg10.png",@"bg11.png",@"bg.png",nil];
//    [activityIndicatorView startAnimating];
    for (int i = 0; i< [array count]; i++) {
        [activityIndicatorView startAnimating];
        NSDictionary * results = [array objectAtIndex:i];
        NSString * unescapedUrl= [results objectForKey:@"unescapedUrl"];
        NSURL * url = [NSURL URLWithString:unescapedUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self performSelectorInBackground:@selector(downOneImage:) withObject:request];
        
    }
    
    
}
-(void)downOneImage:(NSMutableURLRequest *)request{
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error==nil) {
                                   UIImage *image = [UIImage imageWithData:data];
                                   if (image){
//                                       [dataArray addObject:image];
                                       [imagecache saveSearchImage:image];
                                   }
                                   [self.tableView reloadData];
                               }
                               [activityIndicatorView stopAnimating];
                           }];
    
}
-(void)sendImage:(UITapGestureRecognizer *)sender{
    [_searchBar resignFirstResponder];
    ScaledImage * scaled = [[ScaledImage alloc]init];
    UIImageView *imageview = (UIImageView *)sender.view;
    UIImage *image = imageview.image;
    image = [scaled imageWithImage:image scaledToMaxWidth:image.size.width*0.2 maxHeight:image.size.height*0.2];
    [imageSendProtocol sendImages:UIImageJPEGRepresentation(image, 1.0) withTime:nil];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_searchBar resignFirstResponder];
}

#pragma mark Data Source Loading / Reloading Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!_reloading && scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height))
    {
        pageCount +=1;
        if (8*pageCount<=allPage && !isSearch) {
            [self loadDataBegin];
        }
        
    }
}

// 开始加载数据
- (void) loadDataBegin
{
    if (_reloading == NO)
    {
        _reloading = YES;
        UIActivityIndicatorView *tableFooterActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 20.0f, 20.0f)];
        [tableFooterActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        footActivityIndicatorView = tableFooterActivityIndicator;
        [footActivityIndicatorView startAnimating];
        self.tableView.tableFooterView = footActivityIndicatorView;
        [self loadDataing];
    }
}

// 加载数据中
- (void) loadDataing
{
    
    [self loadJsonData:name withCount:pageCount];
    [self performSelector:@selector(loadDataEnd) withObject:nil afterDelay:2.0];

}

// 加载数据完毕
- (void) loadDataEnd
{
    _reloading = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [footActivityIndicatorView stopAnimating];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
