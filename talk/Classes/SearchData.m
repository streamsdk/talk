//
//  SearchData.m
//  talk
//
//  Created by wangsh on 13-12-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SearchData.h"

static NSMutableArray * _searchData;

@implementation SearchData


+(SearchData *) sharedObject{
    static SearchData *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[SearchData alloc] init];
        _searchData = [[NSMutableArray alloc]init];
        
    });
    
    return sharedInstance;

}
-(void) setSearchData:(NSString *)string{
    [_searchData addObject:string];
}
-(NSMutableArray *) getSearchData {
    return _searchData;
}
@end
