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
#import "pinyin.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamFile.h>
#import "ImageCache.h"
#import "ChineseString.h"
#import "SettingViewController.h"
#import "FileCache.h"
#import "ImageCache.h"

@interface MyFriendsViewController ()

@end

@implementation MyFriendsViewController

@synthesize userData,sortedArrForArrays,sectionHeadsKeys;

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
-(void) settingClicked {
    SettingViewController *setVC = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:setVC animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"MyFriends";
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
   [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    userData = [[NSMutableArray alloc]init];
    sortedArrForArrays = [[NSMutableArray alloc] init];
    sectionHeadsKeys = [[NSMutableArray alloc] init];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(settingClicked)];
    self.navigationItem.leftBarButtonItem = leftItem;

    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriends)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    label.text =loginName;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"Arial" size:22.0f];
    self.tableView.tableHeaderView =label;
    
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
    NSMutableArray * friends = [sq find];
    for (STreamObject *so in friends) {
        [userData addObject:[so objectId]];
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:[so objectId] response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:[so objectId]]){
                NSMutableDictionary *dic = [user userMetadata];
                ImageCache *imageCache = [ImageCache sharedObject];
                [imageCache saveUserMetadata:[so objectId] withMetadata:dic];
            }
        }];
    }
    sortedArrForArrays = [self getChineseStringArr:userData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [[sortedArrForArrays objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sortedArrForArrays count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionHeadsKeys objectAtIndex:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"CellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([self.sortedArrForArrays count] > indexPath.section) {
        NSArray *arr = [sortedArrForArrays objectAtIndex:indexPath.section];
        if ([arr count] > indexPath.row) {
            ChineseString *str = (ChineseString *) [arr objectAtIndex:indexPath.row];
           
            [cell.imageView setFrame:CGRectMake(0, 5, 50, 50)];
            [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
             [self loadAvatar:str.string withCell:cell];
            cell.textLabel.text = str.string;
            
            cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];

        } else {
            NSLog(@"arr out of range");
        }
    } else {
        NSLog(@"sortedArrForArrays out of range");
    }
    
    return cell;
}
- (NSMutableArray *)getChineseStringArr:(NSMutableArray *)arrToSort {
    NSMutableArray *chineseStringsArray = [NSMutableArray array];
    for(int i = 0; i < [arrToSort count]; i++) {
        ChineseString *chineseString=[[ChineseString alloc]init];
        chineseString.string=[NSString stringWithString:[arrToSort objectAtIndex:i]];
        
        if(chineseString.string==nil){
            chineseString.string=@"";
        }
        
        if(![chineseString.string isEqualToString:@""]){
            //join the pinYin
            NSString *pinYinResult = [NSString string];
            for(int j = 0;j < chineseString.string.length; j++) {
                NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
                                                 pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
                
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            chineseString.pinYin = pinYinResult;
        } else {
            chineseString.pinYin = @"";
        }
        [chineseStringsArray addObject:chineseString];
    }
    
    //sort the ChineseStringArr by pinYin
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *TempArrForGrouping = nil;
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        ChineseString *chineseStr = (ChineseString *)[chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString:chineseStr.pinYin];
        NSString *sr= [strchar substringToIndex:1];
        NSLog(@"%@",sr);        //sr containing here the first character of each string
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]])//here I'm checking whether the character already in the selection header keys or not
        {
            [sectionHeadsKeys addObject:[sr uppercaseString]];
            TempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
            checkValueAtIndex = NO;
        }
        if([sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                [arrayForArrays addObject:TempArrForGrouping];
                checkValueAtIndex = YES;
            }
        }
    }
    return arrayForArrays;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray * keys = [sortedArrForArrays objectAtIndex:indexPath.section];
    ChineseString * userStr = [keys objectAtIndex:indexPath.row];
    NSString *userName = [userStr string];

    ImageCache *imageCache = [ImageCache sharedObject];
    [imageCache setFriendID:userName];
    MainController *mainVC = [[MainController alloc]init];
    [self.navigationController pushViewController:mainVC animated:YES];
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
-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
@end
