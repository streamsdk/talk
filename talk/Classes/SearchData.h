//
//  SearchData.h
//  talk
//
//  Created by wangsh on 13-12-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchData : NSObject
+ (SearchData *)sharedObject;

-(void) setSearchData:(NSString * )string;

-(NSMutableArray *) getSearchData;

@end
