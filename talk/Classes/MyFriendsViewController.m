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
#import "pinyin.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/JSONKit.h>
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
#import <QuartzCore/QuartzCore.h>
#import "HandlerFirendsViewController.h"


#define TABLECELL_TAG 10000
#define BUTTON_TAG 20000
#define BUTTON_IMAGE_TAG 30000
@interface MyFriendsViewController ()
{
    NSMutableDictionary *countDict;
    MainController *mainVC;
}
@end

@implementation MyFriendsViewController

@synthesize userData,sortedArrForArrays,sectionHeadsKeys,messagesProtocol;
@synthesize button;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) addFriends {
    HandlerFirendsViewController * handlerVC = [[HandlerFirendsViewController alloc]init];
    [self.navigationController pushViewController:handlerVC animated:YES];
}
-(void) settingClicked {
    SettingViewController *setVC = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:setVC animated:NO];
}
-(void)viewWillAppear:(BOOL)animated{

    ImageCache *imageCache = [ImageCache sharedObject];
    [imageCache setFriendID:nil];
    [self.tableView reloadData];
    
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
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    //background
    UIView *backgrdView = [[UIView alloc] initWithFrame:self.tableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.tableView.backgroundView = backgrdView;
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"7.0" options: NSNumericSearch];

    if (order == NSOrderedSame || order == NSOrderedDescending)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
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
    
    [self readAddDb];
    sortedArrForArrays = [self getChineseStringArr:userData];
    
    [_refreshHeaderView refreshLastUpdatedDate];

    [self.tableView reloadData];
}
-(void) readAddDb {
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];

    AddDB * addDB = [[AddDB alloc]init];
    NSMutableDictionary * dict = [addDB readDB:[handle getUserID]];
    NSArray * array = [dict allKeys];
    for (int i = 0;i< [array count];i++) {
        NSString *status = [dict objectForKey:[array objectAtIndex:i]];
        if ([status isEqualToString:@"friend"]) {
            [userData addObject:[array objectAtIndex:i]];
        }
    }

}
-(void) loadFriends {

    sectionHeadsKeys=[[NSMutableArray alloc]init];
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName= [handle getUserID];
    
    AddDB * addDB = [[AddDB alloc]init];
    userData = [[NSMutableArray alloc]init];
    [self readAddDb];
    
    STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq setQueryLogicAnd:true];
    [sq whereEqualsTo:@"status" forValue:@"friend"];
    
    NSMutableArray * friends = [sq find];
    for (STreamObject *so in friends) {
        if (![userData containsObject:[so objectId]]){
            [userData addObject:[so objectId]];
            [addDB insertDB:[handle getUserID] withFriendID:[so objectId] withStatus:@"friend"];
        }
    }
    
    sortedArrForArrays = [self getChineseStringArr:userData];

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
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    STreamObject *so = [[STreamObject alloc] init];
    NSMutableString *history = [[NSMutableString alloc] init];
    [history appendString:[handle getUserID]];
    [history appendString:@"messaginghistory"];
    [so loadAll:history];
    NSArray *keys = [so getAllKeys];
    NSMutableString *removedKeys = [[NSMutableString alloc] init];
    int index = 0;
    for (NSString *key in keys){
        NSString *value = [so getValue:key];
        NSString *jsonValue = [value substringFromIndex:13];
        NSData *jsonData = [jsonValue dataUsingEncoding:NSUTF8StringEncoding];
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        NSDictionary *json = [decoder objectWithData:jsonData];
        NSString *type = [json objectForKey:@"type"];
        NSString *from = [json objectForKey:@"from"];
        if ([type isEqualToString:@"text"]){
            [self didReceiveMessage:jsonValue withFrom:from];
        }else{
            NSString *fileId = [json objectForKey:@"fileId"];
            [self didReceiveFile:fileId withBody:jsonValue withFrom:from];
        }
        
        [removedKeys appendString:key];
        if (index != [keys count] - 1){
            [removedKeys appendString:@"&&"];
        }
        
        index++;
    }
    
    if ([keys count] > 0){
        STreamObject *sob = [[STreamObject alloc] init];
        [sob removeKeyInBackground:removedKeys forObjectId:history];
    }
    
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
- (void)didReceiveMessage:(NSString *)message withFrom:(NSString *)fromID{
    ImageCache *imageCache = [ImageCache sharedObject];
    NSString *friendId = [imageCache getFriendID];
    if (![friendId isEqualToString:fromID]) {
        [imageCache setMessagesCount:fromID];
    }
    
    //parse new message format
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *json = [decoder objectWithData:jsonData];
    NSString *receiveMessage = [json objectForKey:@"message"];
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];

    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    NSString * userID = [handler getUserID];
    [friendDict setObject:receiveMessage forKey:@"messages"];
    [jsonDic setObject:friendDict forKey:fromID];
    NSString  *str = [jsonDic JSONString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date =[NSDate dateWithTimeIntervalSinceNow:0];
    NSString * str2 = [dateFormatter stringFromDate:date];
    
     TalkDB * db = [[TalkDB alloc]init];
    [db insertDBUserID:userID fromID:fromID withContent:str withTime:str2 withIsMine:1];
    
    [messagesProtocol getMessages:receiveMessage withFromID:fromID];
    [self.tableView reloadData];
}

- (void)didReceiveFile:(NSString *)fileId withBody:(NSString *)body withFrom:(NSString *)fromID{
    ImageCache *imageCache = [ImageCache sharedObject];
    NSString *friendId = [imageCache getFriendID];
    if (![friendId isEqualToString:fromID]) {
        [imageCache setMessagesCount:fromID];
    }
    //parse new message format
    NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *json = [decoder objectWithData:jsonData];
    NSString *type = [json objectForKey:@"type"];
    
    STreamFile *sf = [[STreamFile alloc] init];
    NSData *data = [sf downloadAsData:fileId];
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
   
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    if ([type isEqualToString:@"photo"]) {
        NSString *photoPath = [[handler getPath] stringByAppendingString:@".png"];
        [data writeToFile:photoPath atomically:YES];
        NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
        [friendDict setObject:photoPath forKey:@"photo"];
        [jsonDic setObject:friendDict forKey:fromID];
    }else if ([type isEqualToString:@"video"]){
         NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
        
        HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
        NSString * mp4Path = [[handler getPath] stringByAppendingString:@".mp4"];
        
        [data writeToFile : mp4Path atomically: YES ];
        [handler videoPath:mp4Path];
        [friendDict setObject:mp4Path forKey:@"video"];
        [jsonDic setObject:friendDict forKey:fromID];
    }else if ([type isEqualToString:@"voice"]){
        
        NSString *duration = [json objectForKey:@"duration"];
        NSMutableDictionary * friendsDict = [NSMutableDictionary dictionary];
        HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
        NSString * recordFilePath = [[handler getPath] stringByAppendingString:@".aac"];
        [data writeToFile:recordFilePath atomically:YES];
        
        [friendsDict setObject:duration forKey:@"time"];
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = TABLECELL_TAG;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = BUTTON_TAG;
        [button setFrame:CGRectMake(50, 0, 28, 28)];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:10.0f];
        [cell addSubview:button];
        
    }
    
    if ([self.sortedArrForArrays count] > indexPath.section) {
        NSArray *arr = [sortedArrForArrays objectAtIndex:indexPath.section];
        if ([arr count] > indexPath.row) {
            ChineseString *str = (ChineseString *) [arr objectAtIndex:indexPath.row];
            UIImage * icon=[UIImage imageNamed:@"headImage.jpg"];
            cell.imageView.image = icon;
            [self loadAvatar:str.string withCell:cell];
            CALayer *l = [cell.imageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:8.0];
            cell.textLabel.text = str.string;
//            NSMutableArray * array = [[NSMutableArray alloc]init];
//            if (countArray && [countArray count]!= 0) {
//                for (NSString * id in countArray) {
//                    if ([id isEqualToString:str.string]) {
//                        [array addObject:id];
//                    }
//                }
//            }
            ImageCache * imageCache = [ImageCache sharedObject];
            NSInteger count = [imageCache getMessagesCount:str.string];
//            int num = [array count];
            if (count!= 0) {
                NSString * title =[NSString stringWithFormat:@"%d",count];
                [button setBackgroundImage:[UIImage imageNamed:@"message_count.png"] forState:UIControlStateNormal];
                [button setTitle:title forState:UIControlStateNormal];
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
//        NSLog(@"%@",sr);        //sr containing here the first character of each string
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
    [imageCache removeFriendID:userName];
    
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
            if ([pImageId isEqualToString:@""]){
                UIImage *icon =[UIImage imageNamed:@"headImage.jpg"];
                [self setImage:icon withCell:cell];
            }
            else{
                UIImage *icon =[UIImage imageWithData:[imageCache getImage:pImageId]];
                [self setImage:icon withCell:cell];
            }
            
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

-(void)setImage:(UIImage *)icon withCell:(UITableViewCell *)cell{
    CGSize itemSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark egoRefreshScrollViewDidScroll delegate

- (void)reloadTableViewDataSource{
    _reloading = YES;
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
}

- (void)doneLoadingTableViewData{
    NSLog(@"doneLoadingTableViewData");
    
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    //刷新表格内容
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Background operation
-(void)doInBackground
{
    NSLog(@"doInBackground");
    
    [self loadFriends];
    [NSThread sleepForTimeInterval:3];
    
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
    _reloading = NO;
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
