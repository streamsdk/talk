//
//  HandleViewController.m
//  talk
//
//  Created by wangsh on 13-12-24.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "HandleViewController.h"
#import "SearchFriendsViewController.h"
#import "HandlerUserIdAndDateFormater.h"
#import "MBProgressHUD.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import "SearchDB.h"
@interface HandleViewController ()

@end

@implementation HandleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) refresh {
    NSLog(@"");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.searchBar removeFromSuperview];
    
    UIBarButtonItem *refreshitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshitem;
    
    [self.myTableview setFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.myTableview.frame.size.width, 36)];
    label.text =@"I added chatters";
    label.backgroundColor = [UIColor blueColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"DIN Alternate" size:15.0f];
    self.myTableview.tableHeaderView =label;
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"loading friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:[handler getUserID]];
        [sq setQueryLogicAnd:true];
        [sq whereEqualsTo:@"status" forValue:@"sendRequest"];
        self.userData = [sq find];
    }completionBlock:^{
        [self.myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
    
    /*SearchDB * searchDB = [[SearchDB alloc]init];
    self.userData = [searchDB readDB:[handler getUserID]];*/

}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.userData count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    STreamObject * so = [self.userData objectAtIndex:indexPath.row];
    cell.textLabel.text = [so objectId];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
