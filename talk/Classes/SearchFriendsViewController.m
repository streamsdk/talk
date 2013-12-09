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
#import "SearchData.h"

#define SEARCH_TAG 10000
@interface SearchFriendsViewController ()
{
    UIButton *button;
    SearchData * _searchData;
    NSMutableArray *allFriend;
}
@end

@implementation SearchFriendsViewController

@synthesize myTableview,userData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Add Friends";
//    _searchData = [SearchData sharedObject];
//    userData = [_searchData getSearchData];
    userData = [[NSMutableArray alloc]init];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelected)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    myTableview  = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    myTableview.backgroundColor = [UIColor clearColor];
    myTableview.delegate = self;
    myTableview.dataSource = self;
    [self.view addSubview:myTableview];
    
    
    UISearchBar * searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 50)];
    searchBar.delegate = self;
    searchBar.tag =SEARCH_TAG;
    searchBar.barStyle=UIBarStyleDefault;
    searchBar.placeholder=@"search";
    searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    [self.view addSubview:searchBar];
    
    //searchbar background
   /* UIView *segment = [searchBar.subviews objectAtIndex:0];
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [segment addSubview: bgImage];*/
    
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
        [button setFrame:CGRectMake(cell.frame.size.width-60, 2, 40, 40)];
        [cell addSubview:button];
        
    }
    NSString * str;
    if (userData && [userData count]!=0) {
        str =  [userData objectAtIndex:indexPath.row];
        if (allFriend && [allFriend count]!=0) {
            for (STreamObject *so in allFriend) {
                if ([str isEqualToString:[so objectId]]) {
                    NSString *status = [so getValue:@"status"];

                   if ([status isEqualToString:@"friend"]){
                        
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"You are already friends！" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"Cancel", nil];
                        [alert show];
                   }else  if ([status isEqualToString:@"request"]) {
                       [button setImage:[UIImage imageNamed:@"add.png"]forState:UIControlStateNormal];
                       [button addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
                       cell.textLabel.text = str;
                   }else  if ([status isEqualToString:@"sendRequest"]) {
                      cell.textLabel.text = str;
                   }
                }else{
                    [button setImage:[UIImage imageNamed:@"add.png"]forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(addFriendSendRequest:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = str;
                }
            }
        }else{
            [button setImage:[UIImage imageNamed:@"add.png"]forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addFriendSendRequest:) forControlEvents:UIControlEventTouchUpInside];
            cell.textLabel.text = str;
        }
    
        
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
    }
    
    return cell;
}
-(void) searchFriends:(NSString *)userName {
    STreamUser * user = [[STreamUser alloc]init];
    
    NSString * loginName = [self getLoginName];
    STreamQuery *sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq addLimitId:userName];
    allFriend = [sq find];

    if (![userName isEqualToString:loginName]) {
        [user isUserExists:userName response:^(BOOL exists, NSString *resposne) {
            if (exists) {
                [userData addObject:userName];
                NSLog(@"%@",resposne);
            }else{
                UIAlertView * alertview= [[UIAlertView alloc]initWithTitle:@"" message:@"No results found" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alertview show];
            }
        }];
    }
}

- (NSString *)getLoginName {
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    return loginName;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *loginName  = [self getLoginName];
    STreamQuery * sq = [[STreamQuery alloc]initWithCategory:loginName];
    NSMutableArray * all = [sq find];
    NSString *userName= [userData objectAtIndex:indexPath.row];
    for (STreamObject *id in all) {
        if ([userName isEqualToString:[id objectId]]) {
            
        }
    }
    STreamObject * so = [[STreamObject alloc]init];
    [so setObjectId:userName];
    [so addStaff:@"status" withObject:@"request"];
    [so setCategory:loginName];
    [so updateInBackground];
    
//    MainController *mainVC = [[MainController alloc]init];
//    [mainVC setSendToID:userName];
//    self.tabBarController.tabBar.hidden = YES;
//    [self.navigationController pushViewController:mainVC animated:YES];
}
#pragma mark searchBarDelegate
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
     NSString *string = searchBar.text;
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"loading friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self searchFriends:string];
    }completionBlock:^{
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}

-(void) cancelSelected {
    UISearchBar *searchBar =(UISearchBar *)[self.view viewWithTag:SEARCH_TAG];
    searchBar.text = @"";
    searchBar.placeholder = @"Search";
    [searchBar resignFirstResponder];
}

-(void)addFriends:(UIButton *)sender {
   
    NSString * loginName= [self getLoginName];
    NSString *string= [userData objectAtIndex:sender.tag];
    
    STreamObject * so = [[STreamObject alloc]init];
    [so setObjectId:string];

    [so setObjectId:[so objectId]];
    [so addStaff:@"status" withObject:@"friend"];
    [so updateInBackground];
 
    
    STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:string];
    STreamObject *my = [[STreamObject alloc]init];
    [my setObjectId:loginName];
    [my addStaff:@"status" withObject:@"friend"];
    NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
    [updateArray addObject:my];
    [sco updateStreamCategoryObjects:updateArray];

    [button setImage:[UIImage imageNamed:@"selectAdd.png"]forState:UIControlStateNormal];

}
-(void) addFriendSendRequest:(UIButton *) sender {

    NSString * loginName= [self getLoginName];
    NSString *string= [userData objectAtIndex:sender.tag];
    
    STreamObject * so = [[STreamObject alloc]init];
    [so setObjectId:string];
    [so addStaff:@"status" withObject:@"sendRequest"];
    [so setCategory:loginName];
    [so updateInBackground];
    
    
    STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:string];
    STreamObject *my = [[STreamObject alloc]init];
    [my setObjectId:loginName];
    [my addStaff:@"status" withObject:@"request"];
    NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
    [updateArray addObject:my];
    [sco updateStreamCategoryObjects:updateArray];
    
    [button setImage:[UIImage imageNamed:@"selectAdd.png"]forState:UIControlStateNormal];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
