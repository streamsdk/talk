//
//  HandlerFirendsViewController.m
//  talk
//
//  Created by wangsh on 14-1-1.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "HandlerFirendsViewController.h"
#import "HandlerUserIdAndDateFormater.h"
#import "AddDB.h"
#import "SearchDB.h"
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamQuery.h>
#import "ImageCache.h"
#import "FileCache.h"
#import "MBProgressHUD.h"
#import "STreamXMPP.h"
#import <arcstreamsdk/JSONKit.h>
#import "DownloadAvatar.h"
#import "ReadStatus.h"
#define SENDREQUEST_TAG 1000
#define ADD_TAG  2000
#define DELETE_TAG 3000
#define SEARCH_TAG 10000
#define CELL_BUTTON_TAG 40000
#define SEARCH_LABEL_TAG 50000
@interface HandlerFirendsViewController ()
{
    UIBarButtonItem *refreshitem;
    UILabel *label ;
    NSMutableDictionary * addDict;
    BOOL isAddFriend;
    BOOL isSendRequest;
    UIButton * _button ;
    NSMutableArray * requestArray;
    NSMutableArray * friendArray;
}
@end

@implementation HandlerFirendsViewController
@synthesize searchBar=_searchBar;
@synthesize statusDict;

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
    NSMutableArray *objectID = [[NSMutableArray alloc]init];
    for (STreamObject *so in array) {
        [objectID addObject:[so objectId]];
    }
    AddDB * db = [[AddDB alloc]init];
    if ([friendsAddArray count]!=0 && [array count]!=0) {
        if ([friendsAddArray count]>[array count]) {
            for (int i = 0;i<[friendsAddArray count];i++) {
                NSString *friendId= [friendsAddArray objectAtIndex:i];
                if (![objectID containsObject:friendId]) {
                    NSString * status = [addDict objectForKey:friendId];
                    if ([status isEqualToString:@"request"]) {
                        [requestArray removeObject:friendId];
                    }
                    [friendsAddArray removeObject:friendId];
                    [db deleteDB:friendId];
                }
            }
        }
    }
    if ([array count]!=0) {
        for (STreamObject *so in array) {
            if ([friendsAddArray containsObject:[so objectId]]) {
                if (![[addDict objectForKey:[so objectId]] isEqualToString:[so getValue:@"status"]]) {
                    [db updateDB:[handler getUserID] withFriendID:[so objectId] withStatus:[so getValue:@"status"]];
                    [addDict removeObjectForKey:[so objectId]];
                    NSString * status = [addDict objectForKey:[so objectId]];
                    if ([status isEqualToString:@"request"]) {
                        [requestArray removeObject:[so objectId]];
                        [friendArray insertObject:[so objectId] atIndex:0];
                    }else{
                        [requestArray insertObject:[so objectId] atIndex:0];
                        [friendArray removeObject:[so objectId]];
                    }
                    [addDict setObject:[so getValue:@"status"] forKey:[so objectId]];
                }
            }else{
                
                [db insertDB:[handler getUserID] withFriendID:[so objectId] withStatus:[so getValue:@"status"]];
                if ([[so getValue:@"status"] isEqualToString:@"request"]) {
                    [requestArray insertObject:[so objectId] atIndex:0];
                }else{
                    [friendArray insertObject:[so objectId] atIndex:0];
                }
                
                [addDict setObject:[so getValue:@"status"] forKey:[so objectId]];
            }
            
        }
        
    }
    [friendsAddArray removeAllObjects];
    for (NSString * user in requestArray) {
        [friendsAddArray addObject:user];
    }
    for (NSString * user in friendArray) {
        [friendsAddArray addObject:user];
    }
}
-(void) refresh {
    switch (_friendsType) {
        case FriendsAdd:{
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
        }
            
            break;
        case FriendsSearch:
            
            break;
            
        case FriendsHistory:{
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            
            HUD.labelText = @"refresh friends...";
            [self.view addSubview:HUD];
            [HUD showAnimated:YES whileExecutingBlock:^{
                HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
                SearchDB * searchDB = [[SearchDB alloc]init];
                STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:[handler getUserID]];
                [sq setQueryLogicAnd:true];
                [sq whereEqualsTo:@"status" forValue:@"sendRequest"];
                NSMutableArray * friends = [sq find];
                for (STreamObject *so in friends) {
                    if (![friendsHistoryArray containsObject:[so objectId]]) {
                        [searchDB insertDB:[handler getUserID] withFriendID:[so objectId]];
                    }
                }
                friendsHistoryArray = [searchDB readSearchDB:[handler getUserID]];
            }completionBlock:^{
                [myTableview reloadData];
                [HUD removeFromSuperview];
                HUD = nil;
            }];
            
        }
            
            break;
            
        default:
            break;
    }
    
}

-(void) addFriends {
    
    UILabel * searchLabel = (UILabel *)[self.view viewWithTag:SEARCH_LABEL_TAG];
    [searchLabel removeFromSuperview];
    [myTableview removeFromSuperview];
    myTableview = [[UITableView alloc]initWithFrame:CGRectMake(-2, 100, self.view.frame.size.width+4, self.view.frame.size.height-100)];
    myTableview.dataSource = self;
    myTableview.delegate = self;
    [myTableview setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:myTableview];
    
    [_searchBar removeFromSuperview];
    _friendsType = FriendsAdd;
    self.title = @"Add Friends";
    NSArray * array = [addDict allKeys];
    for (int i = 0; i<[array count]; i++) {
        NSString *status = [addDict objectForKey:[array objectAtIndex:i]];
        if ([status isEqualToString:@"request"]) {
            if (![friendsAddArray containsObject:[array objectAtIndex:i]]) {
                [requestArray insertObject:[array objectAtIndex:i] atIndex:0];
                [friendsAddArray insertObject:[array objectAtIndex:i] atIndex:0];
            }
        }
        if ([status isEqualToString:@"friend"]) {
            if (![friendsAddArray containsObject:[array objectAtIndex:i]]) {
                [friendArray insertObject:[array objectAtIndex:i] atIndex:0];
            }
        }
    }
    [friendsAddArray removeAllObjects];
    for (NSString * user in requestArray) {
        [friendsAddArray addObject:user];
    }
    for (NSString * user in friendArray) {
        [friendsAddArray addObject:user];
    }
    
    
    refreshitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshitem;
}
-(void) searchFriends{
    
    [friendsSearchArray removeAllObjects];
    [myTableview removeFromSuperview];
    self.title = @"Search Friends";
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64+36, self.view.bounds.size.width, 40)];
    _searchBar.delegate = self;
    _searchBar.tag =SEARCH_TAG;
    _searchBar.barStyle=UIBarStyleDefault;
    _searchBar.placeholder=@"search";
    _searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self.view addSubview:_searchBar];
    
    UILabel * searchLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-300, self.view.frame.size.width,100)];
    searchLabel .backgroundColor = [UIColor clearColor];
    searchLabel.textColor = [UIColor lightGrayColor];
    searchLabel.text = @"search friends by user name";
    searchLabel.font = [UIFont systemFontOfSize:20.0f];
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchLabel.tag =SEARCH_LABEL_TAG;
    [self.view addSubview:searchLabel];
    
    self.navigationItem.rightBarButtonItem = nil;
    
}

-(void) historyFriends {
    UILabel * searchLabel = (UILabel *)[self.view viewWithTag:SEARCH_LABEL_TAG];
    [searchLabel removeFromSuperview];
    [_searchBar removeFromSuperview];
    _friendsType = FriendsHistory;
    self.title = @"Invitations Sent";
    
    [myTableview removeFromSuperview];
    myTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100)];
    myTableview.dataSource = self;
    myTableview.delegate = self;
    [myTableview setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:myTableview];
    
    
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    SearchDB * searchDB = [[SearchDB alloc]init];
    friendsHistoryArray = [searchDB readSearchDB:[handler getUserID]];
    
    refreshitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshitem;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    isAddFriend= YES;
    isSendRequest = NO;
    //    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    friendsAddPoint = CGPointZero;
    friendsSearchPoint = CGPointZero;
    friendsHistoryPoint = CGPointZero;
    requestArray  =[[NSMutableArray alloc]init];
    friendArray  =[[NSMutableArray alloc]init];
    friendsAddArray = [[NSMutableArray alloc]init];
    friendsSearchArray = [[NSMutableArray alloc]init];
    friendsHistoryArray = [[NSMutableArray alloc]init];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"",@"",@"",nil];
    
    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    
    segmentedControl.frame = CGRectMake(0, 64.0, self.view.bounds.size.width, 36.0);
    segmentedControl.selectedSegmentIndex = 0;
    
    //    segmentedControl.segmentedControlStyle=UISegmentedControlStyleBordered;
    [segmentedControl addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];
    //[segmentedControl setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundColor:[UIColor lightGrayColor]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blueColor],[UIFont fontWithName:@"DIN Alternate" size:17],nil];
    [segmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    
    [self.view addSubview:segmentedControl];
    
    [segmentedControl setImage:[[UIImage imageNamed:@"addf.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
    [segmentedControl setImage:[[UIImage imageNamed:@"searchf.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
    [segmentedControl setImage:[[UIImage imageNamed:@"mailf.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:2];
    
    
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * addDB = [[AddDB alloc]init];
    addDict = [addDB readDB:[handle getUserID]];
    [self addFriends];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (_friendsType) {
        case FriendsAdd:
            count = [friendsAddArray count];
            break;
        case FriendsSearch:
            count = [friendsSearchArray count];
            break;
        case FriendsHistory:
            count = [friendsHistoryArray count];
            break;
            
        default:
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EliteCellIdentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CALayer *l = [cell.imageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:8.0];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0f];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(cell.frame.size.width-38, 15, 30, 30)];
    //    button.tag = CELL_BUTTON_TAG;
    [cell addSubview:button];
    //    UIButton * button = (UIButton *)[cell viewWithTag:CELL_BUTTON_TAG];
    switch (_friendsType) {
        case FriendsAdd:{
            if (friendsAddArray && [friendsAddArray count]!=0) {
                NSString * userId = [friendsAddArray objectAtIndex:indexPath.row];
                NSString *status = [addDict objectForKey:userId];
                if ([status isEqualToString:@"friend"]) {
                    
                    [button setBackgroundImage:[UIImage imageNamed:@"friends.png"]  forState:UIControlStateNormal];
                    button.tag = indexPath.row;
                    [button addTarget:self action:@selector(deleteFriends:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
                    
                    DownloadAvatar * down = [[DownloadAvatar alloc]init];
                    UIImage * icon = [down loadAvatar:userId];
                    [self setImage:icon withCell:cell];
                    
                    cell.textLabel.text = [friendsAddArray objectAtIndex:indexPath.row];
                    
                }else if ([status isEqualToString:@"request"]){
                    [button setBackgroundImage:[UIImage imageNamed:@"addfriend.png"] forState:UIControlStateNormal];
                    button.tag = indexPath.row;
                    [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
                    
                    DownloadAvatar * down = [[DownloadAvatar alloc]init];
                    UIImage * icon = [down loadAvatar:userId];
                    [self setImage:icon withCell:cell];
                    
                    [button addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = [friendsAddArray objectAtIndex:indexPath.row];
                }
                ReadStatus * readstatus = [[ReadStatus alloc]init];
                cell.detailTextLabel.text = [readstatus readStatus:[friendsAddArray objectAtIndex:indexPath.row]];
                if ([cell.detailTextLabel.text length]>32) {
                    NSRange rg = {0,32};
                    NSString  *str = [cell.detailTextLabel.text substringWithRange:rg];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@...",str];
                }
            }
            
        }
            break;
        case FriendsSearch:{
            
            if (friendsSearchArray && [friendsSearchArray count]!=0) {
                
                NSString * userId = [friendsSearchArray objectAtIndex:indexPath.row];
                DownloadAvatar * down = [[DownloadAvatar alloc]init];
                UIImage * icon = [down loadAvatar:userId];
                [self setImage:icon withCell:cell];
                
                NSArray * array = [addDict allKeys];
                if ([array containsObject:userId]) {
                    NSString * status = [addDict objectForKey:userId];
                    
                    if ([status isEqualToString:@"request"]) {
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You need to add addFriends page！" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                        [alert show];
                        
                    }else {
                        [button setBackgroundImage:[UIImage imageNamed:@"friends.png"] forState:UIControlStateNormal];
                        button.tag = indexPath.row;
                        cell.textLabel.text = userId;
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You are already friends！" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    
                }else{
                    [button setBackgroundImage:[UIImage imageNamed:@"addfriend.png"] forState:UIControlStateNormal];
                    button.tag = indexPath.row;
                    [button addTarget:self action:@selector(addFriendSendRequest:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = userId;
                }
            }
            
        }
            
            break;
        case FriendsHistory:{
            [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
            DownloadAvatar * down = [[DownloadAvatar alloc]init];
            UIImage * icon = [down loadAvatar:[friendsHistoryArray objectAtIndex:indexPath.row]];
            [self setImage:icon withCell:cell];
            
            [button setBackgroundImage:[UIImage imageNamed:@"invi.png"] forState:UIControlStateNormal];
            button.tag = indexPath.row;
            cell.textLabel.text = [friendsHistoryArray objectAtIndex:indexPath.row];
            ReadStatus * readstatus = [[ReadStatus alloc]init];
            cell.detailTextLabel.text = [readstatus readStatus:[friendsHistoryArray objectAtIndex:indexPath.row]];
            if ([cell.detailTextLabel.text length]>32) {
                NSRange rg = {0,32};
                NSString  *str = [cell.detailTextLabel.text substringWithRange:rg];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@...",str];
            }
        }
            
            break;
        default:
            break;
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

-(void)setImage:(UIImage *)icon withCell:(UITableViewCell *)cell{
    CGSize itemSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

#pragma mark searchBarDelegate
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *string = searchBar.text;
    string = [string lowercaseString];
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    STreamUser * user = [[STreamUser alloc]init];
    NSString * loginName = [handler getUserID];
    
    UIAlertView * alertview= [[UIAlertView alloc]initWithTitle:@"" message:@"username is not a registered user" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", nil];
    
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Loading...";
    [self.view addSubview:HUD];
    __block BOOL isUserExist;
    [HUD showAnimated:YES whileExecutingBlock:^{
        isUserExist = [user searchUser:string];
        
    }completionBlock:^{
        if (isUserExist) {
            if (![loginName isEqualToString:string]) {
                [friendsSearchArray addObject:string];
            }
        }else{
            [alertview show];
        }
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
    
    
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    UILabel * searchLabel = (UILabel *)[self.view viewWithTag:SEARCH_LABEL_TAG];
    [searchLabel removeFromSuperview];
    [myTableview removeFromSuperview];
    myTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, self.view.frame.size.height-140)];
    myTableview.dataSource = self;
    myTableview.delegate = self;
    [myTableview setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:myTableview];
    [friendsSearchArray removeAllObjects];
    _friendsType = FriendsSearch;
    myTableview.bounces = NO;
    myTableview.alwaysBounceHorizontal = NO;
    myTableview.tableHeaderView = nil;
    [searchBar becomeFirstResponder];
    
    refreshitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelected)];
    self.navigationItem.rightBarButtonItem = refreshitem;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}
#pragma mark --segmentAction
-(void)segmentAction:(UISegmentedControl *)Seg{
    
    NSInteger index = Seg.selectedSegmentIndex;
    
    if (index == 0) {
        
        _friendsType = FriendsAdd;
        [self addFriends];
        [myTableview reloadData];
        
        [myTableview setContentOffset:friendsAddPoint];
    }
    else if (index == 1) {
        _friendsType = FriendsSearch;
        [self searchFriends];
        
        [myTableview reloadData];
        
        [myTableview setContentOffset:friendsSearchPoint];
    }
    else {
        _friendsType = FriendsHistory;
        [self historyFriends];
        [myTableview reloadData];
        
        [myTableview setContentOffset:friendsHistoryPoint];
    }
}
#pragma mark add friends

-(void)deleteFriends:(UIButton *)sender {
    _button = (UIButton *)sender;
    isAddFriend = NO;
    NSString * str = [NSString stringWithFormat:@"You want to delete this friend %@?",[friendsAddArray objectAtIndex:sender.tag]];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    alert.delegate = self;
    [alert show];
}

-(void)delete{
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * db = [[AddDB alloc]init];
    SearchDB * search = [[SearchDB alloc]init];
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"delete friend ...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        NSString * friendID = [friendsAddArray objectAtIndex:_button.tag];
        NSMutableArray * serarchArray=[ search readSearchDB:[handle getUserID]];
        if ([serarchArray containsObject:friendID]) {
            [db deleteDB:friendID];
            STreamObject * so = [[STreamObject alloc]init];
            [so setCategory:[handle getUserID]];
            [so setObjectId:[friendsAddArray objectAtIndex:_button.tag]];
            [so addStaff:@"status" withObject:@"sendRequest"];
            [so updateInBackground];
            
            
            STreamObject *my = [[STreamObject alloc]init];
            [my setCategory:[friendsAddArray objectAtIndex:_button.tag]];
            [my setObjectId:[handle getUserID]];
            [my addStaff:@"status" withObject:@"request"];
            [my updateInBackground];
            
            STreamXMPP *con = [STreamXMPP sharedObject];
            long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
            NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
            [jsonDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
            [jsonDic setObject:@"request" forKey:@"type"];
            [jsonDic setObject:[handle getUserID]forKey:@"username"];
            [jsonDic setObject:[friendsAddArray objectAtIndex:_button.tag] forKey:@"friendname"];
            NSString *jsonSent = [jsonDic JSONString];
            [con sendMessage:[friendsAddArray objectAtIndex:_button.tag] withMessage:jsonSent];
            
            [friendArray removeObject:[friendsAddArray objectAtIndex:_button.tag]];
            [addDict removeObjectForKey:[friendsAddArray objectAtIndex:_button.tag]];
            [friendsAddArray removeObject:[friendsAddArray objectAtIndex:_button.tag]];
        }else{
            [db updateDB:[handle getUserID] withFriendID:[friendsAddArray objectAtIndex:_button.tag] withStatus:@"request"];
            STreamObject * so = [[STreamObject alloc]init];
            [so setCategory:[handle getUserID]];
            [so setObjectId:[friendsAddArray objectAtIndex:_button.tag]];
            [so addStaff:@"status" withObject:@"request"];
            [so updateInBackground];
            
            
            STreamObject *my = [[STreamObject alloc]init];
            [my setCategory:[friendsAddArray objectAtIndex:_button.tag]];
            [my setObjectId:[handle getUserID]];
            [my addStaff:@"status" withObject:@"sendRequest"];
            [my updateInBackground];
            [_button setBackgroundImage:[UIImage imageNamed:@"addfriend.png"] forState:UIControlStateNormal];
            
            STreamXMPP *con = [STreamXMPP sharedObject];
            long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
            NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
            [jsonDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
            [jsonDic setObject:@"sendRequest" forKey:@"type"];
            [jsonDic setObject:[handle getUserID] forKey:@"username"];
            [jsonDic setObject:[friendsAddArray objectAtIndex:_button.tag] forKey:@"friendname"];
            NSString *jsonSent = [jsonDic JSONString];
            [con sendMessage:[friendsAddArray objectAtIndex:_button.tag] withMessage:jsonSent];
            [addDict setObject:@"request" forKey:[friendsAddArray objectAtIndex:_button.tag]];
            [requestArray insertObject:[friendsAddArray objectAtIndex:_button.tag] atIndex:0];
            [friendArray removeObject:[friendsAddArray objectAtIndex:_button.tag]];
            [friendsAddArray removeAllObjects];
            for (NSString * user in requestArray) {
                [friendsAddArray addObject:user];
            }
            for (NSString * user in friendArray) {
                [friendsAddArray addObject:user];
            }
            
        }
        
        
    }completionBlock:^{
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}

-(void)addFriends:(UIButton *)sender {
    
    isAddFriend = YES;
    _button = (UIButton *)sender;
    NSString * str = [NSString stringWithFormat:@"Do you want to add %@ as a friend?",[friendsAddArray objectAtIndex:sender.tag]];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    alert.delegate = self;
    [alert show];
}
-(void)add {
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * db = [[AddDB alloc]init];
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"add friend ...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [db updateDB:[handle getUserID] withFriendID:[friendsAddArray objectAtIndex:_button.tag] withStatus:@"friend"];
        STreamObject * so = [[STreamObject alloc]init];
        [so setCategory:[handle getUserID]];
        [so setObjectId:[friendsAddArray objectAtIndex:_button.tag]];
        [so addStaff:@"status" withObject:@"friend"];
        [so updateInBackground];
        
        STreamObject *my = [[STreamObject alloc]init];
        [my setCategory:[friendsAddArray objectAtIndex:_button.tag]];
        [my setObjectId:[handle getUserID]];
        [my addStaff:@"status" withObject:@"friend"];
        [my updateInBackground];
        
        STreamXMPP *con = [STreamXMPP sharedObject];
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        [jsonDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
        [jsonDic setObject:@"friend" forKey:@"type"];
        [jsonDic setObject:[handle getUserID] forKey:@"username"];
        [jsonDic setObject:[friendsAddArray objectAtIndex:_button.tag] forKey:@"friendname"];
        NSString *jsonSent = [jsonDic JSONString];
        [con sendMessage:[friendsAddArray objectAtIndex:_button.tag] withMessage:jsonSent];
        
        [_button setBackgroundImage:[UIImage imageNamed:@"addfriend.png"] forState:UIControlStateNormal];
        [addDict setObject:@"friend" forKey:[friendsAddArray objectAtIndex:_button.tag]];
        [requestArray removeObject:[friendsAddArray objectAtIndex:_button.tag]];
        [friendArray insertObject:[friendsAddArray objectAtIndex:_button.tag] atIndex:0];
        [friendsAddArray removeAllObjects];
        for (NSString * user in requestArray) {
            [friendsAddArray addObject:user];
        }
        for (NSString * user in friendArray) {
            [friendsAddArray addObject:user];
        }
        
    }completionBlock:^{
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
    
}
-(void) addFriendSendRequest:(UIButton *) sender {
    _button = (UIButton *)sender;
    isSendRequest = YES;
    NSString * str = [NSString stringWithFormat:@"Are you sure the invitation sent to %@?",[friendsSearchArray objectAtIndex:_button.tag]];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    alert.delegate = self;
    [alert show];
    
}
-(void) sendRequest{
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName= [handler getUserID];
    NSString * string= [friendsSearchArray objectAtIndex:_button.tag];
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"send invitation ...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        STreamObject * so = [[STreamObject alloc]init];
        [so setCategory:loginName];
        [so setObjectId:string];
        [so addStaff:@"status" withObject:@"sendRequest"];
        [so updateInBackground];
        
        STreamObject *my = [[STreamObject alloc]init];
        [my setCategory:string];
        [my setObjectId:loginName];
        [my addStaff:@"status" withObject:@"request"];
        [my updateInBackground];
        
        SearchDB * db = [[SearchDB alloc]init];
        NSMutableArray *sendData=[db  readSearchDB:[handler getUserID]];
        if (![sendData containsObject:string]) {
            [db insertDB:[handler getUserID] withFriendID:string];
        }
        
        STreamXMPP *con = [STreamXMPP sharedObject];
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        [jsonDic setObject:[NSString stringWithFormat:@"%lld", milliseconds] forKey:@"id"];
        [jsonDic setObject:@"request" forKey:@"type"];
        [jsonDic setObject:loginName forKey:@"username"];
        [jsonDic setObject:string forKey:@"friendname"];
        NSString *jsonSent = [jsonDic JSONString];
        [con sendMessage:string withMessage:jsonSent];
    }completionBlock:^{
        [_button setBackgroundImage:[UIImage imageNamed:@"invi.png"] forState:UIControlStateNormal];
        [_button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
    
    
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (isSendRequest) {
        if (buttonIndex==1) {
            [self sendRequest];
            isSendRequest = NO;
        }
    }else{
        if (isAddFriend) {
            if (buttonIndex==1) {
                [self add];
                isAddFriend = NO;
            }else{
                isAddFriend = NO;
            }
        }else{
            if (buttonIndex==1) {
                [self delete];
                isAddFriend = YES;
            }else{
                isAddFriend = YES;
            }
        }
    }
}

-(void) cancelSelected {
    UISearchBar *searchBar =(UISearchBar *)[self.view viewWithTag:SEARCH_TAG];
    searchBar.text = @"";
    searchBar.placeholder = @"Search";
    [searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
