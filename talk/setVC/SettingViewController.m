//
//  SettingViewController.m
//  talk
//
//  Created by wangsh on 13-12-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SettingViewController.h"
#import "BackgroundImgViewController.h"
#import "LoginViewController.h"
@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize myTableView;
@synthesize userData;

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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];

	// Do any additional setup after loading the view.
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    userData = [[NSMutableArray alloc]initWithObjects:@"UserName",loginName,@"SetChatBackground",@"Exit", nil];
    myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [userData count]-1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        if (indexPath.row!=0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    if (indexPath.row==0) {
        cell .textLabel.text = [userData objectAtIndex:indexPath.row];
         cell.detailTextLabel.text = [userData objectAtIndex:indexPath.row+1];
        
    }else{
        cell .textLabel.text = [userData objectAtIndex:indexPath.row+1];

    }
   
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:18.0f];

    return cell;
    

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==1) {
        BackgroundImgViewController * bgView = [[BackgroundImgViewController alloc]init];
//        bgView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//        [self presentViewController:bgView animated:YES completion:nil];
        [self .navigationController pushViewController:bgView animated:NO];
    }
    if (indexPath.row ==2) {
        UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"You sure Exit?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
        view .delegate = self;
        [view show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
