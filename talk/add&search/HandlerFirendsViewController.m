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

#define SENDREQUEST_TAG 1000
#define ADD_TAG  2000
#define DELETE_TAG 3000
#define SEARCH_TAG 10000
@interface HandlerFirendsViewController ()
{
    UIBarButtonItem *refreshitem;
    UILabel *label ;
    NSMutableDictionary * addDict;
    BOOL isAddFriend;
    BOOL isSendRequest;
    UIButton * _button ;
}
@end

@implementation HandlerFirendsViewController
@synthesize searchBar=_searchBar;
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
    
    for (STreamObject *so in array) {
        if (![friendsAddArray containsObject:[so objectId]]) {
            [db insertDB:[handler getUserID] withFriendID:[so objectId] withStatus:[so getValue:@"status"]];
            [friendsAddArray addObject:[so objectId]];
            [addDict setObject:[so getValue:@"status"] forKey:[so objectId]];
        }
        
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
            HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
            SearchDB * searchDB = [[SearchDB alloc]init];
            STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:[handler getUserID]];
            [sq setQueryLogicAnd:true];
            [sq whereEqualsTo:@"status" forValue:@"sendRequest"];
            /*[sq find:^(NSMutableArray *friends){
                for (STreamObject *so in friends) {
                    if (![friendsHistoryArray containsObject:[so objectId]]) {
                        [searchDB insertDB:[handler getUserID] withFriendID:[so objectId]];
                    }
                }
                [myTableview reloadData];
            }];*/
            NSMutableArray * friends = [sq find];
            for (STreamObject *so in friends) {
                if (![friendsHistoryArray containsObject:[so objectId]]) {
                    [searchDB insertDB:[handler getUserID] withFriendID:[so objectId]];
                }
                    }
            friendsHistoryArray = [searchDB readSearchDB:[handler getUserID]];
            [myTableview reloadData];

        }
            
            break;
            
        default:
            break;
    }

}

-(void) addFriends {

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
        if (![status isEqualToString:@"sendRequest"]) {
            if (![friendsAddArray containsObject:[array objectAtIndex:i]]) {
                [friendsAddArray addObject:[array objectAtIndex:i]];
            }
        }
    }
    refreshitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshitem;
}
-(void) searchFriends{
    
    [myTableview removeFromSuperview];
    myTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, self.view.frame.size.height-140)];
    myTableview.dataSource = self;
    myTableview.delegate = self;
    [myTableview setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:myTableview];
    
    [friendsSearchArray removeAllObjects];
    _friendsType = FriendsSearch;
    self.title = @"Search Friends";
    myTableview.tableHeaderView = nil;
    [self.view addSubview:_searchBar];

    refreshitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelected)];
    self.navigationItem.rightBarButtonItem = refreshitem;

}

-(void) historyFriends {
    [_searchBar removeFromSuperview];
    _friendsType = FriendsHistory;
    self.title = @"Hostory Friends";
    
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
    isAddFriend= NO;
    isSendRequest = NO;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    friendsAddPoint = CGPointZero;
    friendsSearchPoint = CGPointZero;
    friendsHistoryPoint = CGPointZero;
    
    friendsAddArray = [[NSMutableArray alloc]init];
    friendsSearchArray = [[NSMutableArray alloc]init];
    friendsHistoryArray = [[NSMutableArray alloc]init];
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64+36, self.view.bounds.size.width, 40)];
    _searchBar.delegate = self;
    _searchBar.tag =SEARCH_TAG;
    _searchBar.barStyle=UIBarStyleDefault;
    _searchBar.placeholder=@"search";
    _searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"Add",@"Search",@"History",nil];
    
    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];

    segmentedControl.frame = CGRectMake(0, 64.0, self.view.bounds.size.width, 36.0);
    segmentedControl.selectedSegmentIndex = 0;
    
    segmentedControl.segmentedControlStyle=UISegmentedControlStyleBordered;
    [segmentedControl addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];
   [segmentedControl setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundColor:[UIColor brownColor]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blueColor],UITextAttributeTextColor,[UIFont fontWithName:@"DIN Alternate" size:17],UITextAttributeFont ,nil];
    [segmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];

    [self.view addSubview:segmentedControl];
    
                                                        
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIButton * button;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = indexPath.row;
        //[[button layer] setBorderColor:[[UIColor blueColor] CGColor]];
        //[[button layer] setBorderWidth:1];
        //[[button layer] setCornerRadius:4];
        //[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        
        CALayer *l = [cell.imageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:8.0];
    }
    
    switch (_friendsType) {
        case FriendsAdd:{
            [button setFrame:CGRectMake(cell.frame.size.width-100, 15, 32, 32)];
            if (friendsAddArray && [friendsAddArray count]!=0) {
                NSString *status = [addDict objectForKey:[friendsAddArray objectAtIndex:indexPath.row]];
                if ([status isEqualToString:@"friend"]) {
                    //[button setTitle:@"friend" forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:@"friends.png"] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(deleteFriends:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
                    [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
                    [self loadAvatar:[friendsAddArray objectAtIndex:indexPath.row] withCell:cell];
                    cell.textLabel.text = [friendsAddArray objectAtIndex:indexPath.row];
                    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
                    [cell addSubview:button];
                }else if ([status isEqualToString:@"request"]){
                   // [button setTitle:@"add" forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:@"addfriend.png"] forState:UIControlStateNormal];
                    [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
                    [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
                    [self loadAvatar:[friendsAddArray objectAtIndex:indexPath.row] withCell:cell];
                    [button addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = [friendsAddArray objectAtIndex:indexPath.row];
                    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
                    [cell addSubview:button];
                    
                }
                
            }

        }
            break;
        case FriendsSearch:{
            if (friendsSearchArray && [friendsSearchArray count]!=0) {
                
                NSString * str = [friendsSearchArray objectAtIndex:indexPath.row];
                [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
                [self loadAvatar:[friendsSearchArray objectAtIndex:indexPath.row] withCell:cell];
                NSArray * array = [addDict allKeys];
                if ([array containsObject:str]) {
                    NSString * status = [addDict objectForKey:str];

                    if ([status isEqualToString:@"request"]) {
                        [button setFrame:CGRectMake(cell.frame.size.width-100, 15,60, 30)];
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You need to add addFriends page！" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                        [alert show];
                        
                    }else {
                        [button setFrame:CGRectMake(cell.frame.size.width-100, 15, 60, 30)];
                        [button setTitle:@"friend" forState:UIControlStateNormal];
                        cell.textLabel.text = str;
                        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0f];
                        [cell addSubview:button];
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You are already friends！" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    
                }else{
                    [button setFrame:CGRectMake(cell.frame.size.width-100, 15, 32, 32)];
                   // [button setTitle:@"add" forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:@"addfriend.png"] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(addFriendSendRequest:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = str;
                    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0f];
                    [cell addSubview:button];
                    
                }
            }

        }
            
            break;
        case FriendsHistory:{
            [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
            [self loadAvatar:[friendsHistoryArray objectAtIndex:indexPath.row] withCell:cell];
            [button setFrame:CGRectMake(cell.frame.size.width-100, 15, 32, 32)];
//            friendsSearchArray = friendsHistoryArray;
            [button setBackgroundImage:[UIImage imageNamed:@"invitation.png"] forState:UIControlStateNormal];
//            [button addTarget:self action:@selector(addFriendSendRequest:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            cell.textLabel.text = [friendsHistoryArray objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
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
#pragma mark searchBarDelegate
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    NSString *string = searchBar.text;
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    STreamUser * user = [[STreamUser alloc]init];

    NSString * loginName = [handler getUserID];
    BOOL isUserExist = [user searchUser:string];
    if (isUserExist) {
        __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.labelText = @"loading friends...";
        [self.view addSubview:HUD];
        [HUD showAnimated:YES whileExecutingBlock:^{
            if (![loginName isEqualToString:string]) {
                [friendsSearchArray removeAllObjects];
                [friendsSearchArray addObject:string];
            }
        }completionBlock:^{
            [myTableview reloadData];
            [HUD removeFromSuperview];
            HUD = nil;
        }];

    }else{
        [friendsSearchArray removeAllObjects];

        UIAlertView * alertview= [[UIAlertView alloc]initWithTitle:@"" message:@"No results found" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alertview show];
    }
    
    
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
    
    isAddFriend = NO;
    _button = (UIButton *)sender;
    NSString * str = [NSString stringWithFormat:@"You want to delete this friend %@?",[friendsAddArray objectAtIndex:sender.tag]];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    alert.delegate = self;
    [alert show];

    
}

-(void)delete{
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * db = [[AddDB alloc]init];
    [db updateDB:[handle getUserID] withFriendID:[friendsAddArray objectAtIndex:_button.tag] withStatus:@"request"];
    STreamCategoryObject *sto = [[STreamCategoryObject alloc]initWithCategory:[handle getUserID]];
    STreamObject * so = [[STreamObject alloc]init];
    [so setObjectId:[friendsAddArray objectAtIndex:_button.tag]];
    [so addStaff:@"status" withObject:@"request"];
    [so setCategory:@""];
    NSMutableArray *update= [[NSMutableArray alloc] init] ;
    
    [update addObject:so];
    [sto updateStreamCategoryObjectsInBackground:update];
    
    NSString * loginName= [handle getUserID];
    STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:[friendsAddArray objectAtIndex:_button.tag]];
    STreamObject *my = [[STreamObject alloc]init];
    
    [my setObjectId:loginName];
    [my addStaff:@"status" withObject:@"sendRequest"];
    NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
    
    [updateArray addObject:my];
    [sco updateStreamCategoryObjectsInBackground:updateArray];
    
    [_button setBackgroundImage:[UIImage imageNamed:@"addfriend.png"] forState:UIControlStateNormal];
    //[sender setTitle:@"add" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
    [myTableview reloadData];
}

-(void)addFriends:(UIButton *)sender {
    
    _button = (UIButton *)sender;
    
    isAddFriend = YES;
    NSString * str = [NSString stringWithFormat:@"Do you want to add %@ as a friend?",[friendsAddArray objectAtIndex:sender.tag]];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    alert.delegate = self;
    [alert show];
    
}
-(void)add {
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * db = [[AddDB alloc]init];
    
    [db updateDB:[handle getUserID] withFriendID:[friendsAddArray objectAtIndex:_button.tag] withStatus:@"friend"];
    STreamCategoryObject *sto = [[STreamCategoryObject alloc]initWithCategory:[handle getUserID]];
    STreamObject * so = [[STreamObject alloc]init];
    [so setObjectId:[friendsAddArray objectAtIndex:_button.tag]];
    [so addStaff:@"status" withObject:@"friend"];
    NSMutableArray *update = [[NSMutableArray alloc] init] ;
    
    [update addObject:so];
    [sto updateStreamCategoryObjects:update];
    
    
    STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:[friendsAddArray objectAtIndex:_button.tag]];
    STreamObject *my = [[STreamObject alloc]init];
    [my setObjectId:[handle getUserID]];
    [my addStaff:@"status" withObject:@"friend"];
    NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
    
    [updateArray addObject:my];
    [sco updateStreamCategoryObjectsInBackground:updateArray];
    
    [myTableview reloadData];
    [_button setBackgroundImage:[UIImage imageNamed:@"friends.png"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(deleteFriends:) forControlEvents:UIControlEventTouchUpInside];
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
    STreamCategoryObject *sto = [[STreamCategoryObject alloc]initWithCategory:[handler getUserID]];
    STreamObject * so = [[STreamObject alloc]init];
    [so setObjectId:string];
    [so addStaff:@"status" withObject:@"sendRequest"];
    [so setCategory:loginName];
    [so updateInBackground];
    NSMutableArray *update = [[NSMutableArray alloc] init] ;
    [update addObject:so];
    [sto updateStreamCategoryObjectsInBackground:update];
    
    
    STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:string];
    STreamObject *my = [[STreamObject alloc]init];
    [my setObjectId:loginName];
    [my addStaff:@"status" withObject:@"request"];
    NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
    [updateArray addObject:my];
    [sco updateStreamCategoryObjectsInBackground:updateArray];
    
    SearchDB * db = [[SearchDB alloc]init];
    [db insertDB:[handler getUserID] withFriendID:string];
    [_button setFrame:CGRectMake(220, 15, 32, 32)];
    // [sender setTitle:@"sendRequest" forState:UIControlStateNormal];
    [_button setBackgroundImage:[UIImage imageNamed:@"invitation.png"] forState:UIControlStateNormal];
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
            }
        }else{
            if (buttonIndex==1) {
                [self delete];
            }
        }
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
            if ([pImageId isEqualToString:@""]){
                UIImage *icon =[UIImage imageNamed:@"headImage.jpg"];
                CGSize itemSize = CGSizeMake(50, 50);
                UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [icon drawInRect:imageRect];
                
                cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else{
                UIImage *icon =[UIImage imageWithData:[imageCache getImage:pImageId]];
                CGSize itemSize = CGSizeMake(50, 50);
                UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [icon drawInRect:imageRect];
                
                cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
        }
    }else {
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:userID response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:userID]){
                NSMutableDictionary *dic = [user userMetadata];
                ImageCache *imageCache = [ImageCache sharedObject];
                [imageCache saveUserMetadata:userID withMetadata:dic];
            }
        }];
           [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
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
