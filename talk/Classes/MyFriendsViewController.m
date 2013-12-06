//
//  MyFriendsViewController.m
//  talk
//
//  Created by wangsh on 13-12-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "MyFriendsViewController.h"
#import "MBProgressHUD.h"
#import "MainController.h"
#import "AddFriendsViewController.h"
#import "SearchFriendsViewController.h"
#import "TabBarViewController.h"

#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>

@interface MyFriendsViewController ()

@end

@implementation MyFriendsViewController

@synthesize userData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) addFriends {
    AddFriendsViewController * addVC = [[AddFriendsViewController alloc]init];
    SearchFriendsViewController * searchVC = [[SearchFriendsViewController alloc]init];
    UITabBarItem *mainBar=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1001];
    UITabBarItem *sharedBar=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:1002];
    
    addVC.tabBarItem = mainBar;
    searchVC.tabBarItem = sharedBar;
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    
    UINavigationController * mainNav = [[UINavigationController alloc]initWithRootViewController:addVC];
    UINavigationController * sharedNav =[[UINavigationController alloc]initWithRootViewController:searchVC];
    
    [array addObject:mainNav];
    [array addObject:sharedNav];
    
    TabBarViewController * tabBar = [[TabBarViewController alloc]init];
    tabBar.viewControllers = array;
    [self presentViewController:tabBar animated:YES completion:NULL];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"MyFriends";
   [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    userData = [[NSMutableArray alloc]init];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriends)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"loading friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadFriends];
    }completionBlock:^{
        [self.tableView reloadData];
       [HUD removeFromSuperview];
        HUD = nil;
    }];    
}
-(void) loadFriends {
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq setQueryLogicAnd:true];
    [sq whereEqualsTo:@"status" forValue:@"friend"];
    userData = [sq find];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    }
    STreamObject * so = [userData objectAtIndex:indexPath.row];
    cell.textLabel.text = [so objectId];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MainController *mainVC = [[MainController alloc]init];
    STreamObject * so= [userData objectAtIndex:indexPath.row];
    NSString *userName = [so objectId];
    [mainVC setSendToID:userName];
    [self.navigationController pushViewController:mainVC animated:YES];
}
@end
