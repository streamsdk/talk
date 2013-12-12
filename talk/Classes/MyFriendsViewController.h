//
//  MyFriendsViewController.h
//  talk
//
//  Created by wangsh on 13-12-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyFriendsViewController : UITableViewController

@property (nonatomic,retain) NSMutableArray *userData;
@property (nonatomic, retain) NSMutableArray *sortedArrForArrays;
@property (nonatomic, retain) NSMutableArray *sectionHeadsKeys;

@end
