//
//  FilesUpload.h
//  talk
//
//  Created by wangsh on 14-2-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilesUpload : NSObject

@property (nonatomic,retain) NSString * id;
@property (nonatomic,retain) NSString *filepath;
@property (nonatomic,retain) NSMutableDictionary * bodyDict;
@property (nonatomic,retain) NSString * userId;
@end
