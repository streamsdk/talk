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
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamUser.h>
#import "ImageCache.h"
#import "FileCache.h"
#import "MBProgressHUD.h"

#define IMAGE_TAG 10000
@interface SettingViewController ()
{
    UIImage *avatarImg;
    BOOL isaAatarImg;
}
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
-(void) saveClicked {
    if (avatarImg) {
        isaAatarImg = YES;
        UIAlertView * view = [[UIAlertView alloc]initWithTitle:@"" message:@"Are you sure you want to submit your avatar？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
        view .delegate = self;
        [view show];
    }else {
        UIAlertView * view = [[UIAlertView alloc]initWithTitle:@"" message:@"Please select your avatar！" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
        [view show];

    }
}

-(void) loadAvatar:(NSString *)userID {
    
    UIImageView * imageview = (UIImageView *)[self.view viewWithTag:IMAGE_TAG];
    ImageCache *imageCache = [ImageCache sharedObject];
    if ([imageCache getUserMetadata:userID]!=nil) {
        NSMutableDictionary *userMetaData = [imageCache getUserMetadata:userID];
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if ([imageCache getImage:pImageId] == nil && pImageId){
            FileCache *fileCache = [FileCache sharedObject];
            STreamFile *file = [[STreamFile alloc] init];
            if (![imageCache getImage:pImageId]){
                [file downloadAsData:pImageId downloadedData:^(NSData *imageData, NSString *oId) {
                    if ([pImageId isEqualToString:oId]){
                        [imageCache selfImageDownload:imageData withFileId:pImageId];
                        [fileCache writeFileDoc:pImageId withData:imageData];
                        imageview.image = [UIImage imageWithData: [imageCache getImage:pImageId]];
                    }
                }];
            }
        }else{
            if (pImageId) {
               imageview.image = [UIImage imageWithData: [imageCache getImage:pImageId]];
            }
        }
    }else{
        [imageview setImage:[UIImage imageNamed:@"headImage.jpg"]];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];

	// Do any additional setup after loading the view.
    
    isaAatarImg = NO;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveClicked)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    
    UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, 70, 100, 100)];
    [imageview setImage:[UIImage imageNamed:@"headImage.jpg"]];
    imageview.userInteractionEnabled = YES;
    imageview.tag = IMAGE_TAG;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headImageClicked:)];
    [imageview addGestureRecognizer:tap];
    [self.view addSubview:imageview];
   
    userData = [[NSMutableArray alloc]initWithObjects:@"UserName",loginName,@"SetChatBackground",@"Exit", nil];
    myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0,170, self.view.bounds.size.width, self.view.bounds.size.height)];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"loading friends...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadAvatar:loginName];
    }completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
    }];

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
        [self .navigationController pushViewController:bgView animated:NO];
    }
    if (indexPath.row ==2) {
        UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"You sure Exit?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
        view .delegate = self;
        [view show];
    }
}

-(void)headImageClicked:(UITapGestureRecognizer *)gestureRecognizer
{
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = NO;
	[self presentViewController:imagePickerController animated:YES completion:NULL];
}
#pragma mark imagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    avatarImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImageView * imageview= (UIImageView *)[self.view viewWithTag:IMAGE_TAG];
    imageview.image = avatarImg;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark alertview Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
     if (isaAatarImg) {
         if (buttonIndex == 1) {
             NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
             NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
             NSString * loginName= [array objectAtIndex:0];
             
             STreamUser * user = [[STreamUser alloc]init];
             STreamFile *file = [[STreamFile alloc] init];
             UIImage *sImage = [self imageWithImageSimple:avatarImg scaledToSize:CGSizeMake(avatarImg.size.width*0.3, avatarImg.size.height*0.3)];
             NSData * data = UIImageJPEGRepresentation(sImage, 1.0);
             [file postData:data];
             
             NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
             if ([[file errorMessage] isEqualToString:@""] && [file fileId]){
                 [metaData setValue:[file fileId] forKey:@"profileImageId"];
                 [user updateUserMetadata:loginName withMetadata:metaData];
                 ImageCache *imageCache = [ImageCache sharedObject];
                 [imageCache saveUserMetadata:loginName withMetadata:metaData];
                 
                 UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"save succeed!" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                 [view show];

             }
            NSLog(@"ID:%@",[file fileId]);
         }
     }else{
         if (buttonIndex == 1) {
             LoginViewController *loginVC = [[LoginViewController alloc]init];
             [self.navigationController pushViewController:loginVC animated:YES];
         }
     }
    
}


-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
