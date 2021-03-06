// //
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
#import "DownloadDB.h"
#import "UploadDB.h"
#import "DownloadAvatar.h"
#import "AddDB.h"
#import "ReadStatus.h"

#define TABLECELL_TAG 10000
#define BUTTON_TAG 20000
#define BUTTON_IMAGE_TAG 30000
@interface MyFriendsViewController ()
{
    NSMutableDictionary *countDict;
    MainController *mainVC;
    BOOL firstRead;
}
@end

@implementation MyFriendsViewController

@synthesize userData,sortedArrForArrays,sectionHeadsKeys,messagesProtocol,toolBar;
@synthesize button;
@synthesize uploadProtocol;
@synthesize statusDict,loadonlineProtocol;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) addFriends {
    toolBar.hidden = YES;
    HandlerFirendsViewController * handlerVC = [[HandlerFirendsViewController alloc]init];
    //    [self.navigationController pushViewController:handlerVC animated:YES];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:handlerVC animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
}
-(void) settingClicked {
    SettingViewController *setVC = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:setVC animated:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    ImageCache *imageCache = [ImageCache sharedObject];
    [imageCache setFriendID:nil];
    userData = [[NSMutableArray alloc]init];
    sectionHeadsKeys=[[NSMutableArray alloc]init];
    [self readAddDb];
    sortedArrForArrays = [self getChineseStringArr:userData];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    //   [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings2.png"] style:UIBarButtonItemStyleDone target:self action:@selector(settingClicked)];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriends)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self performSelectorInBackground:@selector(loadFriends) withObject:nil];
    
    
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    _reloading= NO;
    firstRead = YES;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    //background
    //    UIView *backgrdView = [[UIView alloc] initWithFrame:self.tableView.frame];
    //    backgrdView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    //    self.tableView.backgroundView = backgrdView;
    
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
    label.text =[NSString stringWithFormat:@"%@ (me)", [handle getUserID]];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"Arial" size:22.0f];
    self.tableView.tableHeaderView =label;
    
    statusDict = [[NSMutableDictionary alloc]init];
    userData = [[NSMutableArray alloc]init];
    countDict= [[NSMutableDictionary alloc]init];
    userData = [[NSMutableArray alloc]init];
    sortedArrForArrays = [[NSMutableArray alloc] init];
    sectionHeadsKeys = [[NSMutableArray alloc] init];
    mainVC = [[MainController alloc]init];
    [self performSelectorInBackground:@selector(connect) withObject:nil];
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasBackInForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    UIButton  * requestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [requestButton setFrame:CGRectMake(10, 5, 200, 30)];
    [requestButton setTitle:@"You have new friend requests!" forState:UIControlStateNormal];
    requestButton.backgroundColor = [UIColor clearColor];
    [requestButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    requestButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [requestButton addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchUpInside];
    toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,40)];
    toolBar.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:requestButton];
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(self.view.frame.size.width-60, 10,20, 20)];
    [cancelButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(requestCancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *fiexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    NSArray *array =[[NSArray alloc]initWithObjects:item,fiexibleSpace,cancelItem,nil];
    toolBar.items =array;
    toolBar.hidden = YES;
    [self.view addSubview:toolBar];
    
}

-(void)requestCancel {
    toolBar.hidden = YES;
}
- (void)appHasBackInForeground{
    [self performSelectorInBackground:@selector(connect) withObject:nil];
}
-(void) readAddDb {
    userData = [[NSMutableArray alloc]init];
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    AddDB * addDB = [[AddDB alloc]init];
    NSMutableDictionary * addDict = [addDB readDB:[handle getUserID]];
    //NSLog(@"%d",[dict count]);
    NSArray * array = [addDict allKeys];
    for (int i = 0;i< [array count];i++) {
        NSString *status = [addDict objectForKey:[array objectAtIndex:i]];
        if ([status isEqualToString:@"friend"]) {
            [userData addObject:[array objectAtIndex:i]];
        }
    }
    
}
-(void) loadFriends {
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName= [handle getUserID];
    STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    [sq setQueryLogicAnd:FALSE];
    [sq whereEqualsTo:@"status" forValue:@"friend"];
    [sq whereEqualsTo:@"status" forValue:@"request"];
    NSMutableArray * friends = [sq find];
    AddDB * addDB = [[AddDB alloc]init];
    NSMutableDictionary * addDict = [addDB readDB:[handle getUserID]];
    NSArray *allkey = [addDict allKeys];
    for (STreamObject *so in friends) {
        if ([allkey containsObject:[[so objectId]lowercaseString]]) {
            [addDB updateDB:[handle getUserID] withFriendID:[[so objectId] lowercaseString] withStatus:[so getValue:@"status"]];
        }else{
            [addDB insertDB:[handle getUserID] withFriendID:[[so objectId] lowercaseString] withStatus:[so getValue:@"status"]];
        }
    }
    [self readAddDb];
    sectionHeadsKeys=[[NSMutableArray alloc]init];
    sortedArrForArrays = [self getChineseStringArr:userData];
}
-(void) connect {
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    if (![handle getUserID]) return;
    [self setMessagesProtocol:mainVC];
    [self setUploadProtocol:mainVC];
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con setXmppDelegate:self];
    if (![con connected]){
        self.title = @"connecting...";
        [con connect:[handle getUserID] withPassword:[handle getUserIDPassword]];
    }
    
}

- (void)startDownload{
    DownloadDB * downloadDB = [[DownloadDB alloc]init];
    NSMutableArray * downloadArray = [downloadDB readDownloadDB];
    if (downloadArray!=nil && [downloadArray count]!=0) {
        for (NSMutableArray* array in downloadArray) {
            NSString * fileId = [array objectAtIndex:0];
            NSString * body = [array objectAtIndex:1];
            NSString * fromId = [array objectAtIndex:2];
            
            NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
            JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
            NSMutableDictionary *json = [decoder objectWithData:jsonData];
            NSString *type = [json objectForKey:@"type"];
            if (![type isEqualToString:@"video"]) {
                [downloadDB deleteDownloadDBFromFileID:fileId];
                [self didReceiveFile:fileId withBody:body withFrom:fromId];
            }
            
        }
    }
}

- (void)startUpload{
    
    UploadDB * uploadDB = [[UploadDB alloc]init];
    NSMutableArray * uploadArray = [uploadDB readUploadDB];
    if (uploadArray != nil && [uploadArray count] != 0) {
        for (NSMutableArray* array in uploadArray) {
            NSString * filePath = [array objectAtIndex:0];
            NSString * time= [array objectAtIndex:1];
            NSString * fromId = [array objectAtIndex:2];
            NSString * type = [array objectAtIndex:3];
            NSString * date = [array objectAtIndex:4];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSDate * _date = [dateFormatter dateFromString:date];
            [uploadProtocol uploadVideoPath:filePath withTime:time withFrom:fromId withType:type withDate:_date];
        }
    }
}

- (void)readHistory{
    
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
            NSString *receivedMessage = [json objectForKey:@"message"];
            [self didReceiveMessage:receivedMessage withFrom:from];
        }
        if ([type isEqualToString:@"video"] || [type isEqualToString:@"photo"] || [type isEqualToString:@"voice"] || [type isEqualToString:@"map"]){
            NSString *fileId = [json objectForKey:@"fileId"];
            [self didReceiveFile:fileId withBody:jsonValue withFrom:from];
        }
        if ([type isEqualToString:@"request"] || [type isEqualToString:@"friend"]) {
            [self didReceiveRequest:json];
        }
        if ([type isEqualToString:@"sendRequest"]) {
            NSString * friendname = [json objectForKey:@"friendname"];
            NSString * username = [json objectForKey:@"username"];
            AddDB * addDb = [[AddDB alloc]init];
            NSMutableDictionary * dict = [addDb readDB:friendname];
            if (dict!=nil && [dict count]!= 0) {
                NSArray *key = [dict allKeys];
                if ([key containsObject:username]) {
                    [addDb deleteDB:username];
                }
            }
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

#pragma mark - STreamXMPPProtocol
- (void)didAuthenticate{
    NSLog(@"");
    self.title = @"reading...";
    [self startDownload];
    [self readHistory];
    [self startUpload];
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    STreamObject * so = [[STreamObject alloc]init];
    NSMutableString *userid = [[NSMutableString alloc] init];
    [userid appendString:[handle getUserID]];
    [userid appendString:@"status"];
    [so setObjectId:userid];
    [so addStaff:@"online" withObject:@"YES"];
    [so updateInBackground];
    ReadStatus * readStatus = [[ReadStatus alloc]init];
    [readStatus loadAllMetaData];
}

- (void)didNotAuthenticate:(NSXMLElement *)error{
    self.title = @"failed...";
    NSLog(@" ");
}

- (void)didReceivePresence:(XMPPPresence *)presence{
    self.title = @"MyFriends";
    NSString *presenceType = [presence type];
    if ([presenceType isEqualToString:@"subscribe"]){
        
    }
    if ([presenceType isEqualToString:@"available"]){
    }
    if ([presenceType isEqualToString:@"unavailable"]){
        
    }
    [NSThread sleepForTimeInterval:0.1];
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}
-(void) didReceiveRequest:(NSDictionary *)json{
    NSString *type = [json objectForKey:@"type"];
    if ([type isEqualToString:@"request"] || [type isEqualToString:@"friend"]) {
        
        if ([type isEqualToString:@"request"]) {
            toolBar.hidden = NO;
        }
        NSString * friendname = [json objectForKey:@"friendname"];
        NSString * username = [json objectForKey:@"username"];
        AddDB * addDb = [[AddDB alloc]init];
        NSMutableDictionary * dict = [addDb readDB:friendname];
        if (dict!=nil && [dict count]!= 0) {
            NSArray *key = [dict allKeys];
            if ([key containsObject:username]) {
                [addDb updateDB:friendname withFriendID:username withStatus:type];
            }else{
                [addDb insertDB:friendname withFriendID:username withStatus:type];
            }
        }
        
    }
    
    
}
- (void)didReceiveMessage:(NSString *)message withFrom:(NSString *)fromID{
    ImageCache *imageCache = [ImageCache sharedObject];
    NSString *friendId = [imageCache getFriendID];
    if (![friendId isEqualToString:fromID]) {
        [imageCache setMessagesCount:fromID];
    }
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    NSString * userID = [handler getUserID];
    [friendDict setObject:message forKey:@"messages"];
    [jsonDic setObject:friendDict forKey:fromID];
    NSString  *str = [jsonDic JSONString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate * date =[NSDate dateWithTimeIntervalSinceNow:0];
    NSString * str2 = [dateFormatter stringFromDate:date];
    [handler setDate:date];
    TalkDB * db = [[TalkDB alloc]init];
    [db insertDBUserID:userID fromID:fromID withContent:str withTime:str2 withIsMine:1];
    
    [messagesProtocol getMessages:message withFromID:fromID];
    [self.tableView reloadData];
}

- (void)didReceiveFile:(NSString *)fileId withBody:(NSString *)body withFrom:(NSString *)fromID{
    ImageCache *imageCache = [ImageCache sharedObject];
    HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
    
    NSString *friendId = [imageCache getFriendID];
    if (![friendId isEqualToString:fromID]) {
        [imageCache setMessagesCount:fromID];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate * date = [handler getDate];
    [handler setDate:date];
    DownloadDB * downloadDB = [[DownloadDB alloc]init];
    [downloadDB insertDownloadDB:[handler getUserID] fileID:fileId withBody:body withFrom:fromID withTime:[dateFormatter stringFromDate:date]];
    
    STreamFile *sf = [[STreamFile alloc] init];
    NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSMutableDictionary *json = [decoder objectWithData:jsonData];
    NSString *type = [json objectForKey:@"type"];
    
    if ([type isEqualToString:@"video"]) {
        
        
        NSString *tid= [json objectForKey:@"tid"];
        if (tid){
            fileId = tid;
            [downloadDB insertDownloadDB:[handler getUserID] fileID:fileId withBody:body withFrom:fromID withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]];
        }else {
            [imageCache saveJsonData:body forFileId:fileId];
            NSString *jsonBody = [imageCache getJsonData:fileId];
            NSData *jsonData = [jsonBody dataUsingEncoding:NSUTF8StringEncoding];
            JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
            NSMutableDictionary *json = [decoder objectWithData:jsonData];
            NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
            NSString *type = [json objectForKey:@"type"];
            NSString *fromUser = [json objectForKey:@"from"];
            NSString * fileId = [json objectForKey:@"fileId"];
            NSString * timeId = [json objectForKey:@"id"];
            NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
            NSString *duration = [json objectForKey:@"duration"];
            NSString * tidpath= [[handler getPath] stringByAppendingString:@".png"];
            NSData *data ;
            [data writeToFile:tidpath atomically:YES];
            [handler videoPath:tidpath];
            
            if (duration)
                [friendDict setObject:duration forKey:@"duration"];
            [friendDict setObject:tidpath forKey:@"tidpath"];
            [friendDict setObject:fileId forKey:@"fileId"];
            [friendDict setObject:fromUser forKey:@"fromId"];
            [friendDict setObject:timeId forKey:@"id"];
            [jsonDic setObject:friendDict forKey:fromUser];
            
            NSMutableDictionary * jsondict = [[NSMutableDictionary alloc]init];
            [jsondict setObject:type forKey:@"type"];
            [jsondict setObject:tidpath forKey:@"tidpath"];
            if (duration)
                [jsondict setObject:duration forKey:@"duration"];
            [jsondict setObject:fileId forKey:@"fileId"];
            [jsondict setObject:fromUser forKey:@"fromId"];
            [jsondict setObject:timeId forKey:@"id"];
            NSString* jsBody = [jsondict JSONString];
            
            TalkDB * db = [[TalkDB alloc]init];
            NSString * userID = [handler getUserID];
            NSString  *str = [jsonDic JSONString];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
           // NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeId longLongValue]/1000.0];
            //            NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
            [handler setDate:date];
            [db insertDBUserID:userID fromID:fromUser withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:1];
            [messagesProtocol getFiles:data withFromID:fromUser withBody:jsBody withPath:tidpath withDate:date];
            [self.tableView reloadData];
            return;
        }
    }
    [imageCache saveJsonData:body forFileId:fileId];
    
    
    [sf downloadAsData:fileId downloadedData:^(NSData *data, NSString *objectId){
        
        
        NSString *jsonBody = [imageCache getJsonData:objectId];
        [downloadDB deleteDownloadDBFromFileID:objectId];
        NSData *jsonData = [jsonBody dataUsingEncoding:NSUTF8StringEncoding];
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        NSMutableDictionary *json = [decoder objectWithData:jsonData];
        NSString *type = [json objectForKey:@"type"];
        NSString *fromUser = [json objectForKey:@"from"];
       // NSString * timeId  =[json objectForKey:@"id"];
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
        HandlerUserIdAndDateFormater *handler =[HandlerUserIdAndDateFormater sharedObject];
        NSString * path;
        NSString * jsBody;
        if ([type isEqualToString:@"photo"]) {
            NSString *duration = [json objectForKey:@"duration"];
            NSString *photoPath = [[handler getPath] stringByAppendingString:@".png"];
            NSString * fileId = [json objectForKey:@"fileId"];
            [data writeToFile:photoPath atomically:YES];
            NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
            if (duration) {
                [friendDict setObject:duration forKey:@"time"];
            }
            [friendDict setObject:fileId forKey:@"fileId"];
            [friendDict setObject:photoPath forKey:@"photo"];
            [jsonDic setObject:friendDict forKey:fromUser];
            path = photoPath;
            jsBody = jsonBody;
        }else if ([type isEqualToString:@"video"]){
            NSString * timeId = [json objectForKey:@"id"];
            NSString * tid = [json objectForKey:@"tid"];
            NSString * fileId = [json objectForKey:@"fileId"];
            NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
            NSString *duration = [json objectForKey:@"duration"];
            NSString * tidpath= [[handler getPath] stringByAppendingString:@".png"];
            [data writeToFile:tidpath atomically:YES];
            [handler videoPath:tidpath];
            
            if (duration)
                [friendDict setObject:duration forKey:@"duration"];
            [friendDict setObject:tidpath forKey:@"tidpath"];
            [friendDict setObject:tid forKey:@"tid"];
            [friendDict setObject:fileId forKey:@"fileId"];
            [friendDict setObject:fromUser forKey:@"fromId"];
            [friendDict setObject:timeId forKey:@"id"];
            [jsonDic setObject:friendDict forKey:fromUser];
            path = tidpath;
            
            
            NSMutableDictionary * jsondict = [[NSMutableDictionary alloc]init];
            [jsondict setObject:type forKey:@"type"];
            [jsondict setObject:tidpath forKey:@"tidpath"];
            if (duration)
                [jsondict setObject:duration forKey:@"duration"];
            [jsondict setObject:tid forKey:@"tid"];
            [jsondict setObject:fileId forKey:@"fileId"];
            [jsondict setObject:fromUser forKey:@"fromId"];
            [jsondict setObject:timeId forKey:@"id"];
            jsBody = [jsondict JSONString];
        }else if ([type isEqualToString:@"voice"]){
            NSString * fileId = [json objectForKey:@"fileId"];
            NSString *duration = [json objectForKey:@"duration"];
            NSMutableDictionary * friendsDict = [NSMutableDictionary dictionary];
            NSString * recordFilePath = [[handler getPath] stringByAppendingString:@".aac"];
            [data writeToFile:recordFilePath atomically:YES];
            path = recordFilePath;
            [friendsDict setObject:duration forKey:@"time"];
            [friendsDict setObject:fileId forKey:@"fileId"];
            [friendsDict setObject:recordFilePath forKey:@"audiodata"];
            [jsonDic setObject:friendsDict forKey:fromUser];
            jsBody = body;
        }if ([type isEqualToString:@"map"]) {
            NSString *address = [json objectForKey:@"address"];
            NSString *mappath = [[handler getPath] stringByAppendingString:@".png"];
            NSString * fileId = [json objectForKey:@"fileId"];
            NSString *latitude = [json objectForKey:@"latitude"];
            NSString *longitude = [json objectForKey:@"longitude"];
            [data writeToFile:mappath atomically:YES];
            NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [friendDict setObject:address forKey:@"address"];
            [friendDict setObject:fileId forKey:@"fileId"];
            [friendDict setObject:mappath forKey:@"path"];
            [friendDict setObject:latitude forKey:@"latitude"];
            [friendDict setObject:longitude forKey:@"longitude"];
            [dict setObject:friendDict forKey:@"address"];
            [jsonDic setObject:dict forKey:fromUser];
            path = mappath;
            jsBody = jsonBody;
        }
        
        TalkDB * db = [[TalkDB alloc]init];
        NSString * userID = [handler getUserID];
        NSString  *str = [jsonDic JSONString];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
       // NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeId longLongValue]/1000.0];
        //        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        //        NSInteger interval = [zone secondsFromGMTForDate:date];
        //        date = [date dateByAddingTimeInterval:interval];
        //        NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
        [handler setDate:date];
        [db insertDBUserID:userID fromID:fromUser withContent:str withTime:[dateFormatter stringFromDate:date] withIsMine:1];
        [messagesProtocol getFiles:data withFromID:fromUser withBody:jsBody withPath:path withDate:date];
        [self.tableView reloadData];
        
    }];
    
    
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
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return  nil;
    }
    
    UILabel * label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 320, 24);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font=[UIFont fontWithName:@"Arial" size:19.0f];
    label.text = sectionTitle;
    
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 24)] ;
    [sectionView setBackgroundColor:[UIColor blackColor]];
    [sectionView addSubview:label];
    return sectionView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId = @"CellId";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        //        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = TABLECELL_TAG;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = BUTTON_TAG;
        [button setFrame:CGRectMake(50, 0, 28, 28)];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0f];
        [cell addSubview:button];
        
    }
    if ([self.sortedArrForArrays count] > indexPath.section) {
        NSArray *arr = [sortedArrForArrays objectAtIndex:indexPath.section];
        if ([arr count] > indexPath.row) {
            ChineseString *str = (ChineseString *) [arr objectAtIndex:indexPath.row];
            CALayer *l = [cell.imageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:8.0];
            cell.textLabel.text = str.string;
            DownloadAvatar * down = [[DownloadAvatar alloc]init];
            UIImage * icon = [down loadAvatar:str.string];
            [self setImage:icon withCell:cell];
            ImageCache * imageCache = [ImageCache sharedObject];
            NSInteger count = [imageCache getMessagesCount:str.string];
            
            if (count!= 0) {
                NSString * title =[NSString stringWithFormat:@"%d",count];
                [button setBackgroundImage:[UIImage imageNamed:@"message_count.png"] forState:UIControlStateNormal];
                [button setTitle:title forState:UIControlStateNormal];
            }
            ReadStatus * status = [[ReadStatus alloc]init];
            cell.detailTextLabel.text = [status readStatus:str.string];
            
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
    [imageCache saveRaedCount:[NSNumber numberWithInt:0] withuserID:userName];
    [imageCache saveTablecontentOffset:0 withUser:userName];
    STreamObject * so = [[STreamObject alloc]init];
    NSMutableString *userid = [[NSMutableString alloc] init];
    [userid appendString:userName];
    [userid appendString:@"status"];
    [self setLoadonlineProtocol:mainVC];
    [so getObject:userid response:^(NSString * res) {
        NSString * online = [so getValue:@"online"];
        if ([online isEqualToString:@"YES"]) {
            [imageCache saveOnline:@"online" withuserId:userName];
        }else{
            NSString * time = [so getValue:@"lastseen"];
            if (!time){
                time = [imageCache getOnline:userName];
                if (time) return ;
                int value = (arc4random() % (24*60)) + 1;
                long lastseen=[[NSDate dateWithTimeIntervalSinceNow:-(value*60)] timeIntervalSince1970];
                time =[NSString stringWithFormat:@"%ld",lastseen];
            }
            //            long long lastModifiedTime = [time longLongValue];
            NSDate *now = [NSDate date];
            long long millionsSecs = [now timeIntervalSince1970];
            NSString *diff = [NSString stringWithFormat:@"%lld",millionsSecs];
            //            long long diff = millionsSecs - lastModifiedTime;
            //            NSString * timeDiff = [self getTimeDiff:diff withLastseen:time];
            NSString * timeDiff =[self getTime:diff withLastseen:time];
            [imageCache saveOnline:timeDiff withuserId:userName];
        }
        [loadonlineProtocol loadOnline];
    }];
    [self.tableView reloadData];
    self.title = @"MyFriends";
    [self.navigationController pushViewController:mainVC animated:YES];
    
    
}
- (NSString *)getTime:(NSString *)diff withLastseen:(NSString *)lastseen{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:[diff longLongValue]];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:now];
    now = [now dateByAddingTimeInterval: interval];
    NSDate *last = [NSDate dateWithTimeIntervalSince1970:[lastseen longLongValue]];
    NSDate * yester = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
    long long float1 = [[formatter stringFromDate:now] longLongValue];
    long long float2 = [[formatter stringFromDate:last] longLongValue];
    long long float3 = [[formatter stringFromDate:yester] longLongValue];
    long long f= float1 - float2;
    NSString *lastseenTime;
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    if (f<=0) {
        [formatter1 setDateFormat:@"HH:mm"];
        lastseenTime=[NSString stringWithFormat:@"last seen today at %@", [formatter1 stringFromDate:last]];
    }else  if (f<=1|| float2==float3) {
        [formatter1 setDateFormat:@"HH:mm"];
        lastseenTime=[NSString stringWithFormat:@"last seen yesterday at %@", [formatter1 stringFromDate:last]];
    }else{
        [formatter1 setDateFormat:@"dd/MM/yyyy"];
        lastseenTime=[NSString stringWithFormat:@"last seen at %@", [formatter1 stringFromDate:last]];
    }
    return lastseenTime;
    
}
- (NSString *)getTimeDiff:(long long)diff withLastseen:(NSString *)lastseen{
    
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:[lastseen longLongValue]];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"HH:mm"];
    NSString *lastseenTime;
    int days;
    int seconds = (int)(diff);
    days = seconds / 3600 / 24;
    if (days <= 0){
        lastseenTime=[NSString stringWithFormat:@"last seen today at %@", [formatter1 stringFromDate:d]];
    }else  if (days<=1) {
        lastseenTime=[NSString stringWithFormat:@"last seen yesterday at %@", [formatter1 stringFromDate:d]];
    }else{
        [formatter1 setDateFormat:@"dd/MM/yyyy"];
        lastseenTime=[NSString stringWithFormat:@"last seen at %@", [formatter1 stringFromDate:d]];
    }
    return lastseenTime;
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
    //	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
    _reloading = NO;
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
