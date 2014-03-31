//
//  StatusViewController.m
//  talk
//
//  Created by wangsh on 14-3-28.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "StatusViewController.h"
#import "EditStatusViewController.h"
#import "MyStatusDB.h"
#import "HandlerUserIdAndDateFormater.h"
@interface StatusViewController ()

@end

@implementation StatusViewController
@synthesize statusArray,myTableView;
@synthesize status;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{

    HandlerUserIdAndDateFormater * handle =[HandlerUserIdAndDateFormater sharedObject];
    MyStatusDB * db = [[MyStatusDB alloc]init];
    statusArray = [db readStatus:[handle getUserID]];
    [myTableView reloadData];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    self.title = @"Status";
	statusArray = [[NSMutableArray alloc]init];
    myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(10,0, self.view.bounds.size.width-20, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:myTableView];
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [statusArray count];
            break;
        default:
            break;
    }
    return 0;
    //    return [userData count]-1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* head=nil;
    switch (section) {
        case 0:
            head = @"YOUR CURRENT STATUS IS:";
            break;
        case 1:
            head = @"SELECT YOUR NEW STATUS";
            break;
       
        default:
            break;
    }
    return head;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section==0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell .textLabel.text = [statusArray objectAtIndex:indexPath.row];
    }else if(indexPath.section==1){
        if (indexPath.row ==0) {
            UIButton *_selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_selectButton setFrame:CGRectMake(cell.frame.size.width-50, 5, 30, 30)];
            [_selectButton setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
            [cell .contentView addSubview:_selectButton];
        }
        cell .textLabel.text = [statusArray objectAtIndex:indexPath.row];
    }
    
    return cell;
    
    
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        EditStatusViewController * editStatusVC =[[EditStatusViewController alloc]init];
        [editStatusVC setStatus:[statusArray objectAtIndex:indexPath.section]];
        [self.navigationController pushViewController:editStatusVC animated:NO];
    }else {
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
