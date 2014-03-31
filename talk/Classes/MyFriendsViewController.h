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
#import "UploadProtocol.h"
@interface MyFriendsViewController : UIViewController<STreamXMPPProtocol,EGORefreshTableHeaderDelegate,UITableViewDelegate,UITableViewDataSource>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (nonatomic,retain) NSMutableArray *userData;
@property (nonatomic, retain) NSMutableArray *sortedArrForArrays;
@property (nonatomic, retain) NSMutableArray *sectionHeadsKeys;
@property (assign,nonatomic) id<GetAllMessagesProtocol> messagesProtocol;
@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) UIButton * button;
@property (assign,nonatomic) id<UploadProtocol> uploadProtocol;
@property(nonatomic,strong) UIToolbar *toolBar;
@property (nonatomic, retain) NSMutableDictionary *statusDict;
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

@end
