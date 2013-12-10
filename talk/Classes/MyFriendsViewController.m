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

#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>

@interface MyFriendsViewController ()

@end

@implementation MyFriendsViewController

@synthesize userData,userDict;

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
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"MyFriends";
   [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    userData = [[NSArray alloc]init];
    userDict = [[NSMutableDictionary alloc]init];
    
    self.navigationItem.hidesBackButton = YES;
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
    NSArray *my = [[NSArray alloc]initWithObjects:loginName, nil];
    STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq setQueryLogicAnd:true];
    [sq whereEqualsTo:@"status" forValue:@"friend"];
    NSArray * friends = [sq find];
    
    [userDict setValue:my forKey:@"my"];
    [userDict setValue:friends forKey:@"myFriends"];
    userData = [userDict allKeys];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [userData count];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * string = [userData objectAtIndex:section];
    NSArray *frieds = [userDict objectForKey:string];
    return [frieds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString * keys = [userData objectAtIndex:indexPath.section];
    NSArray * friends = [userDict objectForKey:keys];
    if (indexPath.section ==0) {
         cell.textLabel.text = [friends objectAtIndex:indexPath.row];
        
    }else{
        STreamObject * so = [friends objectAtIndex:indexPath.row];
        cell.textLabel.text = [so objectId];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section!=0) {
        NSString * keys = [userData objectAtIndex:indexPath.section];
        NSArray * friends = [userDict objectForKey:keys];
        MainController *mainVC = [[MainController alloc]init];
        STreamObject * so= [friends objectAtIndex:indexPath.row];
        NSString *userName = [so objectId];
        [mainVC setSendToID:userName];
        [self.navigationController pushViewController:mainVC animated:YES];
    }
   
}

@end
