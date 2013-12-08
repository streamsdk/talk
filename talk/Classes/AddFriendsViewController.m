//
//  AddFriendsViewController.m
//  talk
//
//  Created by wangsh on 13-12-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "MBProgressHUD.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import "MyFriendsViewController.h"

@interface AddFriendsViewController ()

@end

@implementation AddFriendsViewController
@synthesize myTableview,userData;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) loadFriends {
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    STreamQuery  * sq = [[STreamQuery alloc]initWithCategory:loginName];
    userData = [sq find];

}
-(void) back{
    MyFriendsViewController * myFriendsVC = [[MyFriendsViewController alloc]init];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController pushViewController:myFriendsVC animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Add Friends";
    self .navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftitem = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftitem;
    userData = [[NSArray alloc]init];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    myTableview  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-49)];
    myTableview.backgroundColor = [UIColor clearColor];
    myTableview.delegate = self;
    myTableview.dataSource = self;
    [self.view addSubview:myTableview];
    
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"loading friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadFriends];
    }completionBlock:^{
        [myTableview reloadData];
        [HUD removeFromSuperview];
        HUD = nil;
    }];
  
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userData count];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    UIButton * button;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = indexPath.row;
        [button setFrame:CGRectMake(cell.frame.size.width-60, 2, 40, 40)];
        [cell addSubview:button];
    }
    STreamObject * so = [userData objectAtIndex:indexPath.row];
    NSString *status = [so getValue:@"status"];
    if ([status isEqualToString:@"friend"]) {
        [button setImage:[UIImage imageNamed:@"delete.png"]forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteFriends:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [button setImage:[UIImage imageNamed:@"addBtn.png"]forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];

    }
    cell.textLabel.text = [so objectId];
     cell.textLabel.font = [UIFont fontWithName:@"Arial" size:22.0f];
    return cell;

}
-(void)deleteFriends:(UIButton *)sender {
    
    STreamObject * so = [userData objectAtIndex:sender.tag];
    [so setObjectId:[so objectId]];
    [so deleteObjectInBackground];
    
    
}
-(void)addFriends:(UIButton *)sender {
    [sender setImage:[UIImage imageNamed:@"delete.png"]forState:UIControlStateNormal];
    STreamObject * so = [userData objectAtIndex:sender.tag];
    [so setObjectId:[so objectId]];
    [so addStaff:@"status" withObject:@"friend"];
    [so updateInBackground];
    STreamCategoryObject *sco = [[STreamCategoryObject alloc]initWithCategory:[so objectId]];
    STreamObject *my = [[STreamObject alloc]init];
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    [my setObjectId:loginName];
    [my addStaff:@"status" withObject:@"friend"];
    NSMutableArray *updateArray = [[NSMutableArray alloc] init] ;

    [updateArray addObject:my];
    [sco updateStreamCategoryObjects:updateArray];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
