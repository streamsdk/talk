//
//  AddFriendsViewController.m
//  talk
//
//  Created by wangsh on 13-12-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "MBProgressHUD.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import "MyFriendsViewController.h"
#import "SearchFriendsViewController.h"
#import "ImageCache.h"
#import "FileCache.h"
#import <arcstreamsdk/STreamFile.h>
#import "MBProgressHUD.h"
#import "TabBarViewController.h"
#import "HandleViewController.h"
#import "HandlerUserIdAndDateFormater.h"
#import "AddDB.h"
#define LEFT_BUTTON_TAG 1000
#define RIGHT_BUTTON_TAG 2000

@interface AddFriendsViewController ()
{
    NSMutableDictionary * addDict;
}
@end

@implementation AddFriendsViewController
@synthesize myTableview,userData;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) loadFriends {
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName= [handler getUserID];
    STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq setQueryLogicAnd:FALSE];
    [sq whereEqualsTo:@"status" forValue:@"friend"];
    
    [sq whereEqualsTo:@"status" forValue:@"request"];
    NSMutableArray * array = [sq find];
    AddDB * db = [[AddDB alloc]init];
    [db deleteDB];
    for (STreamObject *so in array) {
        [db insertDB:[handler getUserID] withFriendID:[so objectId] withStatus:[so getValue:@"status"]];
    }
    userData = [[NSMutableArray alloc]init];
    AddDB * addDB = [[AddDB alloc]init];
    addDict = [addDB readDB:[handler getUserID]];
    NSArray * array2 = [addDict allKeys];
    for (int i = 0; i<[array2 count]; i++) {
        NSString *status = [addDict objectForKey:[array2 objectAtIndex:i]];
        if (![status isEqualToString:@"sendRequest"]) {
            [userData addObject:[array2 objectAtIndex:i]];
        }
    }

    
    [myTableview reloadData];
}
-(void) refresh {
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];

    HUD.labelText = @"refresh friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadFriends];
    }completionBlock:^{
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];

    NSLog(@"");
}
-(void) back{
    MyFriendsViewController * myFriendsVC = [[MyFriendsViewController alloc]init];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController pushViewController:myFriendsVC animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Add Friends";
    self .navigationItem.hidesBackButton = YES;
    self.tabBarController.tabBar.hidden = YES;
    UIBarButtonItem * leftitem = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftitem;
    
    UIBarButtonItem *refreshitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshitem;
    
    userData = [[NSMutableArray alloc]init];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    myTableview  = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    myTableview.backgroundColor = [UIColor clearColor];
    myTableview.delegate = self;
    myTableview.dataSource = self;
    [self.view addSubview:myTableview];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.myTableview.frame.size.width, 36)];
    label.text =@"Chatters Who Added Me";
    label.backgroundColor = [UIColor blueColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"DIN Alternate" size:15.0f];
    myTableview.tableHeaderView =label;
    
    _segmentedControl = [[SegmentedControl alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width,49)];
    [_segmentedControl setDelegate:self];
    [self setupSegmentedControl];
    
    
   HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * addDB = [[AddDB alloc]init];
    addDict = [addDB readDB:[handle getUserID]];
    NSArray * array = [addDict allKeys];
    for (int i = 0; i<[array count]; i++) {
         NSString *status = [addDict objectForKey:[array objectAtIndex:i]];
        if (![status isEqualToString:@"sendRequest"]) {
            [userData addObject:[array objectAtIndex:i]];
        }
    }
    
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userData count];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    UIButton * button;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(cell.frame.size.width-100, 15,60, 30)];
        button.tag = indexPath.row;
        [[button layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[button layer] setBorderWidth:1];
        [[button layer] setCornerRadius:4];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    if (userData && [userData count]!=0) {
        NSString *status = [addDict objectForKey:[userData objectAtIndex:indexPath.row]];
        if ([status isEqualToString:@"friend"]) {
            [button setTitle:@"friend" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deleteFriends:) forControlEvents:UIControlEventTouchUpInside];
            [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
            [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
            [self loadAvatar:[userData objectAtIndex:indexPath.row] withCell:cell];
            cell.textLabel.text = [userData objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
            [cell addSubview:button];
        }else if ([status isEqualToString:@"request"]){
            [button setTitle:@"add" forState:UIControlStateNormal];
            [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
            [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
            [self loadAvatar:[userData objectAtIndex:indexPath.row] withCell:cell];
            [button addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
            cell.textLabel.text = [userData objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
            [cell addSubview:button];
            
        }

    }
        return cell;

}
-(void)deleteFriends:(UIButton *)sender {
    
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * db = [[AddDB alloc]init];
    [db updateDB:[handle getUserID] withFriendID:[userData objectAtIndex:sender.tag] withStatus:@"request"];
    STreamCategoryObject *sto = [[STreamCategoryObject alloc]initWithCategory:[handle getUserID]];
    STreamObject * so = [[STreamObject alloc]init];
    [so setObjectId:[userData objectAtIndex:sender.tag]];
    [so addStaff:@"status" withObject:@"request"];
    NSMutableArray *update= [[NSMutableArray alloc] init] ;
    
    [update addObject:so];
    [sto updateStreamCategoryObjectsInBackground:update];
    
    NSString * loginName= [handle getUserID];
    STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:[userData objectAtIndex:sender.tag]];
    STreamObject *my = [[STreamObject alloc]init];
    
    [my setObjectId:loginName];
    [my addStaff:@"status" withObject:@"sendRequest"];
    NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
    
    [updateArray addObject:my];
    [sco updateStreamCategoryObjectsInBackground:updateArray];
    
    [sender setTitle:@"add" forState:UIControlStateNormal];
    [sender addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
    [self.myTableview reloadData];
}
-(void)addFriends:(UIButton *)sender {
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * db = [[AddDB alloc]init];

    [db updateDB:[handle getUserID] withFriendID:[userData objectAtIndex:sender.tag] withStatus:@"friend"];
    STreamCategoryObject *sto = [[STreamCategoryObject alloc]initWithCategory:[handle getUserID]];
    STreamObject * so = [[STreamObject alloc]init];
    [so setObjectId:[userData objectAtIndex:sender.tag]];
    [so addStaff:@"status" withObject:@"friend"];
    NSMutableArray *update = [[NSMutableArray alloc] init] ;
    
    [update addObject:so];
    [sto updateStreamCategoryObjects:update];
    
    
    STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:[userData objectAtIndex:sender.tag]];
    STreamObject *my = [[STreamObject alloc]init];
    [my setObjectId:[handle getUserID]];
    [my addStaff:@"status" withObject:@"friend"];
    NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
    
    [updateArray addObject:my];
    [sco updateStreamCategoryObjects:updateArray];
    
    [myTableview reloadData];
    [sender setTitle:@"friend" forState:UIControlStateNormal];
    [sender addTarget:self action:@selector(deleteFriends:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setupSegmentedControl
{
    UIImage *backgroundImage = [[UIImage imageNamed:@"segmented-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 10.0, 10.0)];
    [_segmentedControl setBackgroundImage:backgroundImage];
    [_segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [_segmentedControl setSegmentedControlMode:SegmentedControlModeButton];
    [_segmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];

    // Button 1
    UIButton *buttonSocial = [[UIButton alloc] init];
    UIImage *buttonSocialImageNormal = [UIImage imageNamed:@"segmented-pressed-left.png"];
    buttonSocial.tag = LEFT_BUTTON_TAG;
    [buttonSocial setImage:buttonSocialImageNormal forState:UIControlStateNormal];

    // Button 2
    UIButton *buttonStar = [[UIButton alloc] init];
    UIImage *buttonStarImageNormal = [UIImage imageNamed:@"segmented-bg-Right.png"];
    buttonStar.tag = RIGHT_BUTTON_TAG;
    [buttonStar setImage:buttonStarImageNormal forState:UIControlStateNormal];

    [_segmentedControl setButtonsArray:@[buttonSocial, buttonStar]];
    [_segmentedControl setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
    [self.view addSubview:_segmentedControl];
}
#pragma mark -
#pragma mark SegmentedControlDelegate

- (void)segmentedViewController:(SegmentedControl *)segmentedControl touchedAtIndex:(NSUInteger)index
{
    if (_segmentedControl == segmentedControl)
       
    if (index ==1 ) {
        SearchFriendsViewController * searchVC = [[SearchFriendsViewController alloc]init];
        
        UIButton * button =(UIButton *) [self.view viewWithTag:LEFT_BUTTON_TAG];
        [button setImage:[UIImage imageNamed:@"segmented-bg-left.png"] forState:UIControlStateNormal];
        UIButton * button2 =(UIButton *) [self.view viewWithTag:RIGHT_BUTTON_TAG];
        [button2 setImage:[UIImage imageNamed:@"segmented-pressed-Right.png"] forState:UIControlStateNormal];
        HandleViewController * handleVC =[[HandleViewController alloc]init];
        
        UITabBarItem *searchBar=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:1001];
        UITabBarItem *handleBar=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:1002];
        
        searchVC.tabBarItem = searchBar;
        
        handleVC.tabBarItem = handleBar;
        
        NSMutableArray * array = [[NSMutableArray alloc]init];
        
        UINavigationController * searchNav = [[UINavigationController alloc]initWithRootViewController:searchVC];
        UINavigationController * handleNav =[[UINavigationController alloc]initWithRootViewController:handleVC];
        
        [array addObject:searchNav];
        [array addObject:handleNav];
        
        TabBarViewController * tabBar = [[TabBarViewController alloc]init];
        tabBar.viewControllers = array;
        [tabBar.tabBar setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:229.0/255.0 blue:227.0/255.0 alpha:1.0]];
        [self presentViewController:tabBar animated:NO completion:NULL];
    }
    if (index == 0) {
        UIButton * button =(UIButton *) [self.view viewWithTag:LEFT_BUTTON_TAG];
        [button setImage:[UIImage imageNamed:@"segmented-pressed-left.png"] forState:UIControlStateNormal];

    }
}
-(void) loadAvatar:(NSString *)userID withCell:(UITableViewCell *)cell{
    ImageCache *imageCache = [ImageCache sharedObject];
    if ([imageCache getUserMetadata:userID]!=nil) {
        NSMutableDictionary *userMetaData = [imageCache getUserMetadata:userID];
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if ([imageCache getImage:pImageId] == nil && pImageId){
            FileCache *fileCache = [FileCache sharedObject];
            STreamFile *file = [[STreamFile alloc] init];
            if (![imageCache getImage:pImageId]){
                [file downloadAsData:pImageId downloadedData:^(NSData *imageData, NSString *oId) {
                    if ([pImageId isEqualToString:oId]){
                        [imageCache selfImageDownload:imageData withFileId:pImageId];
                        [fileCache writeFileDoc:pImageId withData:imageData];
                    }
                }];
            }
        }else{
            if ([pImageId isEqualToString:@""])
                [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
            else
                [cell.imageView setImage:[UIImage imageWithData:[imageCache getImage:pImageId]]];
        }
    }
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
