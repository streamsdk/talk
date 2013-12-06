//
//  SignUpViewController.m
//  talk
//
//  Created by wangshuai on 13-11-12.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SignUpViewController.h"
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamObject.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import <arcstreamsdk/STreamUser.h>
#import "LoginViewController.h"
#import "CreateUI.h"

@interface SignUpViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate>
{
    UIDatePicker *datePicker;
    NSLocale *datelocale;
    UIToolbar *toolBar;
    NSArray * genderArray;
    
    UIActionSheet* actionSheet;
}
@end

@implementation SignUpViewController

@synthesize userName,password,surePassword,dateOfBirth,genderText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)selectImage{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"插入图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"系统相册",@"拍摄", nil];
    alert.delegate = self;
    [alert show];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    [bgView setImage:[UIImage imageNamed:@"background.png"]];
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];

    genderArray = [[NSArray alloc]initWithObjects:@"--选择性别--",@"男",@"女", nil];
    // 建立 UIDatePicker
    datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, -(self.view.frame.size.height), self.view.frame.size.width, 100)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    datePicker.locale = datelocale;
    datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    // 建立 UIToolbar
    toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelPicker)];
    toolBar.items = [NSArray arrayWithObject:right];
    
    CreateUI *createUI = [[CreateUI alloc]init];
    CGRect viewFrame =self.view.frame;
    CGFloat height =80;

    userName = [createUI setTextFrame:CGRectMake(20,height, viewFrame.size.width-40, 35)];
    userName.keyboardType = UIKeyboardTypeAlphabet;
    userName.delegate = self;
    userName.placeholder = @"Input User Name";
    [bgView addSubview:userName];
    
    height = height+userName.frame.size.height +10;
    password = [createUI setTextFrame:CGRectMake(20, height , viewFrame.size.width-40, 35)];
    password.keyboardType = UIKeyboardTypeAlphabet;
    [password setSecureTextEntry:YES];
    password.delegate = self;
    password.placeholder = @"input password";
    [bgView addSubview:password];
    
    height = height +password.frame.size.height+10;
    surePassword = [createUI setTextFrame:CGRectMake(20, height ,viewFrame.size.width-40, 35)];
    surePassword.keyboardType = UIKeyboardTypeAlphabet;
    [surePassword setSecureTextEntry:YES];
    surePassword.delegate = self;
    surePassword.placeholder = @"input password again";
    [bgView addSubview:surePassword];
    
    height = height +surePassword.frame.size.height+10;
    dateOfBirth = [createUI setTextFrame:CGRectMake(20, height , viewFrame.size.width-40, 35)];
    dateOfBirth.placeholder = @"input your birthday";
    dateOfBirth.inputView = datePicker;
    dateOfBirth.delegate = self;
    dateOfBirth.inputAccessoryView = toolBar;
    [bgView addSubview:dateOfBirth];
    
    height = height +dateOfBirth.frame.size.height+10;
    genderText = [createUI setTextFrame:CGRectMake(20, height , viewFrame.size.width-40, 35)];
    genderText.placeholder = @"select gender";
    [bgView addSubview:genderText];
    UIButton *genderButton = [createUI setButtonFrame:CGRectMake(20, height , viewFrame.size.width-40, 35) withTitle:@"nil"];
    [genderButton addTarget:self action:@selector(genderButton) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:genderButton];
    
    height = height +genderText.frame.size.height+30;
    UIButton *signUpButton = [createUI setButtonFrame:CGRectMake(20, height , viewFrame.size.width-40, 40) withTitle:@"SIGN UP"];
    [signUpButton addTarget:self action:@selector(signUpUser) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:signUpButton];

}
-(void )signUpUser {
    NSString *username = userName.text;
    NSString *pword = password.text;
    NSString *secondWord = surePassword.text;
    if (userName && password && [secondWord isEqualToString:secondWord]) {
        
        STreamUser *user = [[STreamUser alloc] init];
        NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
        [metaData setValue:username forKey:@"name"];
        [metaData setValue:pword forKey:@"password"];
        [metaData setValue:genderText.text forKey:@"gender"];
        [metaData setValue:dateOfBirth.text forKey:@"dateOfBirth"];
        [user signUp:userName.text withPassword:pword withMetadata:metaData];
        
        NSString *error = [user errorMessage];
        if ([error isEqualToString:@""]){
            STreamCategoryObject * sto = [[STreamCategoryObject alloc]initWithCategory:username];
            [sto createNewCategoryObject:^(BOOL succeed, NSString *response){
                
                if (succeed)
                    NSLog(@"succeed");
                else
                    NSLog(@"failed");
              }];
        }else{
            
            UIAlertView * view  = [[UIAlertView alloc]initWithTitle:@"" message:@"用户名或密码错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [view show];
        }
        LoginViewController * loginVC = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    
        NSLog(@"");
}
#pragma mark     ----pick actionsheet

-(void) genderButton{
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    UIPickerView * pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 60)] ;
    pickerView.tag = 101;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    [actionSheet addSubview:pickerView];
    
    UISegmentedControl* button = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Done",nil]];
    button.tintColor = [UIColor grayColor];
    [button setSegmentedControlStyle:UISegmentedControlStyleBar];
    [button setFrame:CGRectMake(250, 10, 50,30 )];
    [button addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:button];
    [actionSheet showInView:self.view];
    [actionSheet setBounds:CGRectMake(0, 0, 320,300)];
    [actionSheet setBackgroundColor:[UIColor whiteColor]];
}
-(void)segmentAction:(UISegmentedControl*)seg{
    NSInteger index = seg.selectedSegmentIndex;
    NSLog(@"%d",index);
    [actionSheet dismissWithClickedButtonIndex:index animated:YES];
}

#pragma mark pickView delegate

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [genderArray count];
    
}
-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [genderArray objectAtIndex:row];
}
-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    genderText.text = [genderArray objectAtIndex:row];
}

//done
-(void) cancelPicker {
    if ([self.view endEditing:NO]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd" options:0 locale:datelocale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:datelocale];
        dateOfBirth.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
