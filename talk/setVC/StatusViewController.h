//
//  StatusViewController.h
//  talk
//
//  Created by wangsh on 14-3-28.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView * myTableView ;

@property (nonatomic,strong) NSMutableArray * statusArray;

@property (nonatomic,retain) NSString * status;

@end
