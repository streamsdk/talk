//
//  HandlerFirendsViewController.h
//  talk
//
//  Created by wangsh on 14-1-1.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FriendsAdd   = 0,
    FriendsSearch   = 1,
    FriendsHistory   = 2,
}FriendsType;

@interface HandlerFirendsViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    FriendsType _friendsType;
    UITableView *myTableview;
    
    NSMutableArray *friendsAddArray;
    NSMutableArray *friendsSearchArray;
    NSMutableArray *friendsHistoryArray;
    
    CGPoint friendsAddPoint;
    CGPoint friendsSearchPoint;
    CGPoint friendsHistoryPoint;
    
    UISegmentedControl *segmentedControl;
}

@property (nonatomic,strong) UISearchBar * searchBar;
@end
