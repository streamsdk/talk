//
//  HandlerFirendsViewController.h
//  talk
//
//  Created by wangsh on 14-1-1.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderSwitch.h"


typedef enum {
    FriendsAdd   = 1000,
    FriendsSearch   = 1001,
    FriendsHistory   = 1002,
}FriendsType;

@interface HandlerFirendsViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,SliderSwitchDelegate>
{
    SliderSwitch *_sliderSwitch;
    FriendsType _friendsType;
    UITableView *myTableview;
    
    NSMutableArray *friendsAddArray;
    NSMutableArray *friendsSearchArray;
    NSMutableArray *friendsHistoryArray;
    
    CGPoint friendsAddPoint;
    CGPoint friendsSearchPoint;
    CGPoint friendsHistoryPoint;
}

@property (nonatomic,strong) UISearchBar * searchBar;
@end
