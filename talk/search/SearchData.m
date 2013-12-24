//
//  SearchData.m
//  talk
//
//  Created by wangsh on 13-12-9.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SearchData.h"

static NSMutableDictionary * _searchDict;
static NSMutableArray * _searchData;
static NSMutableSet * _set;

@implementation SearchData


+(SearchData *) sharedObject{
    static SearchData *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[SearchData alloc] init];
        _searchDict = [[NSMutableDictionary alloc]init];
        _searchData = [[NSMutableArray alloc]init];
        _set = [[NSMutableSet alloc]init];
    });
    
    return sharedInstance;

}
-(void) setSearchData:(NSString *)string withUserID:(NSString *)id{
    if (![_set containsObject:string]) {
        [_set addObject:string];
        [_searchData addObject:string];
        [_searchDict setObject:_searchData forKey:id];
    }
   
}
-(NSMutableArray *) getSearchData:(NSString * )id{
    
    return [_searchDict objectForKey:id];
}
@end
