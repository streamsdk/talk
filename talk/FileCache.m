//
//  FileCache.m
//  talk
//
//  Created by wangsh on 13-12-12.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "FileCache.h"

static NSMutableArray * imageArray;
static NSMutableSet *_downloadedFiles;
static NSMutableSet *_downloadingFiles;

@implementation FileCache

+(FileCache *)sharedObject{
    
    static FileCache *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[FileCache alloc]init];
        imageArray = [[NSMutableArray alloc]init];
        _downloadedFiles = [[NSMutableSet alloc] init];
        _downloadingFiles = [[NSMutableSet alloc] init];
        
    });
    return sharedInstance;
}

-(void)writeFileDoc:(NSString *)fileName withData:(NSData *)data{
    
    NSString *fName = [[self documentsPath] stringByAppendingPathComponent:fileName];
    [data writeToFile:fName atomically:YES];
}

-(NSData *) readFromFileDoc:(NSString *)fileName {
    
    NSString * fName = [[self documentsPath] stringByAppendingPathComponent:fileName];
    
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:fName];
    
    NSData * content = [fileHandle readDataToEndOfFile];
    return content;
}

-(NSString *) documentsPath {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsdir = [paths objectAtIndex:0];
    return documentsdir;
}

@end
