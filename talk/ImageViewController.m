//
//  ImageViewController.m
//  RefreshDemo
//
//  Created by wangsh on 14-1-3.
//  Copyright (c) 2014年 wangsh. All rights reserved.
//

#import "ImageViewController.h"
#import "MainController.h"

#define CLOCKBUTTON_TAG 10000

@interface ImageViewController ()
{
    NSString * time;
    MainController * mainVC;
}
@end

@implementation ImageViewController
@synthesize image;
@synthesize imageSendProtocol;
@synthesize pickerController;


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
    self.navigationController.navigationBarHidden = YES;
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    timeArray = [[NSMutableArray alloc]initWithObjects:@"3s",@"4s",@"5s",@"6s",@"7s",@"8s",@"9s",@"10s", @"11s",@"12s",@"13s",@"14s",@"15s",nil];
    
    mainVC = [[MainController alloc]init];
    time = @"0s";
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(10, 26, 50, 26)];
    [[backButton layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[backButton layer] setBorderWidth:1];
    [[backButton layer] setCornerRadius:4];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * brushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [brushButton setFrame:CGRectMake(self.view.frame.size.width-50, 26, 30, 26)];
    [brushButton setImage:[UIImage imageNamed:@"brush.png"]forState:UIControlStateNormal];
    [brushButton addTarget:self action:@selector(paintbrushClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width -40, 300)];
    [imageview setImage:image];
    [self.view addSubview:imageview];
    
    UIButton * useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [useButton setFrame:CGRectMake(self.view.frame.size.width-80, self.view.frame.size.height-55, 70, 26)];
    [[useButton layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[useButton layer] setBorderWidth:1];
    [[useButton layer] setCornerRadius:4];
    [useButton setTitle:@"usePhoto" forState:UIControlStateNormal];
     useButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [useButton addTarget:self action:@selector(sendImageClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * clockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clockButton setFrame:CGRectMake(10, self.view.frame.size.height-49, 42, 25)];
    [clockButton setBackgroundImage:[UIImage imageNamed:@"clock.png"] forState:UIControlStateNormal];
    [clockButton setTitle:@"0s" forState:UIControlStateNormal];
    clockButton .tag = CLOCKBUTTON_TAG;
    clockButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [clockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clockButton addTarget:self action:@selector(clockClicled) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [self.view addSubview:imageview];
    [self.view addSubview:useButton];
    [self.view addSubview:clockButton];
    [self.view addSubview:brushButton];
}
-(void) back {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
    }];
}
-(void) sendImageClicked {
    [self setImageSendProtocol:mainVC];
    [imageSendProtocol sendImages:image withTime:time ];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [pickerController dismissViewControllerAnimated:YES completion:NULL];
        NSLog(@"back");
    }];
    [self dismissViewControllerAnimated:YES completion:^{
     [pickerController dismissViewControllerAnimated:YES completion:NULL];
        NSLog(@"back");
    }];
   
}
-(void) paintbrushClicked {
    NSLog(@"<#string#>");
}
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [timeArray count];
    
}
-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [timeArray objectAtIndex:row];
}
-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    time = [timeArray objectAtIndex:row];
    UIButton * button = (UIButton *)[self.view viewWithTag:CLOCKBUTTON_TAG];
    [button setTitle:time forState:UIControlStateNormal] ;
}
-(void) clockClicled {
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
    [button setFrame:CGRectMake(250, 10, 50,30 )];
    [button addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 200, 30)];
    lable.text = @"设置对方看几秒";
    lable.backgroundColor = [UIColor clearColor];
    [actionSheet  addSubview:lable];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
