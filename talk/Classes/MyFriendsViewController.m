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
#import "TalkDB.h"
#import "HandlerUserIdAndDateFormater.h"
#import "STreamXMPP.h"

#define LABEL_TAG 10000

@interface MyFriendsViewController ()
{
    NSMutableDictionary *countDict;
    MainController *mainVC;
}
@end

@implementation MyFriendsViewController

@synthesize userData,sortedArrForArrays,sectionHeadsKeys,messagesProtocol;

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
-(void)viewWillAppear:(BOOL)animated{

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"MyFriends";
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
   [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(settingClicked)];
    self.navigationItem.leftBarButtonItem = leftItem;

    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriends)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    label.text =[handle getUserID];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"Arial" size:22.0f];
    self.tableView.tableHeaderView =label;
    
    mainVC = [[MainController alloc]init];

    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"connecting ...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self connect];
    }completionBlock:^{
        [self.tableView reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
    
 
}

-(void) loadFriends {
    
    countDict= [[NSMutableDictionary alloc]init];
    
    userData = [[NSMutableArray alloc]init];
    sortedArrForArrays = [[NSMutableArray alloc] init];
    sectionHeadsKeys = [[NSMutableArray alloc] init];
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
    for (NSString * str in userData) {
        NSDate * time = [NSDate dateWithTimeIntervalSinceNow:0];
        HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
        TalkDB * db = [[TalkDB alloc]init];
        NSArray * array = [db readInitDB:[handle getUserID] withOtherID:str withTime:time];
        NSString *num=[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:[array count]]];
        [countDict setObject:num forKey:str];
        [self.tableView reloadData];
        
    }
}
-(void) connect {
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    [self setMessagesProtocol:mainVC];
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con setXmppDelegate:self];
    [con connect:[handle getUserID] withPassword:[handle getUserIDPassword]];
}

#pragma mark - STreamXMPPProtocol
- (void)didAuthenticate{
    NSLog(@"");
}

- (void)didNotAuthenticate:(NSXMLElement *)error{
    NSLog(@" ");
}

- (void)didReceivePresence:(XMPPPresence *)presence{
    NSString *presenceType = [presence type];
    if ([presenceType isEqualToString:@"subscribe"]){
        
    }
    if ([presenceType isEqualToString:@"available"]){
    }
    if ([presenceType isEqualToString:@"unavailable"]){
        
    }

}
- (void)didReceiveMessage:(XMPPMessage *)message withFrom:(NSString *)fromID{
    NSString *receiveMessage = [message body];
    [messagesProtocol getMessages:receiveMessage withFromID:fromID];
}

- (void)didReceiveFile:(NSString *)fileId withBody:(NSString *)body withFrom:(NSString *)fromID{
    STreamFile *sf = [[STreamFile alloc] init];
    NSData *data = [sf downloadAsData:fileId];
    [messagesProtocol getFiles:data withFromID:fromID withBody:body];
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
            NSString * num = [countDict objectForKey:str.string];
            if (![num isEqualToString:@"0"]) {
                UILabel * label= [[UILabel alloc]initWithFrame:CGRectMake(260, 0, 40, cell.frame.size.height)];
                label.textColor = [UIColor redColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor clearColor];
                label.tag = LABEL_TAG;
                label.font = [UIFont fontWithName:@"Arial" size:22.0f];
                label.text = num;
                [cell addSubview:label];
            }
            
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
    UILabel * label = (UILabel *)[self.view viewWithTag:LABEL_TAG];
    label.text = @" ";
     ImageCache *imageCache = [ImageCache sharedObject];
    // save time
   
    NSDate * time = [NSDate dateWithTimeIntervalSinceNow:0];
    [imageCache messageTime:time];
    
    NSMutableArray * keys = [sortedArrForArrays objectAtIndex:indexPath.section];
    ChineseString * userStr = [keys objectAtIndex:indexPath.row];
    NSString *userName = [userStr string];

    [imageCache setFriendID:userName];
    
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
