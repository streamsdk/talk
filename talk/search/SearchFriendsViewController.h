//
//  SearchFriendsViewController.h
//  talk
//
//  Created by wangsh on 13-12-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentedControl.h"
@interface SearchFriendsViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,SegmentedControlDelegate>
{
     SegmentedControl *_segmentedControl;
     BOOL isRefresh;
}
@property (nonatomic,strong) UITableView * myTableview;
@property (nonatomic,strong) NSMutableArray *userData;

@end