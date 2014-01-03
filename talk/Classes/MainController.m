//
//  MainViewController.m
//  talk
//
//  Created by wangsh on 13-10-31.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "MainController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <arcstreamsdk/STreamSession.h>
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamQuery.h>
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
#import "PlayerDelegate.h"
#import <arcstreamsdk/JSONKit.h>
#import "PhotoHandler.h"
#import "VideoHandler.h"
#import "MessageHandler.h"
#import "AudioHandler.h"
#import "HandlerUserIdAndDateFormater.h"
#import "ImageViewController.h"

#define BUTTON_TAG 20000
#define TOOLBARTAG		200
#define TABLEVIEWTAG	300
#define BIG_IMG_WIDTH  300.0
#define BIG_IMG_HEIGHT 340.0

@interface MainController () <UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PlayerDelegate,reloadTableDeleage, GetAllMessagesProtocol>
{
    NSMutableArray *bubbleData;
    CreateUI * createUI;
    
    UIScrollView *scrollView;//表情滚动视图
    UIPageControl *pageControl;
    
    BOOL keyboardIsShow;//键盘是否显示
    BOOL isFace;
    
    NSData *myData;
    NSData * otherData;
    BOOL isTakeImage;

    PhotoHandler *photoHandler;
    VideoHandler *videoHandler;
    MessageHandler *messageHandler;
    AudioHandler *audioHandler;
    
    UIImage * sendImage;
}

@property(nonatomic,retain) Voice * voice;

@end

@implementation MainController

@synthesize bubbleTableView,toolBar,messageText,iconButton ,recordButton,recordOrKeyboardButton,keyBoardButton;
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

-(void)initWithToolBar{
    
    //初始化为NO added
    keyboardIsShow=NO;
    isFace = NO;
    isTakeImage = NO;
    
    recordOrKeyboardButton = [createUI setButtonFrame:CGRectMake(0, 2, 30, 36) withTitle:(@"nil")];
    [recordOrKeyboardButton setImage:[UIImage imageNamed:@"microphone24.png"] forState:UIControlStateNormal];
    [recordOrKeyboardButton addTarget:self action:@selector(KeyboardTorecordClicked) forControlEvents:UIControlEventTouchUpInside];
   
    iconButton = [createUI setButtonFrame:CGRectMake(30, 2, 30, 36) withTitle:@"nil"];
    [iconButton setImage:[UIImage imageNamed:@"plus24.png"] forState:UIControlStateNormal];
    [iconButton addTarget:self action:@selector(photoClicked) forControlEvents:UIControlEventTouchUpInside];
    
    messageText = [createUI setTextFrame:CGRectMake(60, 3, toolBar.frame.size.width-65, 34)];
    messageText.delegate = self;
    messageText.returnKeyType = UIReturnKeySend;
    
    [toolBar addSubview:recordOrKeyboardButton];
    [toolBar addSubview:iconButton];
    [toolBar addSubview:messageText];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    ImageCache * imageCache =  [ImageCache sharedObject];
    NSString *sendToID = [imageCache getFriendID];
    
    self.title = [NSString stringWithFormat:@"chat to %@",sendToID];

    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString * userID = [handler getUserID];
    
    
    bubbleData = [[NSMutableArray alloc]init];
    TalkDB * talk =[[TalkDB alloc]init];
    bubbleData = [talk readInitDB:userID withOtherID:sendToID];
    for (NSBubbleData * data in bubbleData) {
        data.delegate = self;
    }
    
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:userID];
    NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
    myData = [imageCache getImage:pImageId];
    
    NSMutableDictionary *metaData = [imageCache getUserMetadata:sendToID];
    NSString *pImageId2 = [metaData objectForKey:@"profileImageId"];
    otherData = [imageCache getImage:pImageId2];
    
    BackData *data = [BackData sharedObject];
    UIImage *bgImage =[data getImage];
    if (bgImage) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    }else{
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    }
    
    [bubbleTableView reloadData];
    [self scrollBubbleViewToBottomAnimated:YES];
    NSLog(@"");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    
    createUI = [[CreateUI alloc]init];
    
    self.voice = [[Voice alloc] init];
   
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
    //给键盘注册通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    timeArray = [[NSMutableArray alloc]initWithObjects:@"1s",@"2s",@"3s",@"4s",@"5s",@"6s",@"7s",@"8s",@"9s",@"10s", nil];

    //handler
    photoHandler = [[PhotoHandler alloc] init];
    [photoHandler setController:self];
    
    videoHandler = [[VideoHandler alloc]init];
    
    messageHandler = [[MessageHandler alloc] init];
    
    audioHandler = [[AudioHandler alloc]init];

}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    ImageCache *imageCache = [ImageCache sharedObject];
    HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:[handler getUserID]];
    NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
    myData = [imageCache getImage:pImageId];
    NSString *sendToID =[imageCache getFriendID];
    NSMutableDictionary *metaData = [imageCache getUserMetadata:sendToID];
    NSString *pImageId2 = [metaData objectForKey:@"profileImageId"];
    otherData = [imageCache getImage:pImageId2];
    return [bubbleData objectAtIndex:row];
}

-(void)getFiles:(NSData *)data withFromID:(NSString *)fromID withBody:(NSString *)body{
    
    ImageCache *imageCache = [ImageCache sharedObject];
    HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
    
    NSMutableDictionary *userMetaData = [imageCache getUserMetadata:[handler getUserID]];
    NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
    myData = [imageCache getImage:pImageId];
    NSString *sendToID =[imageCache getFriendID];
    NSMutableDictionary *metaData = [imageCache getUserMetadata:sendToID];
    NSString *pImageId2 = [metaData objectForKey:@"profileImageId"];
    otherData = [imageCache getImage:pImageId2];
    
    NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *json = [decoder objectWithData:jsonData];
    NSString *type = [json objectForKey:@"type"];
    
    if ([type isEqualToString:@"photo"]) {
        [photoHandler receiveFile:data forBubbleDataArray:bubbleData forBubbleOtherData:otherData withSendId:sendToID withFromId:fromID];
        
    }else if ([type isEqualToString:@"video"]){
        [videoHandler setController:self];
        [videoHandler receiveVideoFile:data forBubbleDataArray:bubbleData forBubbleOtherData:otherData withSendId:sendToID withFromId:fromID];
        
    }else if ([type isEqualToString:@"voice"]){

        NSString * time = [json objectForKey:@"duration"];
        [audioHandler receiveAudioFile:data withBody:time forBubbleDataArray:bubbleData forBubbleOtherData:otherData withSendId:sendToID withFromId:fromID];
    }
    [bubbleTableView reloadData];
    [self scrollBubbleViewToBottomAnimated:YES];
    

}
-(void)getMessages:(NSString *)messages withFromID:(NSString *)fromID{
    ImageCache *imageCache = [ImageCache sharedObject];
    NSString *sendToID =[imageCache getFriendID];
    [messageHandler receiveMessage:messages forBubbleDataArray:bubbleData forBubbleOtherData:otherData withSendId:sendToID withFromId:fromID];
    [bubbleTableView reloadData];
    [self scrollBubbleViewToBottomAnimated:YES];

}
#pragma mark - Actions

#pragma mark send  message
-(void)sendMessages {
    ImageCache *imageCache = [ImageCache sharedObject];
    NSString *sendToID =[imageCache getFriendID];
    if (sendToID) {
        
        NSString * messages = messageText.text;
        if ([messages length]!=0) {
            [messageHandler sendMessage:messages forBubbleDataArray:bubbleData forBubbleMyData:myData withSendId:sendToID];
            messageText.text = @"";
            [self dismissKeyBoard];
            [messageText resignFirstResponder];
            [bubbleTableView reloadData];
            [self scrollBubbleViewToBottomAnimated:YES];
        }else {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"please input chat Contents" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"you are waiting..." delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    [self dismissKeyBoard];
    
}
#pragma mark send photo

-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(void) sendPhoto :(UIImage *)image {
    ImageCache *imageCache = [ImageCache sharedObject];
    NSString *sendToID =[imageCache getFriendID];
    if (sendToID) {
        [photoHandler sendPhoto:image forBubbleDataArray:bubbleData forBubbleMyData:myData withSendId:sendToID];
    }
    
    [bubbleTableView reloadData];
    [self dismissKeyBoard];
    [self scrollBubbleViewToBottomAnimated:YES];
}

-(void) sendVideo {
    ImageCache *imageCache = [ImageCache sharedObject];
    NSString *sendToID =[imageCache getFriendID];
    if (sendToID) {
        [videoHandler setController:self];
        [videoHandler setVideoPath:videoPath];
        [videoHandler sendVideoforBubbleDataArray:bubbleData forBubbleMyData:myData withSendId:sendToID];
        videoHandler.delegate = self;
        
    }
    
    [self dismissKeyBoard];
    [bubbleTableView reloadData];
    [self scrollBubbleViewToBottomAnimated:YES];
}
#pragma mark send audio
-(void) sendRecordAudio {
    ImageCache *imageCache = [ImageCache sharedObject];
    NSString *sendToID =[imageCache getFriendID];
    if (self.voice.recordTime >= 0.5f) {
        [audioHandler sendAudio:voice forBubbleDataArray:bubbleData forBubbleMyData:myData withSendId:sendToID];
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
    [iconButton removeFromSuperview];
    CGRect frame = CGRectMake(0, 2, 30, 36);
     keyBoardButton = [createUI setButtonFrame:frame withTitle:@"nil"];
    [keyBoardButton setImage:[UIImage imageNamed:@"keyboard34.png"] forState:UIControlStateNormal];
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
        [pageControl setHidden:NO];
        return;
    }
    //如果键盘没有显示，点击表情了，隐藏表情，显示键盘
    if (keyboardIsShow) {
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, keyboardHeight)];
        }];
        [pageControl setHidden:YES];
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
        [pageControl setHidden:NO];
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
    UIButton *button = (UIButton *)[self.view viewWithTag:BUTTON_TAG];
    [button removeFromSuperview];
    [pageControl setHidden:YES];
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
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(84, self.view.frame.size.height-35, 150, 30)];
    [pageControl setCurrentPage:0];
    pageControl.pageIndicatorTintColor=RGBACOLOR(195, 179, 163, 1);
    pageControl.currentPageIndicatorTintColor=RGBACOLOR(132, 104, 77, 1);
    pageControl.numberOfPages = 9;//指定页面个数
    [pageControl setBackgroundColor:[UIColor clearColor]];
    pageControl.hidden=NO;
    [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    
    UIButton *sendButton = [createUI setButtonFrame:CGRectMake(260, self.view.frame.size.height-35, 50, 30) withTitle:@"send"];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    sendButton.tag = BUTTON_TAG;
    [sendButton addTarget:self action:@selector(sendClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    [self disFaceKeyboard];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = scrollView.contentOffset.x / 320;//通过滚动的偏移量来判断目前页面所对应的小白点
    pageControl.currentPage = page;//pagecontroll响应值的变化
}
//pagecontroll的委托方法

- (void)changePage:(id)sender {
    int page = pageControl.currentPage;//获取当前pagecontroll的值
    [scrollView setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
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
    if (isTakeImage) {
        if (buttonIndex == 0) {
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.labelText = @"uploading file...";
            [self.view addSubview:HUD];
            [HUD showAnimated:YES whileExecutingBlock:^{
                [self sendPhoto:sendImage];
            }completionBlock:^{
                [HUD removeFromSuperview];
                HUD = nil;
            }];
            
            
        }else if (buttonIndex == 1) {
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
    isTakeImage = NO;
}
#pragma mark - Tool Methods
- (void)addPhoto
{
    isTakeImage = NO;
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
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
-(void)addVideo
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    [self presentViewController:imagePicker animated:YES completion:NULL];
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
        
        UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
        imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
        imagePickerController.delegate = self;
        imagePickerController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
         imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage,(NSString*)kUTTypeMovie,nil];
        imagePickerController.videoMaximumDuration = 10;
        
        [self presentViewController:imagePickerController animated:YES completion:NULL];
        
    }
   
}
#pragma mark 

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
       
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        sendImage = image;
        if (isTakeImage) {
            UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"Do you want to set a time for the picture?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            view.delegate = self;
            [view show];
        
        }else{
            [self sendPhoto:image];
        }
       /* ImageViewController * imageview = [[ImageViewController alloc]init];
        imageview.image = image;
        [picker  presentViewController:imageview animated:YES completion:NULL];
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [picker dismissViewControllerAnimated:YES completion:NULL];*/

    }else{
        videoPath = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *tempFilePath = [videoPath path];
        [picker dismissViewControllerAnimated:YES completion:NULL];
        UISaveVideoAtPathToSavedPhotosAlbum(tempFilePath,self, @selector(errorVideoCheck:didFinishSavingWithError:contextInfo:),NULL);
        [self sendVideo];
    }

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)errorVideoCheck:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
	
}

-(void)sendClicked{
    [self sendMessages];
}
#pragma mark textFiledDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMessages];
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
//        [self takeVideo];
        UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Video", @"Local Video",nil];
        actionsheet.delegate = self;
        actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionsheet showInView:self.view];
        [self scrollBubbleViewToBottomAnimated:YES];
    }
        
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takeVideo];
    }else if (buttonIndex == 1) {
        [self addVideo];
        
    }
    
}
-(void)bigImage:(UIImage *)image{
    UIImageViewController * iView = [[UIImageViewController alloc]init];
    iView.image = image;
    iView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:iView animated:YES completion:nil];
}

-(void) playerVideo:(NSString *)path{
    
    NSURL * url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController* pView = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentViewController:pView animated:YES completion:NULL];
 
}
-(void)reloadTable{
    
    [bubbleTableView reloadData];
    [self scrollBubbleViewToBottomAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
