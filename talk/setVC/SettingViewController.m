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
@synthesize emailText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) saveClicked {
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];

	// Do any additional setup after loading the view.
    
    isaAatarImg = NO;
    
    /*UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveClicked)];
    self.navigationItem.rightBarButtonItem = rightItem;*/
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName = [handle getUserID];
    ImageCache * imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata=[imageCache getUserMetadata:[handle getUserID]];
    NSString *email=[userMetadata objectForKey:@"Email"];
    if (!email) {
        email = @"";
    }
    userData = [[NSMutableArray alloc]initWithObjects:@"UserName",loginName,@"Email",email,@"Terms of Service",@"Privacy Policy",@"About",@"Log Out", nil];
    myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(10,0, self.view.bounds.size.width-20, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.showsVerticalScrollIndicator = NO;
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
            
        }else if (indexPath.row==1){
            cell .textLabel.text = [userData objectAtIndex:indexPath.row-1];
            cell.detailTextLabel.text = [userData objectAtIndex:indexPath.row];
        }else{
            cell.tag = indexPath.row;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell .textLabel.text = [userData objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [userData objectAtIndex:indexPath.row+1];
            emailText = [[UITextField alloc] initWithFrame:CGRectMake(100,0,160,44)];
            [emailText setBackgroundColor:[UIColor clearColor]];
            [emailText setKeyboardType:UIKeyboardTypeEmailAddress];
            emailText.delegate = self;
            [emailText setEnabled:NO];
            emailText.returnKeyType = UIReturnKeyDone;
            emailText.font = [UIFont fontWithName:@"Arial" size:15.0f];
            [cell addSubview:emailText];
        }
    }else if(indexPath.section==1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        cell .textLabel.text = [userData objectAtIndex:indexPath.row+4];
    }else if(indexPath.section==2){
        
        cell.backgroundColor = [UIColor redColor];
        UIButton * logOut = [UIButton buttonWithType:UIButtonTypeCustom];
        [logOut setFrame:CGRectMake(10,0, self.view.bounds.size.width-20, 44)];
        [logOut setTitle:@"Log Out" forState:UIControlStateNormal];
        logOut.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [logOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logOut addTarget:self action:@selector(LogOut) forControlEvents:UIControlEventTouchUpInside];
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
                UITableViewCell * cell = (UITableViewCell *)[tableView viewWithTag:indexPath.row];
                cell.detailTextLabel.text = @"";
                [emailText setEnabled:YES];
                [emailText becomeFirstResponder];
            }
        }
            break;
        case 1:{
//            UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"" message:@"You sure Exit?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
//            view .delegate = self;
//            [view show];
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
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Camera", @"Local Photo",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex ==0) {
        [self takePhoto];
    }else if (buttonIndex ==1){
        [self addPhoto];
    }
}
#pragma mark imagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    avatarImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImageView * imageview= (UIImageView *)[self.view viewWithTag:IMAGE_TAG];
    imageview.image = avatarImg;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self uploadProfileImage];
    }];
    
    
}
-(UIImage *)imageWithImage:(UIImage *)_image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [_image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)imageWithImage:(UIImage *)_image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = _image.size.width;
    CGFloat oldHeight = _image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:_image scaledToSize:newSize];
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
         isaAatarImg=NO;
     }else{
         if (buttonIndex == 1) {
             LoginViewController *loginVC = [[LoginViewController alloc]init];
             [self.navigationController pushViewController:loginVC animated:YES];
         }
     }
    
}
-(void) uploadProfileImage{
    HandlerUserIdAndDateFormater * handle =[HandlerUserIdAndDateFormater sharedObject];
    STreamUser * user = [[STreamUser alloc]init];
    STreamFile *file = [[STreamFile alloc] init];
//    CGSize size = avatarImg.size;
    UIImage *sImage = [self imageWithImage:avatarImg scaledToMaxWidth:100 maxHeight:100];
    NSData * data = UIImageJPEGRepresentation(sImage, 0.8);
    [file postData:data];
    NSLog(@"errorMessage：%@",[file errorMessage]);
    NSLog(@"ID:%@",[file fileId]);
    NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
    if ([[file errorMessage] isEqualToString:@""] && [file fileId]){
        [metaData setValue:[file fileId] forKey:@"profileImageId"];
        [user updateUserMetadata:[handle getUserID] withMetadata:metaData];
        ImageCache *imageCache = [ImageCache sharedObject];
        [imageCache saveUserMetadata:[handle getUserID] withMetadata:metaData];
    }
    [self loadAvatar:[handle getUserID]];
//    [myTableView reloadData];
}

/*-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}*/
#pragma mark UITEXTFILED-DELEGATE-
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString * email = [[textField text]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (email &&[email length]!=0) {
        HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
        ImageCache * imageCache = [ImageCache sharedObject];
        NSMutableDictionary *userMetadata=[imageCache getUserMetadata:[handle getUserID]];
        [userMetadata  setObject:email forKey:@"Email"];
        [imageCache saveUserMetadata:[handle getUserID] withMetadata:userMetadata];
        STreamUser *user = [[STreamUser alloc]init];
        [user updateUserMetadata:[handle getUserID] withMetadata:userMetadata];
        userData = [[NSMutableArray alloc]initWithObjects:@"UserName",[handle getUserID],@"Email",email,@"Terms of Service",@"Privacy Policy",@"About",@"Log Out", nil];
    }
    [textField setText:@""];
    [textField setEnabled:NO];
    [myTableView reloadData];
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
