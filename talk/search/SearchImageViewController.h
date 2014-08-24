//
//  SearchImageView.h
//  talk
//
//  Created by wangsh on 14-4-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageSendProtocol.h"
@interface SearchImageViewController : UIViewController<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UISearchBar * searchBar;
@property (nonatomic,strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic,assign) id <ImageSendProtocol> imageSendProtocol;
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,assign) bool reloading;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,strong) UIActivityIndicatorView * footActivityIndicatorView;
@end
