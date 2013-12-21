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

#define LEFT_BUTTON_TAG 1000
#define RIGHT_BUTTON_TAG 2000

@interface AddFriendsViewController ()

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
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq setQueryLogicAnd:FALSE];
    [sq whereEqualsTo:@"status" forValue:@"friend"];
    
    [sq whereEqualsTo:@"status" forValue:@"request"];
    
    userData = [sq find];

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
    UIBarButtonItem * leftitem = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftitem;
    
    
    userData = [[NSMutableArray alloc]init];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    myTableview  = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    myTableview.backgroundColor = [UIColor clearColor];
    myTableview.delegate = self;
    myTableview.dataSource = self;
    [self.view addSubview:myTableview];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.myTableview.frame.size.width, 44)];
    label.text =@"Chatters Who Added Me";
    label.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:203.0/255.0 blue:198.0/255.0 alpha:1.0];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"Arial" size:18.0f];
    myTableview.tableHeaderView =label;
    
    _segmentedControl = [[SegmentedControl alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width,49)];
    [_segmentedControl setDelegate:self];
    [self setupSegmentedControl];
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"loading friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadFriends];
    }completionBlock:^{
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
  
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
        [cell addSubview:button];
    }
    STreamObject * so = [userData objectAtIndex:indexPath.row];
    NSString *status = [so getValue:@"status"];
    if ([status isEqualToString:@"friend"]) {
        [button setTitle:@"friend" forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"selectAdd.png"]forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteFriends:) forControlEvents:UIControlEventTouchUpInside];
        [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
        [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
        [self loadAvatar:[so objectId] withCell:cell];
        cell.textLabel.text = [so objectId];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
    }else if ([status isEqualToString:@"request"]){
        [button setTitle:@"add" forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"add.png"]forState:UIControlStateNormal];
        [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
        [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
        [self loadAvatar:[so objectId] withCell:cell];
        [button addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
        cell.textLabel.text = [so objectId];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];

    }
    return cell;

}
-(void)deleteFriends:(UIButton *)sender {
    
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"loading friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        STreamObject * so = [userData objectAtIndex:sender.tag];
        [so setObjectId:[so objectId]];
        [so addStaff:@"status" withObject:@"request"];
        [so updateInBackground];
        
        NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
        NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
        NSString * loginName= [array objectAtIndex:0];
        STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:[so objectId]];
        STreamObject *my = [[STreamObject alloc]init];
        
        [my setObjectId:loginName];
        [my addStaff:@"status" withObject:@"sendRequest"];
        NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
        
        [updateArray addObject:my];
        [sco updateStreamCategoryObjects:updateArray];

    }completionBlock:^{
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
        [sender setTitle:@"add" forState:UIControlStateNormal];
//    [sender setImage:[UIImage imageNamed:@"add.png"]forState:UIControlStateNormal];
    [sender addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];

}
-(void)addFriends:(UIButton *)sender {
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"add friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        STreamObject * so = [userData objectAtIndex:sender.tag];
        [so setObjectId:[so objectId]];
        [so addStaff:@"status" withObject:@"friend"];
        [so updateInBackground];
        
        STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:[so objectId]];
        STreamObject *my = [[STreamObject alloc]init];
        NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
        NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
        NSString * loginName= [array objectAtIndex:0];
        [my setObjectId:loginName];
        [my addStaff:@"status" withObject:@"friend"];
        NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;
        
        [updateArray addObject:my];
        [sco updateStreamCategoryObjects:updateArray];
        
    }completionBlock:^{
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];

   
    [sender setTitle:@"friend" forState:UIControlStateNormal];
//    [sender setImage:[UIImage imageNamed:@"selectAdd.png"]forState:UIControlStateNormal];
    [sender addTarget:self action:@selector(deleteFriends:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setupSegmentedControl
{
    UIImage *backgroundImage = [[UIImage imageNamed:@"segmented-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    [_segmentedControl setBackgroundImage:backgroundImage];
    [_segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 2.0)];
    [_segmentedControl setSegmentedControlMode:SegmentedControlModeButton];
    [_segmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];

    [_segmentedControl setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
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
    [self.view addSubview:_segmentedControl];
}
#pragma mark -
#pragma mark SegmentedControlDelegate

- (void)segmentedViewController:(SegmentedControl *)segmentedControl touchedAtIndex:(NSUInteger)index
{
    if (_segmentedControl == segmentedControl)
       
    if (index ==1 ) {
        SearchFriendsViewController * search = [[SearchFriendsViewController alloc]init];
        [self.navigationController pushViewController:search animated:NO];
        UIButton * button =(UIButton *) [self.view viewWithTag:LEFT_BUTTON_TAG];
        [button setImage:[UIImage imageNamed:@"segmented-bg-left.png"] forState:UIControlStateNormal];
        UIButton * button2 =(UIButton *) [self.view viewWithTag:RIGHT_BUTTON_TAG];
        [button2 setImage:[UIImage imageNamed:@"segmented-pressed-Right.png"] forState:UIControlStateNormal];
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
            if (pImageId)
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
