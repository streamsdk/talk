//
//  SettingViewController.m
//  talk
//
//  Created by wangsh on 13-12-11.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SettingViewController.h"
#import "BackgroundImgViewController.h"
#import "HandlerUserIdAndDateFormater.h"
#import "LoginViewController.h"
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamUser.h>
#import "ImageCache.h"
#import "FileCache.h"
#import "MBProgressHUD.h"
#import "EmailViewController.h"

#define IMAGE_TAG 10000
@interface SettingViewController ()
{
    UIImage *avatarImg;
    BOOL isaAatarImg;
    UIImage *profileImage;
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
                        profileImage = [UIImage imageWithData: [imageCache getImage:pImageId]];
                    }
                }];
            }
        }else{
            if (pImageId) {
               profileImage = [UIImage imageWithData: [imageCache getImage:pImageId]];
            }else{
              profileImage = [UIImage imageNamed:@"headImage.jpg"];
            }
        }
    }else{
      profileImage= [UIImage imageNamed:@"headImage.jpg"];
    }
    
}
-(void) viewWillAppear:(BOOL)animated{
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName = [handle getUserID];
    ImageCache * imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata=[imageCache getUserMetadata:[handle getUserID]];
    NSString *email=[userMetadata objectForKey:@"Email"];
    if (!email) {
        email= @"email is null";
    }
    userData = [[NSMutableArray alloc]initWithObjects:@"UserName",loginName,@"Email",email,@"Terms of Service",@"Privacy Policy",@"About",@"Log Out", nil];
    [myTableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];

	// Do any additional setup after loading the view.
    
    isaAatarImg = NO;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveClicked)];
    self.navigationItem.rightBarButtonItem = rightItem;
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName = [handle getUserID];
   
    myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(10,0, self.view.bounds.size.width-20, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:myTableView];
    
   /* UIButton * logOut = [UIButton buttonWithType:UIButtonTypeCustom];
    [logOut setFrame:CGRectMake(10, self.view.bounds.size.height-60, self.view.bounds.size.width-20, 50)];
    [[logOut layer] setBorderColor:[[UIColor redColor] CGColor]];
    [[logOut layer] setBorderWidth:1];
    [[logOut layer] setCornerRadius:4];
    [logOut setTitle:@"Log Out" forState:UIControlStateNormal];
    logOut.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [logOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logOut setBackgroundColor:[UIColor redColor]];
    [logOut addTarget:self action:@selector(LogOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logOut];*/

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
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
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
           head = @"Basic user info";
            break;
        case 1:
            head = @"Support";
            break;
        default:
            break;
    }
    return head;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 120)/2, 0, 100, 100)];
            //    [imageview setImage:[UIImage imageNamed:@"headImage.jpg"]];
            CALayer *l = [imageview layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:CGRectGetHeight([imageview bounds]) / 2];
            [l setBorderWidth:3];
            [l setBorderColor:[[UIColor lightGrayColor]CGColor]];
            if (profileImage) {
                l.contents = (id)[profileImage CGImage];
            }else{
                l.contents = (id)[[UIImage imageNamed:@"headImage.jpg"] CGImage];
            }
            
            imageview.userInteractionEnabled = YES;
            imageview.tag = IMAGE_TAG;
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headImageClicked:)];
            [imageview addGestureRecognizer:tap];
            [cell addSubview:imageview];
//            HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
//            [self loadAvatar:[handle getUserID] withCell:cell];
        }else if (indexPath.row==1){
            cell .textLabel.text = [userData objectAtIndex:indexPath.row-1];
            cell.detailTextLabel.text = [userData objectAtIndex:indexPath.row];
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell .textLabel.text = [userData objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [userData objectAtIndex:indexPath.row+1];
        }
    }else if(indexPath.section==1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        cell .textLabel.text = [userData objectAtIndex:indexPath.row+4];
    }else if(indexPath.section==2){
        /*cell .textLabel.text = [userData objectAtIndex:indexPath.row+7];
        cell.backgroundColor = [UIColor redColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment =NSTextAlignmentRight;*/
        cell.backgroundColor = [UIColor redColor];
        UIButton * logOut = [UIButton buttonWithType:UIButtonTypeCustom];
        [logOut setFrame:CGRectMake(10,0, self.view.bounds.size.width-20, 44)];
        [logOut setTitle:@"Log Out" forState:UIControlStateNormal];
        logOut.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [logOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell addSubview:logOut];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:18.0f];

    return cell;
    

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            return 100;
        }
    }
     return 44;
  
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row==2) {
                EmailViewController *email = [[EmailViewController alloc]init];
                [self.navigationController pushViewController:email animated:YES];
            }
        }
            break;
        case 1:{
//            UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"You sure Exit?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
//            view .delegate = self;
//            [view show];
        }
            break;
        case 2:{
            UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"You sure Log Out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
            view .delegate = self;
            [view show];
        }
            break;
        default:
            break;
    }
}
-(void)LogOut{
    UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"You sure Log Out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    view .delegate = self;
    [view show];
}
-(void)addPhoto{
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = NO;
	[self presentViewController:imagePickerController animated:YES completion:NULL];
}
- (void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"该设备不支持拍照功能"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"好", nil];
        [alert show];
    }else{
        UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        [self presentViewController:imagePickerController animated:YES completion:NULL];
    }
}
-(void)headImageClicked:(UITapGestureRecognizer *)gestureRecognizer
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"---- select photo ----"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"确定"
                                  otherButtonTitles:@"Camera", @"Local Photo",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex ==1) {
        [self takePhoto];
    }else if (buttonIndex ==2){
        [self addPhoto];
    }
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
             __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
             HUD.labelText = @"uploading profileImage...";
             [self.view addSubview:HUD];
             [HUD showAnimated:YES whileExecutingBlock:^{
                 [self uploadProfileImage];
             }completionBlock:^{
                 [HUD removeFromSuperview];
                 HUD = nil;
             }];

        }
     }else{
         if (buttonIndex == 1) {
             LoginViewController *loginVC = [[LoginViewController alloc]init];
             [self.navigationController pushViewController:loginVC animated:YES];
         }
     }
    
}
-(void) uploadProfileImage{
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"userName.text"];
    NSArray * array = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSString * loginName= [array objectAtIndex:0];
    
    STreamUser * user = [[STreamUser alloc]init];
    STreamFile *file = [[STreamFile alloc] init];
    UIImage *sImage = [self imageWithImageSimple:avatarImg scaledToSize:CGSizeMake(60, 60)];
    NSData * data = UIImageJPEGRepresentation(sImage, 1.0);
    [file postData:data];
    
    NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
    if ([[file errorMessage] isEqualToString:@""] && [file fileId]){
        [metaData setValue:[file fileId] forKey:@"profileImageId"];
        [user updateUserMetadata:loginName withMetadata:metaData];
        ImageCache *imageCache = [ImageCache sharedObject];
        [imageCache saveUserMetadata:loginName withMetadata:metaData];
    }
    NSLog(@"ID:%@",[file fileId]);

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
