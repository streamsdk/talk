//
//  SearchFriendsViewController.m
//  talk
//
//  Created by wangsh on 13-12-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SearchFriendsViewController.h"
#import "MainController.h"
#import "MBProgressHUD.h"
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import "AddFriendsViewController.h"
#import "HandlerUserIdAndDateFormater.h"
#import "SearchDB.h"
#import "AddDB.h"

#define SEARCH_TAG 10000
#define LEFT_BUTTON_TAG 1000
#define RIGHT_BUTTON_TAG 2000
@interface SearchFriendsViewController ()
{
    UIButton *button;
    NSMutableDictionary *allFriend;
}
@end

@implementation SearchFriendsViewController

@synthesize myTableview,userData;
@synthesize searchBar=_searchBar;

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

    self.title = @"Add Friends";
    userData = [[NSMutableArray alloc]init];
    self.navigationItem.hidesBackButton = YES;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelected)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    myTableview  = [[UITableView alloc]initWithFrame:CGRectMake(0,90, self.view.bounds.size.width, self.view.bounds.size.height-90-50)];
    myTableview.backgroundColor = [UIColor clearColor];
    myTableview.delegate = self;
    myTableview.dataSource = self;
    [self.view addSubview:myTableview];
    allFriend = [[NSMutableDictionary alloc]init];
    
    _segmentedControl = [[SegmentedControl alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width,49)];
    [_segmentedControl setDelegate:self];
    [self setupSegmentedControl];

    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64+47, self.view.bounds.size.width, 50)];
    _searchBar.delegate = self;
    _searchBar.tag =SEARCH_TAG;
    _searchBar.barStyle=UIBarStyleDefault;
    _searchBar.placeholder=@"search";
    _searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    [self.view addSubview:_searchBar];
    
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * addDB = [[AddDB alloc]init];
    allFriend = [addDB readDB:[handler getUserID]];

    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = indexPath.row;
        [[button layer] setBorderColor:[[UIColor blueColor] CGColor]];
        [[button layer] setBorderWidth:1];
        [[button layer] setCornerRadius:4];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [cell addSubview:button];
        
    }
   
    if (userData && [userData count]!=0) {
        NSString * str = [userData objectAtIndex:indexPath.row];
        NSArray * array = [allFriend allKeys];
        if ([array containsObject:str]) {
            NSString * status = [allFriend objectForKey:[array objectAtIndex:indexPath.row]];

            if ([status isEqualToString:@"request"]) {
                [button setFrame:CGRectMake(cell.frame.size.width-100, 7,60, 30)];
                [button setTitle:@"add" forState:UIControlStateNormal];
                //                [button addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You need to add addFriends page！" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"Cancel", nil];
                [alert show];
                
            }else {
                [button setFrame:CGRectMake(cell.frame.size.width-100, 7, 60, 30)];
                [button setTitle:@"friend" forState:UIControlStateNormal];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You are already friends！" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"Cancel", nil];
                [alert show];
            }

        }else{
            [button setFrame:CGRectMake(cell.frame.size.width-100, 7, 60, 30)];
            [button setTitle:@"add" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addFriendSendRequest:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.textLabel.text = str;
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0f];
    }
    return cell;
}

#pragma mark searchBarDelegate
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
     NSString *string = searchBar.text;
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    STreamUser * user = [[STreamUser alloc]init];
    NSString * loginName = [handler getUserID];
    BOOL isUserExist = [user searchUser:string];
    
    if (isUserExist) {
        if (![loginName isEqualToString:string]) {
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"loading friends...";
            [self.view addSubview:HUD];
            [HUD showAnimated:YES whileExecutingBlock:^{
                [userData removeAllObjects];
                [userData addObject:string];
            }completionBlock:^{
                [myTableview reloadData];
                [HUD removeFromSuperview];
                HUD = nil;
            }];

        }
    }else{
        UIAlertView * alertview= [[UIAlertView alloc]initWithTitle:@"" message:@"No results found" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alertview show];
    }
    }

-(void) cancelSelected {
    UISearchBar *searchBar =(UISearchBar *)[self.view viewWithTag:SEARCH_TAG];
    searchBar.text = @"";
    searchBar.placeholder = @"Search";
    [searchBar resignFirstResponder];
}

-(void) addFriendSendRequest:(UIButton *) sender {
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName= [handler getUserID];
    NSString *string= [userData objectAtIndex:sender.tag];
    
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"send request friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        STreamCategoryObject *sto = [[STreamCategoryObject alloc]initWithCategory:[handler getUserID]];
        STreamObject * so = [[STreamObject alloc]init];
        [so setObjectId:string];
        [so addStaff:@"status" withObject:@"sendRequest"];
        [so setCategory:loginName];
        [so updateInBackground];
        NSMutableArray *update = [[NSMutableArray alloc] init] ;
        [update addObject:so];
        [sto updateStreamCategoryObjects:update];

        
        STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:string];
        STreamObject *my = [[STreamObject alloc]init];
        [my setObjectId:loginName];
        [my addStaff:@"status" withObject:@"request"];
        NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
        [updateArray addObject:my];
        [sco updateStreamCategoryObjects:updateArray];
    }completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
    }];
    SearchDB * db = [[SearchDB alloc]init];
    [db insertDB:[handler getUserID] withFriendID:string];
    [button setFrame:CGRectMake(220, 7, 100, 30)];
    [button setTitle:@"sendRequest" forState:UIControlStateNormal];
  
}

- (void)setupSegmentedControl
{
    UIImage *backgroundImage = [[UIImage imageNamed:@"segmented-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 10.0, 10.0)];
    [_segmentedControl setBackgroundImage:backgroundImage];
    [_segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [_segmentedControl setSegmentedControlMode:SegmentedControlModeButton];
    [_segmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    
    [_segmentedControl setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
    
    // Button 1
    UIButton *buttonSocial = [[UIButton alloc] init];
    UIImage *buttonSocialImageNormal = [UIImage imageNamed:@"segmented-bg-left.png"];
    [buttonSocial setImage:buttonSocialImageNormal forState:UIControlStateNormal];
   
    button.tag = LEFT_BUTTON_TAG;
    // Button 2
    UIButton *buttonStar = [[UIButton alloc] init];
    UIImage *buttonStarImageNormal = [UIImage imageNamed:@"segmented-pressed-Right.png"];
    button.tag = RIGHT_BUTTON_TAG;
    [buttonStar setImage:buttonStarImageNormal forState:UIControlStateNormal];
    [_segmentedControl setButtonsArray:@[buttonSocial, buttonStar]];
    [self.view addSubview:_segmentedControl];
}

#pragma mark -
#pragma mark SegmentedControlDelegate

- (void)segmentedViewController:(SegmentedControl *)segmentedControl touchedAtIndex:(NSUInteger)index
{
    if (_segmentedControl == segmentedControl)
        NSLog(@"SegmentedControl #1 : Selected Index %d", index);
    if (index ==0) {
        AddFriendsViewController * add = [[AddFriendsViewController alloc]init];
        [self.navigationController pushViewController:add animated:NO];
        UIButton * button1 = (UIButton *)[self.view viewWithTag:LEFT_BUTTON_TAG];
        [button1 setImage:[UIImage imageNamed:@"segmented-pressed-left.png" ]forState:UIControlStateNormal];
    }
    if (index == 1) {
        UIButton * button1 = (UIButton *)[self.view viewWithTag:RIGHT_BUTTON_TAG];
        [button1 setImage:[UIImage imageNamed:@"segmented-pressed-Right.png" ]forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
