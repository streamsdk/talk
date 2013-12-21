//
//  MainViewController.m
//  talk
//
//  Created by wangsh on 13-10-31.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "MainController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <arcstreamsdk/STreamSession.h>
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamUser.h>
#import "NSBubbleData.h"
#import "STreamXMPP.h"
#import "Voice.h"
#import "CreateUI.h"
#import "XMPPMessage.h"
#import "LoginViewController.h"
#import "TalkDB.h"
#import "MyFriendsViewController.h"
#import "BackData.h"
#import "MBProgressHUD.h"
#import "ImageCache.h"
#import "FileCache.h"
#import "UIImageViewController.h"
#import <arcstreamsdk/JSONKit.h>
#define TOOLBARTAG		200
#define TABLEVIEWTAG	300
#define BIG_IMG_WIDTH  300.0
#define BIG_IMG_HEIGHT 340.0

@interface MainController () <UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PlayerDelegate>
{
    NSMutableArray *bubbleData;
    CreateUI * createUI;
    
    UIScrollView *scrollView;//表情滚动视图
    
    BOOL keyboardIsShow;//键盘是否显示
    BOOL isFace;
    
    NSData *myData;
    NSData * otherData;
    BOOL isTakeImage;
    
    NSMutableDictionary *jsonDic;
}

@property(nonatomic,retain) Voice * voice;

@end

@implementation MainController

@synthesize bubbleTableView,toolBar,messageText,sendButton,iconButton ,recordButton,recordOrKeyboardButton,keyBoardButton;
@synthesize sendToID;
@synthesize voice;
@synthesize actionSheet;
@synthesize timeArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) back {
    MyFriendsViewController * myFriendsVC = [[MyFriendsViewController alloc]init];
    [self.navigationController pushViewController:myFriendsVC animated:YES];
}
-(void)initWithToolBar{
    
    //初始化为NO added
    keyboardIsShow=NO;
    isFace = NO;
    isTakeImage = NO;
    
    recordOrKeyboardButton = [createUI setButtonFrame:CGRectMake(0, 2, 30, 36) withTitle:(@"nil")];
    [recordOrKeyboardButton setImage:[UIImage imageNamed:@"Voice.png"] forState:UIControlStateNormal];
    [recordOrKeyboardButton addTarget:self action:@selector(KeyboardTorecordClicked) forControlEvents:UIControlEventTouchUpInside];
   
    iconButton = [createUI setButtonFrame:CGRectMake(30, 2, 30, 36) withTitle:@"nil"];
    [iconButton setImage:[UIImage imageNamed:@"addIcon.png"] forState:UIControlStateNormal];
    [iconButton addTarget:self action:@selector(photoClicked) forControlEvents:UIControlEventTouchUpInside];
    
    messageText = [createUI setTextFrame:CGRectMake(60, 3, toolBar.frame.size.width-120, 34)];
    messageText.delegate = self;
    
    sendButton = [createUI setButtonFrame:CGRectMake(toolBar.frame.size.width-50,4, 45, 32) withTitle:@"send"];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [sendButton addTarget:self action:@selector(sendMessageClicked) forControlEvents:UIControlEventTouchUpInside];
  
    [toolBar addSubview:recordOrKeyboardButton];
    [toolBar addSubview:iconButton];
    [toolBar addSubview:messageText];
    [toolBar addSubview:sendButton];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {

}
-(NSString *)getUserID{
    
    NSString * userID =nil;
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    if (array && [array count]!=0) {
        
       userID = [array objectAtIndex:0];
    }
    return userID;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    self.navigationItem.hidesBackButton = YES;
    
    BackData *data = [BackData sharedObject];
    UIImage *bgImage =[data getImage];
    if (bgImage) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    }else{
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    }
    ImageCache * imageCache =  [ImageCache sharedObject];
    sendToID = [imageCache getFriendID];
    NSString * userID = [self getUserID];

    self.title = [NSString stringWithFormat:@"chat to %@",sendToID];

    STreamXMPP *con = [STreamXMPP sharedObject];
    [con setXmppDelegate:self];
    
    bubbleData = [[NSMutableArray alloc]init];
    
    createUI = [[CreateUI alloc]init];
    
    self.voice = [[Voice alloc] init];
    
    TalkDB * talk =[[TalkDB alloc]init];
    bubbleData = [talk readInitDB:userID withOtherID:sendToID];
    for (NSBubbleData * data in bubbleData) {
        data.delegate = self;
    }
    
    UIBarButtonItem * leftitem = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftitem;

    UIImageView * backView = [[UIImageView alloc]initWithFrame:self.view.frame];
    backView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [backView addGestureRecognizer:singleTouch];
    [backView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backView];
    //bubbleTableView
    bubbleTableView = [[UIBubbleTableView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44-40)];
    bubbleTableView .bubbleDataSource = self;
    bubbleTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [backView addSubview:bubbleTableView];
    
    toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.view.frame.size.width, 40)];
    toolBar.tag = TOOLBARTAG;
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [backView addSubview:toolBar];
    
    [self initWithToolBar];
    
    bubbleTableView.tag = TABLEVIEWTAG;
    bubbleTableView.snapInterval = 120;
    bubbleTableView.showAvatars = YES;

    [bubbleTableView reloadData];
   
    [self scrollBubbleViewToBottomAnimated:YES];
//给键盘注册通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    timeArray = [[NSMutableArray alloc]initWithObjects:@"1s",@"2s",@"3s",@"4s",@"5s",@"6s",@"7s",@"8s",@"9s",@"10s", nil];
    
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:userID];
    NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
    myData = [imageCache getImage:pImageId];
    
    NSMutableDictionary *metaData = [imageCache getUserMetadata:sendToID];
    NSString *pImageId2 = [metaData objectForKey:@"profileImageId"];
    otherData = [imageCache getImage:pImageId2];
    
    jsonDic = [[NSMutableDictionary alloc]init];
    
    // save time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate * time = [NSDate dateWithTimeIntervalSinceNow:0];
    [imageCache messageTime:time];
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    ImageCache *imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:[self getUserID]];
    NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
    myData = [imageCache getImage:pImageId];
    
    NSMutableDictionary *metaData = [imageCache getUserMetadata:sendToID];
    NSString *pImageId2 = [metaData objectForKey:@"profileImageId"];
    otherData = [imageCache getImage:pImageId2];
    return [bubbleData objectAtIndex:row];
}

- (void)didAuthenticate{
    
    NSLog(@"");
}
- (void)didReceiveFile:(NSString *)fileId withBody:(NSString *)body withFrom:(NSString *)fromID{
    ImageCache *imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:[self getUserID]];
    NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
    myData = [imageCache getImage:pImageId];
    
    NSMutableDictionary *metaData = [imageCache getUserMetadata:sendToID];
    NSString *pImageId2 = [metaData objectForKey:@"profileImageId"];
    otherData = [imageCache getImage:pImageId2];

    STreamFile *sf = [[STreamFile alloc] init];
    NSData *data = [sf downloadAsData:fileId];
    
    if ([fromID isEqualToString:sendToID]) {
        if ([body isEqualToString:@"photo"]) {
            UIImage * image = [UIImage imageWithData:data];
            NSBubbleData * bubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
            if (otherData)
                bubble.avatar = [UIImage imageWithData:otherData];
            bubble.delegate = self;
            [bubbleData addObject:bubble];

            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
            NSString *photoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.png", [formater stringFromDate:[NSDate date]]];
            [data writeToFile:photoPath atomically:YES];
            NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
            [friendDict setObject:photoPath forKey:@"photo"];
            [jsonDic setObject:friendDict forKey:sendToID];
           
        }else if ([body isEqualToString:@"video"]){
            
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
           NSString *mp4Path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
            [data writeToFile : mp4Path atomically: YES ];
            NSURL *url = [NSURL fileURLWithPath:mp4Path];
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url];
            player.shouldAutoplay = NO;
            UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
            NSBubbleData *bdata = [NSBubbleData dataWithImage:fileImage withData:data withType:@"video" date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse withVidePath:mp4Path];
            bdata.delegate = self;
            if (otherData)
                bdata.avatar = [UIImage imageWithData:otherData];
            [bubbleData addObject:bdata];
            NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
            [friendDict setObject:mp4Path forKey:@"video"];
            [jsonDic setObject:friendDict forKey:sendToID];
            
        }else{
            NSBubbleData *bubble = [NSBubbleData dataWithtimes:[body stringByAppendingString:@"\""] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse withData:data];
            bubble.delegate = self;
            if (otherData)
                bubble.avatar = [UIImage imageWithData:otherData];
            [bubbleData addObject:bubble];
            
            NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
            [dateformat setDateFormat:@"yyyyMMddHHmmss"];
            NSString * recordFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.aac",[dateformat stringFromDate:[NSDate date]]]];
            [data writeToFile:recordFilePath atomically:YES];
            NSMutableDictionary * friendsDict = [NSMutableDictionary dictionary];
            [friendsDict setObject:[body stringByAppendingString:@"\""] forKey:@"time"];
            [friendsDict setObject:recordFilePath forKey:@"audiodata"];
            [jsonDic setObject:friendsDict forKey:sendToID];

        }
        [bubbleTableView reloadData];
        [self scrollBubbleViewToBottomAnimated:YES];
    }
    
    TalkDB * db = [[TalkDB alloc]init];
    NSString * userID = [self getUserID];
    NSString  *str = [jsonDic JSONString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [db insertDBUserID:userID fromID:sendToID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:1];

}

- (void)didReceiveMessage:(XMPPMessage *)message withFrom:(NSString *)fromID{

    
    NSString *receiveMessage = [message body];
    if ([fromID isEqualToString:sendToID]) {
        NSBubbleData *sendBubble = [NSBubbleData dataWithText:receiveMessage date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        if (otherData)
            sendBubble.avatar = [UIImage imageWithData:otherData];
        [bubbleData addObject:sendBubble];
    }
    TalkDB * db = [[TalkDB alloc]init];
    NSString * userID = [self getUserID];
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:receiveMessage forKey:@"messages"];
    [jsonDic setObject:friendDict forKey:sendToID];
    NSString  *str = [jsonDic JSONString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [db insertDBUserID:userID fromID:sendToID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:1];
    [bubbleTableView reloadData];
    [self scrollBubbleViewToBottomAnimated:YES];
    
}
- (void)didReceiveRosterItems:(NSMutableArray *)rosterItem{
    NSLog(@"");
}
- (void)didNotAuthenticate:(DDXMLElement *)error{
    
    NSLog(@"");
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

#pragma mark - Actions
#pragma mark send photo

-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(void) sendPhoto :(UIImage *)image {
    if (sendToID) {
        NSData * data = UIImageJPEGRepresentation(image, 0.7);
        UIImage * _image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width*0.7, image.size.height*0.7)];
        NSBubbleData * bubbledata = [NSBubbleData dataWithImage:_image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        if (myData) {
            bubbledata.avatar = [UIImage imageWithData:myData];
        }
        [bubbleData addObject:bubbledata];
        
        bubbledata.delegate = self;
        [bubbleTableView reloadData];
        
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *photoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.png", [formater stringFromDate:[NSDate date]]];
        [data writeToFile:photoPath atomically:YES];
        NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
        [friendDict setObject:photoPath forKey:@"photo"];
        [jsonDic setObject:friendDict forKey:sendToID];
        NSString  *str = [jsonDic JSONString];
        
        TalkDB * db = [[TalkDB alloc]init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [db insertDBUserID:[self getUserID] fromID:sendToID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];

        STreamXMPP *con = [STreamXMPP sharedObject];
        [con sendFileInBackground:data toUser:sendToID finished:^(NSString *res){
            NSLog(@"res:%@",res);
        }byteSent:^(float b){
            NSLog(@"byteSent:%f",b);
        }withBodyData:@"photo"];
    }
    [self dismissKeyBoard];
    [self scrollBubbleViewToBottomAnimated:YES];
}
-(void) sendVideo :(UIImage *)image withData:(NSData *)videoData {
    
    NSBubbleData * bubbledata = [NSBubbleData dataWithImage:image withData:videoData withType:@"video" date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine withVidePath:_mp4Path];
    bubbledata .delegate = self;
    if (myData)
        bubbledata.avatar = [UIImage imageWithData:myData];
    [bubbleData addObject:bubbledata];
    
    NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
    [friendDict setObject:_mp4Path forKey:@"video"];
    [jsonDic setObject:friendDict forKey:sendToID];
    NSString  *str = [jsonDic JSONString];
    
    TalkDB * db = [[TalkDB alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [db insertDBUserID:[self getUserID] fromID:sendToID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];

    
    [bubbleTableView reloadData];
    STreamXMPP *con = [STreamXMPP sharedObject];
    [con sendFileInBackground:videoData toUser:sendToID finished:^(NSString *res){
        NSLog(@"res:%@",res);
    }byteSent:^(float b){
        NSLog(@"byteSent:%f",b);
    }withBodyData:@"video"];
    
    [self dismissKeyBoard];
    [self scrollBubbleViewToBottomAnimated:YES];
}
#pragma mark send  message
-(void) sendMessageClicked {
    
    if (sendToID) {
        
        NSString * messages = messageText.text;
        if ([messages length]!=0) {
            bubbleTableView.typingBubble = NSBubbleTypingTypeNobody;
            NSBubbleData *sendBubble = [NSBubbleData dataWithText:messages date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            if (myData)
                sendBubble.avatar = [UIImage imageWithData:myData];
            [bubbleData addObject:sendBubble];
            [bubbleTableView reloadData];
            
            
            STreamXMPP *con = [STreamXMPP sharedObject];
            [con sendMessage:sendToID withMessage:messages];
            NSMutableDictionary *friendDict = [NSMutableDictionary dictionary];
            [friendDict setObject:messages forKey:@"messages"];
            [jsonDic setObject:friendDict forKey:sendToID];
            NSString  *str = [jsonDic JSONString];
            
            TalkDB * db = [[TalkDB alloc]init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [db insertDBUserID:[self getUserID] fromID:sendToID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
            messageText.text = @"";
            [self dismissKeyBoard];
            [messageText resignFirstResponder];
            [self scrollBubbleViewToBottomAnimated:YES];
        }else {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"please input chat Contents" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"you are waiting..." delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

#pragma mark send audio
-(void) sendRecordAudio {
    
    NSURL* url = [NSURL fileURLWithPath:self.voice.recordPath];
    NSError * err = nil;
    NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if (self.voice.recordTime >= 0.5f) {
        NSString * bodyData = [NSString stringWithFormat:@"%d",(int)self.voice.recordTime];
        
        NSBubbleData *bubble = [NSBubbleData dataWithtimes:bodyData date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine withData:audioData];
        if (myData)
            bubble.avatar = [UIImage imageWithData:myData];
        [bubbleData addObject:bubble];
     
        NSMutableDictionary * friendsDict = [NSMutableDictionary dictionary];
        [friendsDict setObject:bodyData forKey:@"time"];
        [friendsDict setObject:[url path] forKey:@"audiodata"];
        [jsonDic setObject:friendsDict forKey:sendToID];
        NSString * str = [jsonDic JSONString];
        NSLog(@"json===:%@",str);
        TalkDB * db = [[TalkDB alloc]init];
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
         [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
         [db insertDBUserID:[self getUserID] fromID:sendToID withContent:str withTime:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]] withIsMine:0];
        
        STreamXMPP *con = [STreamXMPP sharedObject];

            [con sendFileInBackground:audioData toUser:sendToID finished:^(NSString *res) {
            
            NSLog(@"%@", res);
            
        }byteSent:^(float b){
            
            NSLog(@"%@", [NSString stringWithFormat:@"%1.6f", b]);
            
        }withBodyData:bodyData];
        [bubbleTableView reloadData];
        [self scrollBubbleViewToBottomAnimated:YES];
        
    }else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Send Failed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"", nil];
        [alert show];
    }
}

-(void) recordStart
{
    [self.voice startRecordWithPath];
}
-(void) recordEnd
{
    [self.voice stopRecordWithCompletionBlock:^{
        
        if (self.voice.recordTime >= 0.5f) {
            
            [self sendRecordAudio];
        }
    }];
}
-(void) recordCancel
{
    [self.voice cancelled];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"取消了" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}


//recordToKeyboardClicked
-(void) recordToKeyboardClicked {
    [keyBoardButton removeFromSuperview];
    [recordButton removeFromSuperview];
    [self initWithToolBar];
}
// KeyboardTorecordClicked
-(void) KeyboardTorecordClicked {
    
    [self dismissKeyBoard];
    [scrollView removeFromSuperview];
    [recordOrKeyboardButton removeFromSuperview];
    [messageText removeFromSuperview];
    [sendButton removeFromSuperview];
    [iconButton removeFromSuperview];
    CGRect frame = CGRectMake(0, 2, 30, 36);
     keyBoardButton = [createUI setButtonFrame:frame withTitle:@"nil"];
    [keyBoardButton setImage:[UIImage imageNamed:@"Text.png"] forState:UIControlStateNormal];
    [keyBoardButton addTarget:self action:@selector(recordToKeyboardClicked) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *title =@"按住说话";
    CGRect frame2 = CGRectMake(40, 2, toolBar.frame.size.width-60, 36);
    recordButton = [createUI setButtonFrame:frame2 withTitle:title];
    [recordButton addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(recordCancel) forControlEvents:UIControlEventTouchUpOutside];
    
    [toolBar addSubview:keyBoardButton];
    [toolBar addSubview:recordButton];
}

#pragma MARK Icon button 表情事件
-(void) disIconKeyboard {
    [self scrollBubbleViewToBottomAnimated:YES];
    //如果直接点击，通过toolbar的位置来判断
    if (toolBar.frame.origin.y== self.view.bounds.size.height - toolBarHeight&&toolBar.frame.size.height==toolBarHeight) {
        [UIView animateWithDuration:Time animations:^{
            toolBar.frame = CGRectMake(0, self.view.frame.size.height-ICONHEIGHT-toolBarHeight,  self.view.bounds.size.width,toolBarHeight);
            UIBubbleTableView *tableView = (UIBubbleTableView *)[self.view viewWithTag:TABLEVIEWTAG];
            tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width,(float)(self.view.frame.size.height-ICONHEIGHT-40.0));
            
        }];
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height-ICONHEIGHT,self.view.frame.size.width, ICONHEIGHT)];
        }];
         return;
    }
    //如果键盘没有显示，点击表情了，隐藏表情，显示键盘
    if (isFace) {
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, TABLEVIEWTAG)];
        }];
        [messageText becomeFirstResponder];
        
    }else{
        
        //键盘显示的时候，toolbar需要还原到正常位置，并显示表情
        [UIView animateWithDuration:Time animations:^{
            toolBar.frame = CGRectMake(0, self.view.frame.size.height-ICONHEIGHT-toolBar.frame.size.height,  self.view.bounds.size.width,toolBar.frame.size.height);
            UIBubbleTableView *tableView = (UIBubbleTableView *)[self.view viewWithTag:TABLEVIEWTAG];
            tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width,(float)(self.view.frame.size.height-ICONHEIGHT-40.0));
            
        }];
        
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height-ICONHEIGHT  ,self.view.frame.size.width, ICONHEIGHT)];
        }];
        [messageText resignFirstResponder];
    }

}
#pragma MARK face button 表情事件
-(void)disFaceKeyboard{
    [self scrollBubbleViewToBottomAnimated:YES];
    //如果直接点击表情，通过toolbar的位置来判断
    if (toolBar.frame.origin.y== self.view.bounds.size.height - toolBarHeight&&toolBar.frame.size.height==toolBarHeight) {
        [UIView animateWithDuration:Time animations:^{
            toolBar.frame = CGRectMake(0, self.view.frame.size.height-keyboardHeight-toolBarHeight,  self.view.bounds.size.width,toolBarHeight);
            UIBubbleTableView *tableView = (UIBubbleTableView *)[self.view viewWithTag:TABLEVIEWTAG];
            tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width,(float)(self.view.frame.size.height-keyboardHeight-40.0));
            
        }];
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height-keyboardHeight,self.view.frame.size.width, keyboardHeight)];
        }];
        return;
    }
    //如果键盘没有显示，点击表情了，隐藏表情，显示键盘
    if (keyboardIsShow) {
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, keyboardHeight)];
        }];
        [messageText becomeFirstResponder];
        
    }else{
        
        //键盘显示的时候，toolbar需要还原到正常位置，并显示表情
        [UIView animateWithDuration:Time animations:^{
            toolBar.frame = CGRectMake(0, self.view.frame.size.height-keyboardHeight-toolBar.frame.size.height,  self.view.bounds.size.width,toolBar.frame.size.height);
            UIBubbleTableView *tableView = (UIBubbleTableView *)[self.view viewWithTag:TABLEVIEWTAG];
            tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width,(float)(self.view.frame.size.height-keyboardHeight-40.0));
            
        }];
        
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height-keyboardHeight,self.view.frame.size.width, keyboardHeight)];
        }];
        [messageText resignFirstResponder];
    }
}
#pragma mark 隐藏键盘

-(void)dismissKeyBoard{
    //键盘显示的时候，toolbar需要还原到正常位置，并显示表情
    [UIView animateWithDuration:Time animations:^{
        toolBar.frame = CGRectMake(0, self.view.frame.size.height-toolBar.frame.size.height,  self.view.bounds.size.width,toolBar.frame.size.height);
        bubbleTableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64-toolBarHeight);
    }];
    if (isFace) {
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width, keyboardHeight)];
        }];
    }else{
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width, ICONHEIGHT)];
        }];
    }
    
    [messageText resignFirstResponder];
    
}


#pragma mark 监听键盘的显示与隐藏

-(void) autoMovekeyBoard: (float) h{
    
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
    toolbar.frame = CGRectMake(0.0f, (float)(self.view.frame.size.height-h-40.0), self.view.frame.size.width, 40.0f);
    UIBubbleTableView *tableView = (UIBubbleTableView *)[self.view viewWithTag:TABLEVIEWTAG];
    tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width,(float)(self.view.frame.size.height-h-40.0));
    [self scrollBubbleViewToBottomAnimated:YES];
}
-(void)inputKeyboardWillShow:(NSNotification *)notification{
    //键盘显示，设置toolbar的frame跟随键盘的frame
   CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSValue *animationDurationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
    
        NSLog(@"键盘即将出现：%@", NSStringFromCGRect(keyBoardFrame));
        if (toolBar.frame.size.height>40) {
            toolBar.frame = CGRectMake(0, keyBoardFrame.origin.y-20-toolBar.frame.size.height,  self.view.bounds.size.width,toolBar.frame.size.height);
        }else{
            keyBoardFrame.size.height = keyBoardFrame.size.height< keyBoardFrame.size.width ?keyBoardFrame.size.height:keyBoardFrame.size.width;
            [self autoMovekeyBoard:keyBoardFrame.size.height];
        }
    }];
    
    keyboardIsShow=YES;
    
}
-(void)inputKeyboardWillHide:(NSNotification *)notification{
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    keyboardIsShow=NO;
}

#pragma mark -
#pragma mark facialView delegate 点击表情键盘上的文字
-(void)selectedFacialView:(NSString*)str
{
    
    NSString *newStr;
    if ([str isEqualToString:@"删除"]) {
        if (messageText.text.length>0) {
            if ([[Emoji allEmoji] containsObject:[messageText.text substringFromIndex:messageText.text.length-2]]) {
                newStr=[messageText.text substringToIndex:messageText.text.length-2];
            }else{
                NSLog(@"删除文字%@",[messageText.text substringFromIndex:messageText.text.length-1]);
                newStr=[messageText.text substringToIndex:messageText.text.length-1];
            }
            messageText.text=newStr;
        }
    }else{
        NSString *newStr=[NSString stringWithFormat:@"%@%@",messageText.text,str];
        [messageText setText:newStr];
    }
}
#pragma mark PhotoButton clicked
-(void) photoClicked {
    isFace = NO;
    [scrollView removeFromSuperview];

    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, ICONHEIGHT)];
    [scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"facesBack.png"]]];
    for (int i=0; i<5; i++) {
        IconView *fview=[[IconView alloc] initWithFrame:CGRectMake(12+320*i, 15, facialViewWidth, facialViewHeight)];
        [fview setBackgroundColor:[UIColor clearColor]];
        [fview loadIconView:i size:CGSizeMake(40, 40)];
        fview.delegate=self;
        [scrollView addSubview:fview];
    }
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    scrollView.contentSize=CGSizeMake(320, ICONHEIGHT);
    scrollView.pagingEnabled=YES;
    scrollView.delegate=self;
    [self.view addSubview:scrollView];
    [self disIconKeyboard];
}
#pragma mark Face button 
-(void) faceClicked {
    [scrollView removeFromSuperview];
    //创建表情键盘
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, keyboardHeight)];
    [scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"facesBack"]]];
    for (int i=0; i<9; i++) {
        FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(12+320*i, 15, facialViewWidth, facialViewHeight)];
        [fview setBackgroundColor:[UIColor clearColor]];
        [fview loadFacialView:i size:CGSizeMake(33, 43)];
        fview.delegate=self;
        [scrollView addSubview:fview];
    }

    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    scrollView.contentSize=CGSizeMake(320*9, keyboardHeight);
    scrollView.pagingEnabled=YES;
    scrollView.delegate=self;
    [self.view addSubview:scrollView];
    isFace = YES;
    [self disFaceKeyboard];
}

//* UIPickerView
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [timeArray count];
    
}
-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [timeArray objectAtIndex:row];
}
-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}


-(void)segmentAction:(UISegmentedControl*)seg{
    NSInteger index = seg.selectedSegmentIndex;
    NSLog(@"%d",index);
    [self.actionSheet dismissWithClickedButtonIndex:index animated:YES];
}

#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        UIPickerView * pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 60)] ;
        pickerView.tag = 101;
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.showsSelectionIndicator = YES;
        
        [self.actionSheet addSubview:pickerView];
        
        UISegmentedControl* button = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Done",nil]];
        button.tintColor = [UIColor grayColor];
        [button setSegmentedControlStyle:UISegmentedControlStyleBar];
        [button setFrame:CGRectMake(250, 10, 50,30 )];
        [button addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        [self.actionSheet addSubview:button];
        [self.actionSheet showInView:self.view];
        [self.actionSheet setBounds:CGRectMake(0, 0, 320,300)];
        [self.actionSheet setBackgroundColor:[UIColor whiteColor]];
        
    }
}
#pragma mark - Tool Methods
- (void)addPhoto
{
    isTakeImage = NO;
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = NO;
    imagePickerController.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
	[self presentViewController:imagePickerController animated:YES completion:NULL];
}
- (void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"该设备不支持拍照功能"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"好", nil];
        [alert show];
    }else{
        isTakeImage = YES;
        UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        [self presentViewController:imagePickerController animated:YES completion:NULL];
    }
}
-(void) takeVideo {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"该设备不支持摄像功能"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"好", nil];
        [alert show];
    }else {
        UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        [self presentViewController:pickerView animated:YES completion:NULL];
        pickerView.videoMaximumDuration = 15;
        pickerView.delegate = self;
    }
   
}
#pragma mark 
- (void)encodeToMp4
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoPath options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSString*  _mp4Quality = AVAssetExportPresetHighestQuality;
    if ([compatiblePresets containsObject:_mp4Quality])
        
    {
        UIAlertView *_alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"Waiting.."];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.frame = CGRectMake(140,
                                    80,
                                    CGRectGetWidth(_alert.frame),
                                    CGRectGetHeight(_alert.frame));
        [_alert addSubview:activity];
        [activity startAnimating];
        _startDate = [NSDate date];
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:_mp4Quality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        _mp4Path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
     
        
        exportSession.outputURL = [NSURL fileURLWithPath: _mp4Path];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    [_alert dismissWithClickedButtonIndex:0 animated:NO];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[[exportSession error] localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    [_alert dismissWithClickedButtonIndex:0
                                                 animated:YES];
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Successful!");
                    [self performSelectorOnMainThread:@selector(convertFinish) withObject:nil waitUntilDone:NO];
                    break;
                default:
                    break;
            }
        }];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"AVAsset doesn't support mp4 quality"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}
#pragma mark - private Method

- (NSInteger) getFileSize:(NSString*) path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue]/1024;
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

- (CGFloat) getVideoDuration:(NSURL*) URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (void) convertFinish
{
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoPath];
    player.shouldAutoplay = NO;
    NSData *videoData = [NSData dataWithContentsOfFile:_mp4Path];
    UIImage *fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    [self sendVideo:fileImage withData:videoData];
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
       
        UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (isTakeImage) {
            UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"You Sure Send File?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            view.delegate = self;
            [view show];
            
        }else{
            [self sendPhoto:image];
        }
//        [self sendPhoto:image];
    }else{
        videoPath = [info objectForKey:UIImagePickerControllerMediaURL];
        [self encodeToMp4];
        
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark textFiledDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self dismissKeyBoard];
    return  YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self scrollBubbleViewToBottomAnimated:YES];
}

-(void) dismissKeyboard:(UITapGestureRecognizer *)estureRecognizer {
    [self dismissKeyBoard];
}

#pragma mark show bubbleview  lastrow
- (void) scrollBubbleViewToBottomAnimated:(BOOL)animated
{
    NSInteger lastSectionIdx = [bubbleTableView numberOfSections] - 1;
    
    if (lastSectionIdx >= 0)
    {
    	[bubbleTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([bubbleTableView numberOfRowsInSection:lastSectionIdx] - 1) inSection:lastSectionIdx] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


#pragma mark player delegate 
-(void) playerVideo:(NSString *)path {
    NSURL * url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController* pView = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentViewController:pView animated:YES completion:NULL];
}

//bibImage

-(void) bigImage:(UIImage *)image {
    
    UIImageViewController * iView = [[UIImageViewController alloc]init];
    iView.image = image;
    iView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:iView animated:YES completion:nil];
//    [self.navigationController pushViewController:iView animated:YES];
}

-(void)  selectedIconView:(NSInteger) buttonTag{
    
    if(buttonTag == 0){
        [self faceClicked];
    }
    if(buttonTag == 1){
        [self addPhoto];
        [self scrollBubbleViewToBottomAnimated:YES];
    }
    if (buttonTag == 2) {
        [self takePhoto];
        [self scrollBubbleViewToBottomAnimated:YES];
    }
    if (buttonTag == 3) {
        [self takeVideo];
        [self scrollBubbleViewToBottomAnimated:YES];
    }
        
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
