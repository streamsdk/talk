//
//  FileUpload.h
//  talk
//
//  Created by wangsh on 14-2-8.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUpload : NSObject

@property (nonatomic, strong)NSString *friendId;
@property (nonatomic, strong)NSData *fileData;
@property (nonatomic, strong)NSMutableDictionary *bodyDic;

@end
