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

@interface UIBubbleTableView ()

@property (nonatomic, retain) NSMutableArray *bubbleSection;

@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleSection = _bubbleSection;
@synthesize typingBubble = _typingBubble;
@synthesize showAvatars = _showAvatars;


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
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]init];
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
        if (data._videoPath) {
           /* UIButton * downButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [downButton setFrame:CGRectMake(200, cell.frame.size.height, 100, 30)];
            [downButton setTitle:@"Download" forState:UIControlStateNormal];
            [[downButton layer] setBorderColor:[[UIColor blackColor] CGColor]];
            [[downButton layer] setBorderWidth:1];
            [[downButton layer] setCornerRadius:4];
            [downButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cell.contentView addSubview:downButton];
            
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]init];
            [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            activityIndicatorView.frame = CGRectMake(220, cell.frame.size.height, 20, 20);
            [activityIndicatorView setCenter:CGPointMake(220, cell.frame.size.height)];
            [cell.contentView addSubview:activityIndicatorView];*/
        }
    }

    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    NSLog(@"row  = %d",indexPath.row);
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
