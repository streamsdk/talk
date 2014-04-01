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
#import <arcstreamsdk/STreamObject.h>
@interface StatusViewController ()
{
   
    UITableViewCell * currentStatusCell;
}
@end

@implementation StatusViewController
@synthesize statusArray,myTableView;
@synthesize status=_status;;
@synthesize row;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    row = 0;
    
    HandlerUserIdAndDateFormater * handle =[HandlerUserIdAndDateFormater sharedObject];
    MyStatusDB * db = [[MyStatusDB alloc]init];
    statusArray = [db readStatus:[handle getUserID]];
    _status = [statusArray objectAtIndex:0];
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
        cell .textLabel.text = [statusArray objectAtIndex:row];
        currentStatusCell = cell;
    }else if(indexPath.section==1){
        if (row == indexPath.row)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        cell .textLabel.text = [statusArray objectAtIndex:indexPath.row];
    }
    
    return cell;
    
    
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        EditStatusViewController * editStatusVC =[[EditStatusViewController alloc]init];
        [editStatusVC setStatus:_status];
        [self.navigationController pushViewController:editStatusVC animated:NO];
    }else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if(indexPath.row==row){
            return;
        }
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:row
                                                       inSection:indexPath.section];
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        if (newCell.accessoryType == UITableViewCellAccessoryNone) {
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        row=indexPath.row;
        _status = [statusArray objectAtIndex:indexPath.row];
        currentStatusCell.textLabel.text = @"";
        currentStatusCell.textLabel.text = _status;
        HandlerUserIdAndDateFormater * handle =[HandlerUserIdAndDateFormater sharedObject];
        MyStatusDB * db = [[MyStatusDB alloc]init];
        [db insertStatus:_status withUser:[handle getUserID]];
        STreamObject * so = [[STreamObject alloc]init];
        NSMutableString *userid = [[NSMutableString alloc] init];
        [userid appendString:[handle getUserID]];
        [userid appendString:@"status"];
        [so setObjectId:userid];
        [so addStaff:@"status" withObject:_status];
        [so updateInBackground];

    }
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
       return UITableViewCellAccessoryDisclosureIndicator;
    }else {
        if(indexPath.row==row){
            return UITableViewCellAccessoryCheckmark;
        }
        else{
            return UITableViewCellAccessoryNone;
        }
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
