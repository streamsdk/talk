//
//  ReadStatus.h
//  talk
//
//  Created by wangsh on 14-4-3.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadStatus : NSObject

-(void)loadAllMetaData ;

-(NSString *)readStatus:(NSString *)froemID;
@end
