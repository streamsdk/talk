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
#import "PlayerDelegate.h"

#define BUBBLETABLEVIEWCELL_TAG 1000

@interface UIBubbleTableView ()
{
    UIActivityIndicatorView *activityIndicatorView ;
}
@property (nonatomic, retain) NSMutableArray *bubbleSection;
@property (assign,nonatomic) id <PlayerDelegate> playerDelegate;
@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleSection = _bubbleSection;
@synthesize typingBubble = _typingBubble;
@synthesize showAvatars = _showAvatars;
@synthesize playerDelegate;

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
    cell.tag =indexPath.row;
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
            activityIndicatorView = [[UIActivityIndicatorView alloc]init];
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
            NSArray * array = [json allKeys];
            if ([array containsObject:@"tidpath"]) {
                UIButton * downButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [downButton setFrame:CGRectMake(200, cell.frame.size.height, 100, 30)];
                [downButton setTitle:@"Download" forState:UIControlStateNormal];
                [[downButton layer] setBorderColor:[[UIColor blueColor] CGColor]];
                [[downButton layer] setBorderWidth:1];
                [[downButton layer] setCornerRadius:4];
                [downButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [downButton addTarget:self action:@selector(downloadvideo:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:downButton];
                downButton .tag = indexPath.row;
                
                activityIndicatorView = [[UIActivityIndicatorView alloc]init];
                [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                activityIndicatorView.frame = CGRectMake(220, cell.frame.size.height, 20, 20);
                [activityIndicatorView setCenter:CGPointMake(220, cell.frame.size.height)];
                [cell.contentView addSubview:activityIndicatorView];
                activityIndicatorView.tag = indexPath.row;
            }
            
        }
        if (cell.data.fileType == FileDisappear){
            if (![cell.data._videoPath hasPrefix:@".mp4"]) {
                if ([cell.data.videobutton.titleLabel.text isEqualToString:@"Download"]) {
                    cell.data.videobutton.tag = indexPath.row;
                    [cell.data.videobutton addTarget:self action:@selector(downloadvideo:) forControlEvents:UIControlEventTouchUpInside];
                    activityIndicatorView = [[UIActivityIndicatorView alloc]init];
                    [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicatorView.frame = CGRectMake(250, cell.frame.size.height-20, 20, 20);
                    [activityIndicatorView setCenter:CGPointMake(250, cell.frame.size.height-20)];
                    [cell.contentView addSubview:activityIndicatorView];
                    activityIndicatorView.tag = indexPath.row;
                }
                
            }
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    NSLog(@"row  = %d",indexPath.row);
}

-(void) downloadvideo:(UIButton *)button{
   
   
    UIBubbleTableViewCell * cell = (UIBubbleTableViewCell * )[self viewWithTag:button.tag];
//    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [self viewWithTag:button.tag];
    if (cell.data.fileType == FileVideo){
         button.hidden = YES;
    }else{
        [cell.data.videobutton setTitle:@"downloading" forState:UIControlStateNormal];
    }
    DownloadDB * download = [[DownloadDB alloc]init];
    [activityIndicatorView startAnimating];
    NSString * jsonbody = cell.data.jsonBody;
    NSData *jsonData = [jsonbody dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *json = [decoder objectWithData:jsonData];
    NSString *fileId = [json objectForKey:@"fileId"];
    NSString *tid = [json objectForKey:@"tid"];
    NSString * fromId = [download readDownloadDBFromFileID:fileId];
    NSString *duration = [json objectForKey:@"duration"];
    NSString *urlString = [STreamSession getFileObjectDownloadUrl:fileId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   if (cell.data.fileType == FileDisappear){
                                       [cell.data.videobutton setTitle:@"Click to view" forState:UIControlStateNormal];
                                       [cell.data.videobutton addTarget:self action:@selector(playerVideo:) forControlEvents:UIControlEventTouchUpInside];
                                   }
                                   HandlerUserIdAndDateFormater * handler = [HandlerUserIdAndDateFormater sharedObject];
                                   TalkDB * talkDb = [[TalkDB alloc]init];
                                   NSString * filepath= [[handler getPath] stringByAppendingString:@".mp4"];
                                   [data writeToFile : filepath atomically: YES ];
                                   [handler videoPath:filepath];
                                   NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
                                   NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
                                   [dict setObject:tid forKey:@"tid"];
                                   [dict setObject:fileId forKey:@"fileId"];
                                   [dict setObject:filepath forKey:@"filepath"];
                                   if (duration) {
                                       [dict setObject:duration forKey:@"duration"];
                                   }
                                   [jsonDic setObject:dict forKey:fromId];
                                   NSString * json = [jsonDic JSONString];
                                   [talkDb updateDB:cell.data.date withContent:json];
                                   cell.data._videoPath = filepath;
                                   
                                   [download deleteDownloadDBFromFileID:fileId];
                                   [activityIndicatorView stopAnimating];

                               } else{
                               }
                           }];
    NSLog(@"download");
}

-(void)playerVideo:(UIButton *)button {
    UIBubbleTableViewCell * cell = (UIBubbleTableViewCell * )[self viewWithTag:button.tag];
    NSString * jsonbody = cell.data.jsonBody;
    NSData *jsonData = [jsonbody dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    NSDictionary *json = [decoder objectWithData:jsonData];
    NSString *duration = [json objectForKey:@"duration"];
    [playerDelegate playerVideo:cell.data._videoPath withTime:duration withDate:cell.data.date ];
    
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
