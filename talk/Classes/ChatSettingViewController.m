//
//  ChatSettingViewController.m
//  talk
//
//  Created by wangsh on 14-1-11.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "ChatSettingViewController.h"
#import "BackgroundImgViewController.h"
#import "ImageCache.h"
#import "HandlerUserIdAndDateFormater.h"
#import "TalkDB.h"

@interface ChatSettingViewController ()<UIAlertViewDelegate>
{
    NSMutableArray * userData;
}
@end

@implementation ChatSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    userData = [[NSMutableArray alloc]initWithObjects:@"SetChatBackground",@"Clear chat Data", nil];
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [userData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = [userData objectAtIndex:indexPath.row];

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==0) {
        BackgroundImgViewController * bgView = [[BackgroundImgViewController alloc]init];
        [self .navigationController pushViewController:bgView animated:NO];
    }
    if (indexPath.row ==1) {
        UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"You sure clear data?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
        view .delegate = self;
        [view show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    HandlerUserIdAndDateFormater *handler = [HandlerUserIdAndDateFormater sharedObject];
    ImageCache * imagecache = [ImageCache sharedObject];
    TalkDB * talk = [[TalkDB alloc]init];
    if (buttonIndex == 1) {
        [talk deleteDB:[handler getUserID] withOtherID:[imagecache getFriendID]];
    }
 }
@end
