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
#import "AddDB.h"
#import "HandlerUserIdAndDateFormater.h"
#import "STreamXMPP.h"
#import <arcstreamsdk/JSONKit.h>
#define TABLECELL_TAG 10000

@interface MyFriendsViewController ()
{
    NSMutableDictionary *countDict;
    MainController *mainVC;
    NSMutableArray * countArray;
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

   //    [self loadFriends];
    
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
    _reloading= NO;
    if (_refreshTableView == nil) {
        
        EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        refreshView.delegate = self;
        [self.tableView addSubview:refreshView];
        _refreshTableView = refreshView;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    label.text =[handle getUserID];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"Arial" size:22.0f];
    self.tableView.tableHeaderView =label;
    
    userData = [[NSMutableArray alloc]init];
    countDict= [[NSMutableDictionary alloc]init];
    userData = [[NSMutableArray alloc]init];
    sortedArrForArrays = [[NSMutableArray alloc] init];
    sectionHeadsKeys = [[NSMutableArray alloc] init];
    
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
    
    AddDB * addDB = [[AddDB alloc]init];
    NSMutableDictionary * dict = [addDB readDB:[handle getUserID]];
    NSArray * array = [dict allKeys];
    for (int i = 0;i< [array count];i++) {
        NSString *status = [dict objectForKey:[array objectAtIndex:i]];
        if ([status isEqualToString:@"friend"]) {
            [userData addObject:[array objectAtIndex:i]];
        }
    }
    sortedArrForArrays = [self getChineseStringArr:userData];
    [self.tableView reloadData];
}

-(void) loadFriends {
    
    ImageCache * imageCache = [ImageCache sharedObject];
    countArray = [imageCache getMessagesCount];
    sectionHeadsKeys=[[NSMutableArray alloc]init];
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName= [handle getUserID];
    
    STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq setQueryLogicAnd:true];
    [sq whereEqualsTo:@"status" forValue:@"friend"];
    AddDB * addDB = [[AddDB alloc]init];
    NSMutableArray * friends = [sq find];
    for (STreamObject *so in friends) {
        if (![userData containsObject:[so objectId]]){
            [userData addObject:[so objectId]];
            [addDB insertDB:[handle getUserID] withFriendID:[so objectId] withStatus:@"sendRequest"];
        }
    }
    
    sortedArrForArrays = [self getChineseStringArr:userData];
   /* STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq setQueryLogicAnd:true];
    [sq whereEqualsTo:@"status" forValue:@"friend"];
    [sq find:^(NSMutableArray *friends){
        for (STreamObject *so in friends) {
            if (![userData containsObject:[so objectId]])
                [userData addObject:[so objectId]];
            }
        sortedArrForArrays = [self getChineseStringArr:userData];
        [self.tableView reloadData];
    }];*/
    [self.tableView reloadData];
}
-(void) connect {
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    [self setMessagesProtocol:mainVC];
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con setXmppDelegate:self];
    if (![con connected])
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
    ImageCache *imageCache = [ImageCache sharedObject];
    [imageCache setMessagesCount:fromID];
    NSString *receiveMessage = [message body];
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];

    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    TalkDB * db = [[TalkDB alloc]init];
    NSString * userID = [handler getUserID];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:receiveMessage forKey:@"messages"];
    [jsonDic setObject:friendDict forKey:fromID];
    NSString  *str = [jsonDic JSONString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date =[NSDate dateWithTimeIntervalSinceNow:0];
    NSString * str2 = [dateFormatter stringFromDate:date];
    [db insertDBUserID:userID fromID:fromID withContent:str withTime:str2 withIsMine:1];
    
    [messagesProtocol getMessages:receiveMessage withFromID:fromID];
    [self.tableView reloadData];
}

- (void)didReceiveFile:(NSString *)fileId withBody:(NSString *)body withFrom:(NSString *)fromID{
    ImageCache *imageCache = [ImageCache sharedObject];
    [imageCache setMessagesCount:fromID];
    STreamFile *sf = [[STreamFile alloc] init];
    NSData *data = [sf downloadAsData:fileId];
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
   
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    if ([body isEqualToString:@"photo"]) {
        NSString *photoPath = [[handler getPath] stringByAppendingString:@".png"];
        [data writeToFile:photoPath atomically:YES];
        NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
        [friendDict setObject:photoPath forKey:@"photo"];
        [jsonDic setObject:friendDict forKey:fromID];
    }else if ([body isEqualToString:@"video"]){
         NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
        
        HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
        NSString * mp4Path = [[handler getPath] stringByAppendingString:@".mp4"];
        
        [data writeToFile : mp4Path atomically: YES ];
        [handler videoPath:mp4Path];
        [friendDict setObject:mp4Path forKey:@"video"];
        [jsonDic setObject:friendDict forKey:fromID];
    }else{
        NSMutableDictionary * friendsDict = [NSMutableDictionary dictionary];
        
        HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
        
        NSString * recordFilePath = [[handler getPath] stringByAppendingString:@".aac"];
        [data writeToFile:recordFilePath atomically:YES];
        
        [friendsDict setObject:[body stringByAppendingString:@"\""] forKey:@"time"];
        [friendsDict setObject:recordFilePath forKey:@"audiodata"];
        [jsonDic setObject:friendsDict forKey:fromID];
       
    }
    
    
    TalkDB * db = [[TalkDB alloc]init];
    NSString * userID = [handler getUserID];
    NSString  *str = [jsonDic JSONString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [db insertDBUserID:userID fromID:fromID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:1];
    
    [messagesProtocol getFiles:data withFromID:fromID withBody:body];
     [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"11：%d",[sortedArrForArrays count]);
    return  [[sortedArrForArrays objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"22：%d",[sortedArrForArrays count]);
    return [sortedArrForArrays count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionHeadsKeys objectAtIndex:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSString *cellId = @"CellId";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = TABLECELL_TAG;
    }
    if ([self.sortedArrForArrays count] > indexPath.section) {
        NSArray *arr = [sortedArrForArrays objectAtIndex:indexPath.section];
        if ([arr count] > indexPath.row) {
            ChineseString *str = (ChineseString *) [arr objectAtIndex:indexPath.row];

            [cell.imageView setFrame:CGRectMake(0, 10, 50, 40)];
            [cell.imageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
            [self loadAvatar:str.string withCell:cell];
            cell.textLabel.text = str.string;
            NSMutableArray * array = [[NSMutableArray alloc]init];
            if (countArray && [countArray count]!= 0) {
                for (NSString * id in countArray) {
                    if ([id isEqualToString:str.string]) {
                        [array addObject:id];
                    }
                }
            }
            int num = [array count];
            if (num!= 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",num];
                cell.detailTextLabel.textColor = [UIColor redColor];
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
    NSMutableArray *chineseStringsArray = [[NSMutableArray alloc]init];
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
    
    
    NSMutableArray *arrayForArrays = [[NSMutableArray alloc]init];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *TempArrForGrouping = [[NSMutableArray alloc]init];
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
  
     ImageCache *imageCache = [ImageCache sharedObject];
    
    NSMutableArray * keys = [sortedArrForArrays objectAtIndex:indexPath.section];
    ChineseString * userStr = [keys objectAtIndex:indexPath.row];
    NSString *userName = [userStr string];
    [imageCache setFriendID:userName];
    
    [countArray removeObject:userName];
    
    [self.tableView reloadData];
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
    }else{
        STreamUser *user = [[STreamUser alloc] init];
        [user loadUserMetadata:userID response:^(BOOL succeed, NSString *error){
            if ([error isEqualToString:userID]){
                NSMutableDictionary *dic = [user userMetadata];
                ImageCache *imageCache = [ImageCache sharedObject];
                [imageCache saveUserMetadata:userID withMetadata:dic];
            }
        }];

    }
}
-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)reloadTableViewDataSource{
    _reloading = YES;
    [self loadFriends];
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
}

- (void)doneLoadingTableViewData{
    NSLog(@"doneLoadingTableViewData");
    
    _reloading = NO;
    [_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Background operation
-(void)doInBackground
{
    NSLog(@"doInBackground");
    
    [NSThread sleepForTimeInterval:3];
    
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshTableView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];
}

@end
