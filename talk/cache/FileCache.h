//
//  FileCache.h
//  talk
//
//  Created by wangsh on 13-12-12.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject

+(FileCache *)sharedObject;

- (void)writeFileDoc:(NSString *)fileName withData:(NSData *)data;

- (NSData *)readFromFileDoc:(NSString *)fileName;


@end
