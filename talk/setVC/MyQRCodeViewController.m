//
//  MyQRCodeViewController.m
//  talk
//
//  Created by wangsh on 14-3-17.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "MyQRCodeViewController.h"
#import "ZXMultiFormatWriter.h"
#import "ZXImage.h"
@interface MyQRCodeViewController ()

@end

@implementation MyQRCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"My QRCode";
     UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, 80,280, 280)];
    [self.view addSubview:imageview];
    NSString * text = @"对方只需要CoolChat的二维码阅读器扫瞄此二维码，便可以将您添加为好友。";
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    CGSize size = [(text ? text : @"") boundingRectWithSize:CGSizeMake(280, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 360, size.width, size.height)];
    label.numberOfLines = 0;
    label.font = font;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * userId = [userDefaults objectForKey:@"username"];
    if (userId && ![userId isEqualToString:@""]) {
        ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
        ZXBitMatrix *result = [writer encode:userId format:kBarcodeFormatQRCode width:imageview.frame.size.width height:imageview.frame.size.width error:nil];
        if (result) {
            imageview.image = [UIImage imageWithCGImage:[ZXImage imageWithMatrix:result].cgimage];
            label.text = text;
        } else {
            imageview.image = nil;
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
