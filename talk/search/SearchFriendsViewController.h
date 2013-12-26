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

}
@property (nonatomic,strong) UITableView * myTableview;
@property (nonatomic,strong) NSMutableArray *userData;
@property (nonatomic,strong) UISearchBar * searchBar;
@end
