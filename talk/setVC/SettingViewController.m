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
#import "TearmServiceViewController.h"
#import "PrivacyPoolicyViewController.h"
#import <MessageUI/MessageUI.h>
#import<MessageUI/MFMailComposeViewController.h>
#import "STreamXMPP.h"
#import "DownloadAvatar.h"
#import "MyQRCodeViewController.h"
#import "ScannerViewController.h"
#import "StatusViewController.h"
#define IMAGE_TAG 10000
#import "MyStatusDB.h"
@interface SettingViewController ()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    UIImage *avatarImg;
    BOOL isaAatarImg;
    UIImage *profileImage;
    NSString * status;
    NSString *email;
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
        if (pImageId!=nil && ![pImageId isEqualToString:@""] &&[imageCache getImage:pImageId]==nil){
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
            if (pImageId!=nil && ![pImageId isEqualToString:@""]) {
               profileImage = [UIImage imageWithData: [imageCache getImage:pImageId]];
            }else{
              profileImage = [UIImage imageNamed:@"noavatar.png"];
            }
        }
    }else{
      profileImage= [UIImage imageNamed:@"noavatar.png"];
    }
    
}
-(void) viewWillAppear:(BOOL)animated{
    HandlerUserIdAndDateFormater * handle =[HandlerUserIdAndDateFormater sharedObject];
    MyStatusDB * db = [[MyStatusDB alloc]init];
    NSMutableArray* statusArray = [db readStatus:[handle getUserID]];
    if ([statusArray count]!=0 && statusArray) {
        status = [statusArray objectAtIndex:0];
    }else{
        status = @"Hey,there! I am using CoolChat!";
        [db insertStatus:status withUser:[handle getUserID]];
    }
    
    ImageCache * imageCache = [ImageCache sharedObject];
    NSMutableDictionary *userMetadata=[imageCache getUserMetadata:[handle getUserID]];
    email=[userMetadata objectForKey:@"Email"];
    if (!email) {
        email = @"";
    }
     userData = [[NSMutableArray alloc]initWithObjects:@"UserName",[handle getUserID],@"status",status,@"Email",email,@"My QRCode",@"Scanner QRCode",@"Invite by SMS",@"Invite by Mail",@"Terms of Service",@"Privacy Policy",@"Log Out", nil];
    if (!isaAatarImg) [myTableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    isaAatarImg = NO;
    HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
    NSString * loginName = [handle getUserID];
    /*STreamObject * so = [[STreamObject alloc]init];
    NSMutableString *userid = [[NSMutableString alloc] init];
    [userid appendString:[handle getUserID]];
    [userid appendString:@"status"];
    [so setObjectId:userid];
    [so loadAll:userid];
    [so getObject:userid response:^(NSString * res) {
        status =[so getValue:@"status"];
        if (!status) status =@"Hey there! I am using CoolChat!";
        MyStatusDB *db= [[MyStatusDB alloc]init];
        [db insertStatus:status withUser:[handle getUserID]];
    }];*/
    myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(10,0, self.view.bounds.size.width-20, self.view.bounds.size.height-30) style:UITableViewStyleGrouped];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:myTableView];

    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0,self.view.bounds.size.height-30, self.view.frame.size.width, 30)];
    [label setBackgroundColor:[UIColor blackColor]];
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont fontWithName:@"Arial" size:15.0f];
    label.textColor = [UIColor whiteColor];
    label.text= @"CoolChat messenger V1.0";
    [self.view addSubview:label];
    DownloadAvatar * loadavatar = [[DownloadAvatar alloc]init];
    profileImage = [loadavatar readAvatar:loginName];
    [myTableView reloadData];
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 1;
            break;
        case 5:
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
            head = @"QR Code";
            break;
        case 2:
            head = @"Invite to CoolChat";
            break;
        case 3:
            head = @"About";
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
        if (indexPath.row==0) {
            UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 120)/2, 0, 100, 100)];
            CALayer *l = [imageview layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:CGRectGetHeight([imageview bounds]) / 2];
            [l setBorderWidth:3];
            [l setBorderColor:[[UIColor lightGrayColor]CGColor]];   
            if (profileImage) {
                l.contents = (id)[profileImage CGImage];
            }else{
                l.contents = (id)[[UIImage imageNamed:@"noavatar.png"] CGImage];
            }
            
            imageview.userInteractionEnabled = YES;
            imageview.tag = IMAGE_TAG;
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headImageClicked:)];
            [imageview addGestureRecognizer:tap];
            [cell addSubview:imageview];
            
        }else if (indexPath.row==1){
            cell .textLabel.text = [userData objectAtIndex:indexPath.row-1];
            cell.detailTextLabel.text = [userData objectAtIndex:indexPath.row];
        }else if (indexPath.row==2){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell .textLabel.text = [userData objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [userData objectAtIndex:indexPath.row+1];
        }else if (indexPath.row==3){
            cell.tag = indexPath.row;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell .textLabel.text = [userData objectAtIndex:indexPath.row+1];
            cell.detailTextLabel.text = [userData objectAtIndex:indexPath.row+2];
            emailText = [[UITextField alloc] initWithFrame:CGRectMake(100,0,160,44)];
            [emailText setBackgroundColor:[UIColor clearColor]];
            [emailText setKeyboardType:UIKeyboardTypeEmailAddress];
            emailText.autocapitalizationType = UITextAutocapitalizationTypeNone;
            emailText.delegate = self;
            [emailText setEnabled:NO];
            emailText.returnKeyType = UIReturnKeyDone;
            emailText.font = [UIFont fontWithName:@"Arial" size:15.0f];
            [cell addSubview:emailText];
        }
    }else if(indexPath.section==1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        cell .textLabel.text = [userData objectAtIndex:indexPath.row+6];
    }else if(indexPath.section==2){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell .textLabel.text = [userData objectAtIndex:indexPath.row+8];
    }else if(indexPath.section==3){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell .textLabel.text = [userData objectAtIndex:indexPath.row+10];
    }else if(indexPath.section==4){
        
        cell.backgroundColor = [UIColor redColor];
        UIButton * logOut = [UIButton buttonWithType:UIButtonTypeCustom];
        [logOut setFrame:CGRectMake(0,0, cell.contentView.frame.size.width-20, 44)];
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
                StatusViewController * statusVC =[[StatusViewController alloc]init];
                [statusVC setStatus:status];
                [self.navigationController pushViewController:statusVC animated:NO];
            }else  if (indexPath.row==3) {
                UITableViewCell * cell = (UITableViewCell *)[tableView viewWithTag:indexPath.row];
                cell.detailTextLabel.text = @"";
                [emailText setEnabled:YES];
                [emailText becomeFirstResponder];
            }
        }
            break;
        case 1:{
            if (indexPath.row == 0) {
                MyQRCodeViewController *myQRCodeView = [[MyQRCodeViewController alloc]init];
                [self.navigationController pushViewController:myQRCodeView animated:NO];
                
            }
            if (indexPath.row == 1) {
                ScannerViewController *scannerView = [[ScannerViewController alloc]init];
//                [[[[[UIApplication sharedApplication]delegate]window]rootViewController]presentViewController:scannerView animated:NO completion:NULL];
//                [self.navigationController pushViewController:scannerView animated:NO];
                [self.navigationController presentViewController:scannerView animated:NO completion:NULL];
            }
        }
            break;
            
        case 2:{
            if (indexPath.row == 0) {
                
                Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
                
                if (messageClass != nil) {
                    if ([messageClass canSendText]) {
                        [self displaySMSComposerSheet];
                    }else {
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""message:@"设备不支持短信功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                    }
                }
             }
             if (indexPath.row ==1) {
                 Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
                 if (mailClass !=nil) {
                     if ([mailClass canSendMail]) {
                         [self displayMailComposerSheet];
                     }else{
                         UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""message:@"设备不支持邮件功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                         [alert show];;
                     }
                 }
             }
        }
            break;

        case 3:{
          if (indexPath.row == 0) {
                TearmServiceViewController * tearm = [[TearmServiceViewController alloc]init];
                [self.navigationController pushViewController:tearm animated:YES];
            }
            if (indexPath.row ==1) {
                PrivacyPoolicyViewController *privacy = [[PrivacyPoolicyViewController alloc] init];
                [self.navigationController pushViewController:privacy animated:YES];
            }
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
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Camera", @"Local Photo",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    isaAatarImg = YES;
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
        
        __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.labelText = @"uploadLoading...";
        [self.view addSubview:HUD];
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self uploadProfileImage];
        }completionBlock:^{
            [HUD removeFromSuperview];
            HUD = nil;
            isaAatarImg = NO;
        }];
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
    if (buttonIndex == 1) {
        __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.labelText = @"log out...";
        [self.view addSubview:HUD];
        [HUD showAnimated:YES whileExecutingBlock:^{
            STreamXMPP * con = [STreamXMPP sharedObject];
            [con disconnect];
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *username = [userDefaults objectForKey:@"username"];
            if (username) {
                NSDate *now = [[NSDate alloc] init];
                long long millionsSecs = [now timeIntervalSince1970];
                NSString *time = [NSString stringWithFormat:@"%lld",millionsSecs];
                STreamObject * so = [[STreamObject alloc]init];
                NSMutableString *userid = [[NSMutableString alloc] init];
                [userid appendString:username];
                [userid appendString:@"status"];
                [so setObjectId:userid];
                [so addStaff:@"lastseen" withObject:time];
                [so addStaff:@"online" withObject:@"NO"];
                [so updateInBackground];
                
            }
            [userDefaults removeObjectForKey:@"username"];
            [userDefaults removeObjectForKey:@"password"];
           
        }completionBlock:^{
            LoginViewController *loginVC = [[LoginViewController alloc]init];
            [UIView animateWithDuration:0.01
                             animations:^{
                                 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                                 [self.navigationController pushViewController:loginVC animated:NO];
                                 [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
                             }];
            [HUD removeFromSuperview];
            HUD = nil;
        }];        
    }
    
}
-(void) uploadProfileImage{
    HandlerUserIdAndDateFormater * handle =[HandlerUserIdAndDateFormater sharedObject];
    STreamUser * user = [[STreamUser alloc]init];
    STreamFile *file = [[STreamFile alloc] init];

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
}

#pragma mark UITEXTFILED-DELEGATE-
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString * _email = [[textField text]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_email &&[_email length]!=0) {
        HandlerUserIdAndDateFormater * handle = [HandlerUserIdAndDateFormater sharedObject];
        ImageCache * imageCache = [ImageCache sharedObject];
        NSMutableDictionary *userMetadata=[imageCache getUserMetadata:[handle getUserID]];
        [userMetadata  setObject:_email forKey:@"Email"];
        [imageCache saveUserMetadata:[handle getUserID] withMetadata:userMetadata];
        STreamUser *user = [[STreamUser alloc]init];
        [user updateUserMetadata:[handle getUserID] withMetadata:userMetadata];
        email = _email;
        userData = [[NSMutableArray alloc]initWithObjects:@"UserName",[handle getUserID],@"status",status,@"Email",_email,@"My QRCode",@"Scanner QRCode",@"Invite by SMS",@"Invite by Mail",@"Terms of Service",@"Privacy Policy",@"Log Out", nil];
    }
    [textField setText:@""];
    [textField setEnabled:NO];
    [myTableView reloadData];
    [textField resignFirstResponder];
    return YES;
}
-(void)displayMailComposerSheet
{
    HandlerUserIdAndDateFormater *handle = [HandlerUserIdAndDateFormater sharedObject];

    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
    picker.mailComposeDelegate =self;
    [picker setSubject:@"文件分享"];
    NSString *emailBody =[NSString stringWithFormat:@"I am using CoolChat now. Download CoolChat from apple store or google play store. My user name is %@. Add me as friend",[handle getUserID]] ;
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)displaySMSComposerSheet
{
    HandlerUserIdAndDateFormater *handle = [HandlerUserIdAndDateFormater sharedObject];
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate =self;
    NSString *smsBody =[NSString stringWithFormat:@"I am using CoolChat now. Download CoolChat from apple store or google play store. My user name is %@. Add me as friend",[handle getUserID]] ;
    picker.body=smsBody;
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result)
    {
        caseMFMailComposeResultCancelled:
            NSLog(@"Result: Mail sending canceled");
            break;
        caseMFMailComposeResultSaved:
            NSLog(@"Result: Mail saved");
            break;
        caseMFMailComposeResultSent:
            NSLog(@"Result: Mail sent");
            break;
        caseMFMailComposeResultFailed:
            NSLog(@"Result: Mail sending failed");
            break;
        default:
            NSLog(@"Result: Mail not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result)
    {
        caseMFMailComposeResultCancelled:
            NSLog(@"Result: message sending canceled");
            break;
        caseMFMailComposeResultSaved:
            NSLog(@"Result: message saved");
            break;
        caseMFMailComposeResultSent:
            NSLog(@"Result: message sent");
            break;
        caseMFMailComposeResultFailed:
            NSLog(@"Result: message sending failed");
            break;
        default:
            NSLog(@"Result: message not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
