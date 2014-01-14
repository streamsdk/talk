//
//  TwitterViewController.m
//  talk
//
//  Created by wangsh on 14-1-14.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "TwitterViewController.h"
#import "HandlerUserIdAndDateFormater.h"
#import "Twitter.h"
#import "ImageCache.h"

@interface TwitterViewController ()
{
    HandlerUserIdAndDateFormater * handler;
    NSMutableArray * twitters;
}
@end

@implementation TwitterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    ImageCache * imageCache =[ImageCache sharedObject];
    twitters = [imageCache getTwitters];
    handler = [HandlerUserIdAndDateFormater sharedObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [twitters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CALayer *l = [cell.imageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:8.0];
        UIImageView * image= [[UIImageView alloc]initWithFrame:CGRectMake(42, 32, 26, 26)];
        image.image = [UIImage imageNamed:@"twitter.png"];
        image.tag = 10000;
        [cell addSubview:image];
    }
    
    Twitter * twitter = [twitters objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"headImage.jpg"];
    [self loadProfileId:twitter withCell:cell];
    cell.textLabel.text = [twitter name];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:18.0f];

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}
-(void)loadProfileId:(Twitter *)twitter withCell:(UITableViewCell *)cell{
    
    UIImageFromURL([NSURL URLWithString:[twitter profileUrl]], ^(UIImage *image) {
        NSData * data =UIImageJPEGRepresentation(image, 1.0);
        NSString *profilePath = [[handler getPath] stringByAppendingString:@".png"];
        [data writeToFile:profilePath atomically:YES];
        UIImage *_image = [UIImage imageWithData:[NSData dataWithContentsOfFile:profilePath]];
        [self setImage:_image withCell:cell];
        UIImageView * view = (UIImageView *)[self.view viewWithTag:10000];
        view.image = [UIImage imageNamed:@"twitter.png"];
    }, ^{
        NSLog(@"");
    });
}
-(void)setImage:(UIImage *)icon withCell:(UITableViewCell *)cell{
    CGSize itemSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
#pragma mark - download profileimage
void UIImageFromURL( NSURL * URL, void (^imageBlock)(UIImage * image), void (^errorBlock)(void) )
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void){
        NSData * data = [[NSData alloc] initWithContentsOfURL:URL];
        UIImage * image = [[UIImage alloc] initWithData:data];
        dispatch_async( dispatch_get_main_queue(), ^(void){
            if( image != nil )
            {
                imageBlock( image );
            } else {
                errorBlock();
            }
        });
    });

    }

@end
