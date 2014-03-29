//
//  UIBubbleTableView.m
//
//  Created by Alex Barinov

//

#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "UIBubbleHeaderTableViewCell.h"
#import "UIBubbleTypingTableViewCell.h"
#import "AppDelegate.h"
#import "Progress.h"
#import <arcstreamsdk/JSONKit.h>
#import <arcstreamsdk/STreamSession.h>
#import "TalkDB.h"
#import "DownloadDB.h"
#import "HandlerUserIdAndDateFormater.h"
#import "ImageCache.h"
#import "TalkDB.h"
#import "DownLoadVideo.h"
//static int count =20;
#define BUBBLETABLEVIEWCELL_TAG 1000

@interface UIBubbleTableView ()
{
//    UIActivityIndicatorView *activityIndicatorView ;
}
@property (nonatomic, retain) NSMutableArray *bubbleSection;

@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleSection = _bubbleSection;
@synthesize typingBubble = _typingBubble;
@synthesize showAvatars = _showAvatars;
@synthesize isEdit = _isEdit;
#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    
    // UIBubbleTableView default properties
    
    self.snapInterval = 120;
    self.typingBubble = NSBubbleTypingTypeNobody;
    _reloading = NO;
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_bubbleSection release];
	_bubbleSection = nil;
	_bubbleDataSource = nil;
    [super dealloc];
}
#endif

#pragma mark - Override

- (void)reloadData
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // Cleaning up
	self.bubbleSection = nil;
    // Loading new data
    int count = 0;
#if !__has_feature(objc_arc)
    self.bubbleSection = [[[NSMutableArray alloc] init] autorelease];
#else
    self.bubbleSection = [[NSMutableArray alloc] init];
#endif
    
    if (self.bubbleDataSource && (count = [self.bubbleDataSource rowsForBubbleTable:self]) > 0)
    {
#if !__has_feature(objc_arc)
        NSMutableArray *bubbleData = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
#else
        NSMutableArray *bubbleData = [[NSMutableArray alloc] initWithCapacity:count];
#endif
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[NSBubbleData class]]);
            [bubbleData addObject:object];
        }
        
        [bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             NSBubbleData *bubbleData1 = (NSBubbleData *)obj1;
             NSBubbleData *bubbleData2 = (NSBubbleData *)obj2;
             
             return [bubbleData1.date compare:bubbleData2.date];            
         }];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        
        for (int i = 0; i < count; i++)
        {
            NSBubbleData *data = (NSBubbleData *)[bubbleData objectAtIndex:i];
            
            if ([data.date timeIntervalSinceDate:last] > self.snapInterval)
            {
#if !__has_feature(objc_arc)
                currentSection = [[[NSMutableArray alloc] init] autorelease];
#else
                currentSection = [[NSMutableArray alloc] init];
#endif
                [self.bubbleSection addObject:currentSection];
            }
            
            [currentSection addObject:data];
            last = data.date;
        }
    }
   
    [super reloadData];
}

#pragma mark - UITableViewDelegate implementation

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int result = [self.bubbleSection count];
    if (self.typingBubble != NSBubbleTypingTypeNobody) result++;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This is for now typing bubble
	if (section >= [self.bubbleSection count]) return 1;
    
    return [[self.bubbleSection objectAtIndex:section] count] + 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        return MAX([UIBubbleTypingTableViewCell height], self.showAvatars ? 52 : 0);
    }
    
    // Header
    if (indexPath.row == 0)
    {
        return [UIBubbleHeaderTableViewCell height];
    }
    
    NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom, self.showAvatars ? 52 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        static NSString *cellId = @"tblBubbleTypingCell";
        UIBubbleTypingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        cell.backgroundColor = [UIColor clearColor];
        
        if (cell == nil) cell = [[UIBubbleTypingTableViewCell alloc] init];

        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        cell.type = self.typingBubble;
        cell.showAvatar = self.showAvatars;
        
        return cell;
    }

    // Header with date and time
    if (indexPath.row == 0)
    {
        static NSString *cellId = @"tblBubbleHeaderCell";
        UIBubbleHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        if (cell == nil) cell = [[UIBubbleHeaderTableViewCell alloc] init];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.date = data.date;
        return cell;
    }
    // Standard bubble    
    static NSString *cellId = @"tblBubbleCell";
    UIBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) cell = [[UIBubbleTableViewCell alloc] init];
    [cell setBackgroundColor:[UIColor clearColor]];
    NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    cell.data = data;
    cell.showAvatar = self.showAvatars;
    cell.isEdit = self.isEdit;
    cell.tag =indexPath.row+1000*indexPath.section;;
    if (cell.data.type == BubbleTypeMine) {
         Progress * p = [[Progress alloc]init];
        if ( cell.data.fileType == FileVideo) {
            UIProgressView*progressView = [[UIProgressView alloc]init];
            [progressView setProgressViewStyle:UIProgressViewStyleDefault];
            progressView .frame = CGRectMake(24, cell.frame.size.height+25, 90, 8);
            CGAffineTransform transform =CGAffineTransformMakeScale(1.0f,2.0f);
            progressView.transform = transform;
            progressView.hidden = YES;
            UILabel *label = [[UILabel alloc]init];
            label.backgroundColor = [UIColor clearColor];
            label.frame = CGRectMake(0, cell.frame.size.height+10, 60, 30);
            [label setFont:[UIFont systemFontOfSize:11.0f]];
            label.hidden = YES;
            [cell.contentView addSubview:progressView];
            [cell.contentView addSubview:label];
            p.progressView = progressView;
            p.label = label;
            NSString * path =data._videoPath;
            if (path!=nil && ![path isEqualToString:@""]) {
                [APPDELEGATE.progressDict setValue:p forKey:path];
            }
        }
        if (cell.data.fileType == FileDisappear) {
           UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc]init];
            [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            activityIndicatorView.frame = CGRectMake(60, cell.frame.size.height-15, 20, 20);
            [activityIndicatorView setCenter:CGPointMake(60, cell.frame.size.height-15)];
            [cell.contentView addSubview:activityIndicatorView];
            p.activityIndicatorView = activityIndicatorView;
            NSString * path =data.disappearPath;
            if (path!=nil && ![path isEqualToString:@""]) {
                [APPDELEGATE.progressDict setValue:p forKey:path];
            }
        }
        if (cell.data.fileType == FileImage) {
            UIProgressView * progressView = [[UIProgressView alloc]init];
            [progressView setProgressViewStyle:UIProgressViewStyleDefault];
            progressView .frame = CGRectMake(24, cell.frame.size.height, 90, 8);
            CGAffineTransform transform =CGAffineTransformMakeScale(1.0f,2.0f);
            progressView.transform = transform;
            progressView.hidden = YES;
            UILabel *label = [[UILabel alloc]init];
            label.backgroundColor = [UIColor clearColor];
            label.frame = CGRectMake(0, cell.frame.size.height, 60, 30);
            [label setFont:[UIFont systemFontOfSize:11.0f]];
            label.hidden = YES;
            [cell.contentView addSubview:progressView];
            [cell.contentView addSubview:label];
            p.progressView = progressView;
            p.label = label;
            
            UILabel *label2 = [[UILabel alloc]init];
            label2.frame = CGRectMake(0, 5, 60, 30);
            [label2 setFont:[UIFont systemFontOfSize:12.0f]];
            label.text=@"enfkewnfwf";
            NSString * path =data.photopath;
            [APPDELEGATE.progressDict setValue:p forKey:path];
           
        }
    }else{
        if (cell.data.fileType == FileVideo) {
            NSData *jsonData = [cell.data.jsonBody dataUsingEncoding:NSUTF8StringEncoding];
            JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
            NSDictionary *json = [decoder objectWithData:jsonData];
            NSString *fileId = [json objectForKey:@"id"];
            ImageCache * imagecache = [ImageCache sharedObject];
            BOOL isTheFileDownloading = [imagecache isFileDownloading:fileId];
            NSArray * array = [json allKeys];
            if ([array containsObject:@"tidpath"]) {
                UIButton * downButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [[downButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
                [[downButton layer] setBorderWidth:1];
                [[downButton layer] setCornerRadius:4];
                downButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
                [downButton setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.2]];
                [downButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                downButton .tag = indexPath.row+1000*indexPath.section;
                
                UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc]init];
                [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                
                [cell.contentView addSubview:activityIndicatorView];
                activityIndicatorView.tag = 1000*indexPath.section+indexPath.row+100;
                if (isTheFileDownloading) {
                    [activityIndicatorView startAnimating];
                    [self checkfileManager:json withButton:downButton withActivityIndicatorView:activityIndicatorView withCell:cell];
                }else{
                    if ([self checkfileManager:json withButton:downButton withActivityIndicatorView:activityIndicatorView withCell:cell]){
                        return cell;
                    }

                    [downButton setTitle:@"Download" forState:UIControlStateNormal];
                    [downButton addTarget:self action:@selector(downloadvideo:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:downButton];
                }
                if (self.isEdit) {
                    [downButton setFrame:CGRectMake(216, cell.frame.size.height-5, 100, 35)];
                    activityIndicatorView.frame = CGRectMake(236, cell.frame.size.height+20, 20, 20);
                    [activityIndicatorView setCenter:CGPointMake(236, cell.frame.size.height+20)];
                }else{
                    [downButton setFrame:CGRectMake(200, cell.frame.size.height-5, 100, 35)];
                    activityIndicatorView.frame = CGRectMake(220, cell.frame.size.height+20, 20, 20);
                    [activityIndicatorView setCenter:CGPointMake(220, cell.frame.size.height+20)];
                }

            }
            
        }
        if (cell.data.fileType == FileDisappear){
            if (![cell.data._videoPath hasPrefix:@".mp4"] && cell.data._videoPath) {
                UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]init];
                [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                activityIndicatorView.frame = CGRectMake(268, cell.frame.size.height-15, 20, 20);
                [activityIndicatorView setCenter:CGPointMake(268, cell.frame.size.height-15)];
                [cell.contentView addSubview:activityIndicatorView];
                activityIndicatorView.tag = indexPath.row+100+1000*indexPath.section;
                NSData *jsonData = [cell.data.jsonBody dataUsingEncoding:NSUTF8StringEncoding];
                JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
                NSDictionary *json = [decoder objectWithData:jsonData];
                NSString *fileId = [json objectForKey:@"id"];
                ImageCache * imagecache = [ImageCache sharedObject];
                BOOL isTheFileDownloading = [imagecache isFileDownloading:fileId];
                if (isTheFileDownloading) {
                    [activityIndicatorView startAnimating];
                    cell.data.videobutton.titleLabel.text =@"Downloading";
                }else {
                    if ([self checkfileManager:json withButton:cell.data.videobutton withActivityIndicatorView:activityIndicatorView withCell:cell]) {
                        [cell.data.videobutton setTitle:@"Click to view" forState:UIControlStateNormal];
                        [cell.data.videobutton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                        [cell.data.videobutton addTarget:self action:@selector(playerVideo:) forControlEvents:UIControlEventTouchUpInside];
                        return cell;
                    }

                    if ([cell.data.videobutton.titleLabel.text isEqualToString:@"Download"]) {
                        cell.data.videobutton.tag = indexPath.row+1000*indexPath.section;
                        [cell.data.videobutton addTarget:self action:@selector(downloadvideo:) forControlEvents:UIControlEventTouchUpInside];
                        
                    }
                    if ([cell.data.videobutton.titleLabel.text isEqualToString:@"Downloading"]){
                        cell.data.videobutton.tag = indexPath.row+1000*indexPath.section;
                        [activityIndicatorView startAnimating];
                    }
                }
                
            }
        }
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (indexPath.row !=0) {
        NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
        if (data.fileType == FileMessage) {
            if (action == @selector(copy:)) {
                return YES;
            }
        }
        
    }
    
    return NO;
}
-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (indexPath.row !=0) {
        ImageCache * imagecache = [ImageCache sharedObject];
        NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
        if (action==@selector(copy:)) {
            TalkDB * talk = [[TalkDB alloc]init];
            NSString *contents = [talk readDB:data.date];
            NSDictionary *ret = [contents objectFromJSONString];
            NSDictionary * chatDic = [ret objectForKey:[imagecache getFriendID]];
            NSString *message =[chatDic objectForKey:@"messages"];
            NSLog(@"message = %@",message);
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            [pasteBoard setString:message];
            
        }
    }
    
}
-(BOOL)checkfileManager:(NSDictionary *)json withButton:(UIButton *)button withActivityIndicatorView: (UIActivityIndicatorView *)activityIndicatorView withCell:(UIBubbleTableViewCell *)cell {
    NSString *fileId = [json objectForKey:@"fileId"];
    
    NSString *tid = [json objectForKey:@"tid"];
    NSString * fromId =[json objectForKey:@"fromId"];
    NSString *duration = [json objectForKey:@"duration"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath =[NSHomeDirectory() stringByAppendingFormat:@"/Documents/out-%@.mp4", fileId];
    if([fileManager fileExistsAtPath:filePath]){
        
        TalkDB * talkDb = [[TalkDB alloc]init];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
        if (tid) {
            [dict setObject:tid forKey:@"tid"];
        }
        
        [dict setObject:fileId forKey:@"fileId"];
        [dict setObject:filePath forKey:@"filepath"];
        if (duration) {
            [dict setObject:duration forKey:@"duration"];
        }
        if (!fromId) return NO;
        
        [jsonDic setObject:dict forKey:fromId];
        NSString * jsonBody = [jsonDic JSONString];
        [talkDb updateDB:cell.data.date withContent:jsonBody];
        cell.data._videoPath = filePath;
        cell.data.jsonBody = jsonBody;
        if (cell.data.fileType == FileDisappear){
            [cell.data.videobutton setTitle:@"Click to view" forState:UIControlStateNormal];
            [cell.data.videobutton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            //            [cell.data.videobutton addTarget:self action:@selector(playerVideo:) forControlEvents:UIControlEventTouchUpInside];
            [activityIndicatorView stopAnimating];
        }else{
            button.hidden = YES;
            [activityIndicatorView stopAnimating];
            //            [self playerVideo:button];
        }
        return YES;
    }
        return NO;
}
-(void) downloadvideo:(UIButton *)button{
    ImageCache * cache = [ImageCache sharedObject];
    DownLoadVideo *_downVideo = [[DownLoadVideo alloc]init];
    
    UIBubbleTableViewCell * cell = (UIBubbleTableViewCell * )[self viewWithTag:button.tag];
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [cell.contentView viewWithTag:button.tag+100];
    [activityIndicatorView startAnimating];
    NSString * jsonbody = cell.data.jsonBody;
    NSData *jsonData = [jsonbody dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *json = [decoder objectWithData:jsonData];
    NSString *timeId = [json objectForKey:@"id"];
    BOOL fileExist =[self checkfileManager:json withButton:button withActivityIndicatorView:activityIndicatorView withCell:cell];
    if (!fileExist){
        [cache addDownloadingFile:timeId withTag:[NSNumber numberWithInt:button.tag]];
        if (cell.data.fileType == FileVideo){
            button.hidden = YES;
            [_downVideo setButton:button];
        }else{
            [_downVideo setButton:cell.data.videobutton];
            [cell.data.videobutton setTitle:@"downloading" forState:UIControlStateNormal];
        }
        [_downVideo setDict:json];
        [_downVideo setDate:cell.data.date];
        [_downVideo setCell:cell];
        [_downVideo setActivityIndicatorView:activityIndicatorView];
        if (![cache downVideoArrayIsNull]) {
            [cache saveDownVideo:_downVideo];
            return;
        }
        [cache saveDownVideo:_downVideo];
        [self downVideo:_downVideo];
    }
    
}
-(void)downVideo :(DownLoadVideo *)loadvieo{
    ImageCache * cache = [ImageCache sharedObject];
    DownloadDB * download = [[DownloadDB alloc]init];
    NSDictionary *json = loadvieo.dict;
    NSString *fileId = [json objectForKey:@"fileId"];
    NSString *timeId = [json objectForKey:@"id"];
    NSString *urlString = [STreamSession getFileObjectDownloadUrl:fileId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               UIBubbleTableViewCell * cell = (UIBubbleTableViewCell *)[self viewWithTag:loadvieo.button.tag];
                               UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [cell.contentView viewWithTag:loadvieo.button.tag+100];;
                               if ( !error ){
                                   
                                   NSString *tid = [json objectForKey:@"tid"];
                                   NSString * fromId =[json objectForKey:@"fromId"];
                                   NSString *duration = [json objectForKey:@"duration"];
                                   
                                   if (cell.data.fileType == FileDisappear){
                                       [cell.data.videobutton setTitle:@"Click to view" forState:UIControlStateNormal];
                                       [cell.data.videobutton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                                       [cell.data.videobutton addTarget:self action:@selector(playerVideo:) forControlEvents:UIControlEventTouchUpInside];
                                   }
                                   HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
                                   TalkDB * talkDb = [[TalkDB alloc]init];
                                   NSString * filepath= [NSHomeDirectory() stringByAppendingFormat:@"/Documents/out-%@.mp4", fileId];
                                   [data writeToFile : filepath atomically: YES ];
                                   [handler videoPath:filepath];
                                   NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
                                   NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
                                   if (tid) {
                                       [dict setObject:tid forKey:@"tid"];
                                   }
                                   [dict setObject:fileId forKey:@"fileId"];
                                   [dict setObject:filepath forKey:@"filepath"];
                                   if (duration) {
                                       [dict setObject:duration forKey:@"duration"];
                                   }
                                   [dict setObject:fromId forKey:@"fromId"];
                                   [jsonDic setObject:dict forKey:fromId];
                                   NSString * jsonBody = [jsonDic JSONString];
                                   [download deleteDownloadDBFromFileID:fileId];
                                   [talkDb updateDB:cell.data.date withContent:jsonBody];
                                   cell.data._videoPath = filepath;
                                   cell.data.jsonBody = jsonBody;
                                   [activityIndicatorView stopAnimating];
                                   [cache removeDownloadingFile:timeId];
                                   [self reloadData];
                               } else{
                                   if (cell.data.fileType == FileDisappear){
                                       [cell.data.videobutton setTitle:@"Download" forState:UIControlStateNormal];
                                       [cell.data.videobutton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                                       [cell.data.videobutton addTarget:self action:@selector(downloadvideo:) forControlEvents:UIControlEventTouchUpInside];
                                   }else{
                                       UIButton * button = loadvieo.button;
                                       button.hidden = NO;
                                       [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                                       [button addTarget:self action:@selector(downloadvideo:) forControlEvents:UIControlEventTouchUpInside];
                                   }
                                   [activityIndicatorView stopAnimating];
                                   [cache removeDownloadingFile:timeId];
                               }
                               [cache deleteDownVideo];
                               if (![cache downVideoArrayIsNull]) {
                                   DownLoadVideo * downVideo = [cache getDownVideo];
                                   [self downVideo:downVideo];
                               }
                           }];
    
}
-(void)playerVideo:(UIButton *)button {
    UIBubbleTableViewCell * cell = (UIBubbleTableViewCell * )[self viewWithTag:button.tag];
    NSString * jsonbody = cell.data.jsonBody;
    NSData *jsonData = [jsonbody dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *json = [decoder objectWithData:jsonData];
    NSArray * key = [json allKeys];
    NSDictionary *dict = [json objectForKey:[key objectAtIndex:0]];
    NSString *duration = [dict objectForKey:@"duration"];
    [cell.data.delegate playerVideo:cell.data._videoPath withTime:duration withDate:cell.data.date ];
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    scrollView.decelerationRate=1.0;
    ImageCache * imageCache =  [ImageCache sharedObject];
    NSString *sendToID = [imageCache getFriendID];
    [imageCache saveTablecontentOffset:self.contentOffset.y withUser:sendToID];
    TalkDB * talk = [[TalkDB alloc]init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * name =[userDefaults objectForKey:@"username"];
    NSInteger allCount = [talk allDataCount:name withOtherID:sendToID];
     NSInteger readCount = [imageCache getAllReadCount:sendToID];
    int count = [imageCache getReadCount:sendToID];
    if (count>=10 && allCount!=readCount) {
        if(!_reloading && scrollView.contentOffset.y < 5)
        {
            _reloading = YES;
            [self loadDataBegin];
        }
    }
    
}

// 开始加载数据
- (void) loadDataBegin
{
    UIActivityIndicatorView *tableFooterActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 20.0f, 20.0f)];
    [tableFooterActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activity = tableFooterActivityIndicator;
    [activity startAnimating];
    self.tableHeaderView = activity;
    [self loadDataing];
}

// 加载数据中
- (void) loadDataing
{
    [self performSelectorInBackground:@selector(loadDataEnd) withObject:nil];
//    [self performSelector:@selector(loadDataEnd) withObject:nil afterDelay:1.0];
}

// 加载数据完毕
- (void) loadDataEnd
{
    ImageCache * imageCache =  [ImageCache sharedObject];
    NSString *sendToID = [imageCache getFriendID];
    
    HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
    NSString * userID = [handler getUserID];
    int count = [imageCache getReadCount:sendToID];
    count= count+10;
    NSMutableArray *bubbleData = [[NSMutableArray alloc]init];
    TalkDB * talk =[[TalkDB alloc]init];
    bubbleData = [talk readInitDB:userID withOtherID:sendToID withCount:count];
    [imageCache saveRaedCount:[NSNumber numberWithInt:count] withuserID:sendToID];
    [self.bubbleDataSource reloadBubbleView:bubbleData];
    [activity stopAnimating];
    [activity removeFromSuperview];
    _reloading = NO;
    [imageCache saveTablecontentOffset:self.contentOffset.y withUser:sendToID];
}


#pragma mark - Public interface

- (void) scrollBubbleViewToBottomAnimated:(BOOL)animated
{
   NSInteger lastSectionIdx = [self numberOfSections] - 1;

    
    if (lastSectionIdx >= 0)
    {
    	[self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self numberOfRowsInSection:lastSectionIdx] - 1) inSection:lastSectionIdx] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


@end
