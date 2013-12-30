//
//  MyFriendsViewController.h
//  talk
//
//  Created by wangsh on 13-12-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STreamXMPPProtocol.h"
#import "GetAllMessagesProtocol.h"
#import "EGORefreshTableHeaderView.h"
@interface MyFriendsViewController : UITableViewController<STreamXMPPProtocol,EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshTableView;
    BOOL _reloading;
}
@property (nonatomic,retain) NSMutableArray *userData;
@property (nonatomic, retain) NSMutableArray *sortedArrForArrays;
@property (nonatomic, retain) NSMutableArray *sectionHeadsKeys;
@property (assign,nonatomic) id<GetAllMessagesProtocol> messagesProtocol;

//start
- (void)reloadTableViewDataSource;
//done
- (void)doneLoadingTableViewData;
@end
