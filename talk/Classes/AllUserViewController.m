//
//  AllUserViewController.m
//  talk
//
//  Created by wangshuai on 13-11-13.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "AllUserViewController.h"
#import "MainController.h"

@interface AllUserViewController ()
{
    NSMutableArray * userArray;
}
@end

@implementation AllUserViewController

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
    userArray = [[NSMutableArray alloc]initWithObjects:@"test1",@"test2",@"test3",@"test4",@"test5",@"test6",@"test7",@"test8",@"test9", nil];
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * userID = [array objectAtIndex:0];
    for(NSString * name in userArray) {
        if ([name isEqualToString:userID]) {
            [userArray removeObject:name];
            break;
        }
    }
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [userArray objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MainController *mainVC = [[MainController alloc]init];
    NSString *userName = [userArray objectAtIndex:indexPath.row];
    [mainVC setSendToID:userName];
    [self.navigationController pushViewController:mainVC animated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
