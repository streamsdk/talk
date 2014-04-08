//
//  SearchImageView.h
//  talk
//
//  Created by wangsh on 14-4-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageSendProtocol.h"
@interface SearchImageViewController : UIViewController<UISearchBarDelegate,UISearchDisplayDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UISearchBar * searchBar;
@property (nonatomic,strong) UIScrollView *scrollerView;
@property (nonatomic,strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic,assign) id <ImageSendProtocol> imageSendProtocol;

@end
