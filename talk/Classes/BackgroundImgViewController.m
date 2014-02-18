//
//  BackgroundImgViewController.m
//  TextEditorDemo
//
//  Created by wangsh on 13-11-29.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "BackgroundImgViewController.h"
#import "MyFriendsViewController.h"
#import "ImageCache.h"
#import "HandlerUserIdAndDateFormater.h"
#import "ChatBackGround.h"
#import "MainController.h"
#import "BackData.h"

#define SPACE_WIDTH 20
#define IMAGE_HEIGHT_WIDTH 130
#define COLUMN 2

@interface BackgroundImgViewController ()

@end

@implementation BackgroundImgViewController

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
	// Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
	
    self.img = [[NSArray alloc]initWithObjects:@"b1.png",@"b2.png",@"b3.png",@"b4.png",@"b5.png",@"b6.png",@"background.png",nil];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,50, self.view.frame.size.width, self.view.frame.size.height-50)];
    int line = [self.img count]%COLUMN ? [self.img count]/COLUMN+1 :[self.img count]/COLUMN;
    int column;
    for (int i = 0; i < line; i++) {
        if (i == line-1) {
            column = [self.img count]%COLUMN ? [self.img count]%COLUMN :COLUMN ;
        }else{
            column = COLUMN;
        }
        for (int j = 0; j < column; j++) {
            UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(SPACE_WIDTH+(IMAGE_HEIGHT_WIDTH+20)*j, SPACE_WIDTH+(IMAGE_HEIGHT_WIDTH+20)*i, IMAGE_HEIGHT_WIDTH, IMAGE_HEIGHT_WIDTH)];
            [imageview setImage:[UIImage imageNamed:[self.img objectAtIndex:COLUMN*i+j]]];
            imageview.userInteractionEnabled = YES;
            UITapGestureRecognizer *sigleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageSeleted:)];
            [imageview addGestureRecognizer:sigleTap];
            imageview.tag = COLUMN*i+j+100;
            [self.scrollView addSubview:imageview];
        }
    }
    self.scrollView.showsVerticalScrollIndicator = NO;
//    self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width, self.view.frame.size.height - 50);
    self.scrollView.contentSize = CGSizeMake(0 ,(IMAGE_HEIGHT_WIDTH+SPACE_WIDTH)*line);
    [self.view addSubview:self.scrollView];
    
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 20, 60, 30)];
	[btnClose addTarget:self action:@selector(closeSelected:) forControlEvents:UIControlEventTouchUpInside];
	[btnClose.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [[btnClose layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[btnClose layer] setBorderWidth:1];
    [[btnClose layer] setCornerRadius:4];
	[btnClose setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	[btnClose setTitle:@"Close" forState:UIControlStateNormal];
	[self.view addSubview:btnClose];
	
	UIButton *btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 60, 30)];
	[btnDone addTarget:self action:@selector(doneSelected:) forControlEvents:UIControlEventTouchUpInside];
	[btnDone.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [[btnDone layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[btnDone layer] setBorderWidth:1];
    [[btnDone layer] setCornerRadius:4];
	[btnDone setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	[btnDone setTitle:@"Done" forState:UIControlStateNormal];
	[self.view addSubview:btnDone];
    
//    self.contentSizeForViewInPopover = CGSizeMake(250, 400);
    
}
-(void) imageSeleted:(UIGestureRecognizer *) gestureRecognizer {
    
    UIImageView * img = (UIImageView *)[gestureRecognizer view];
    UIImage *image = img.image;
    
   HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
    ImageCache * imagecache = [ImageCache sharedObject];
    ChatBackGround * chat = [[ChatBackGround alloc]init];
    if ([imagecache getFriendID]) {
        NSString * path = [[handler getPath] stringByAppendingString:@".png"];
        NSData * data =UIImageJPEGRepresentation(image, 1.0);
        [data writeToFile:path atomically:YES];
        [chat insertDB:[handler getUserID] withFriendID:[imagecache getFriendID] withImagePth:path];
//        MainController * main = [[MainController alloc]init];
//        [self.navigationController pushViewController:main animated:YES];
    }else{
        [chat deleteDB:[handler getUserID] withFriendID:[imagecache getFriendID]];
        BackData * data = [BackData sharedObject];
        [data setImage:image];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
    }];

//    MyFriendsViewController * friendVC = [[MyFriendsViewController alloc]init];
//    [self.navigationController pushViewController:friendVC animated:NO];
//    
}

- (void)closeSelected:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
    
    }];
}
-(void)doneSelected:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
    }];
}
@end

