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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
