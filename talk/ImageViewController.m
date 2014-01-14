//
//  ImageViewController.m
//  RefreshDemo
//
//  Created by wangsh on 14-1-3.
//  Copyright (c) 2014年 wangsh. All rights reserved.
//

#import "ImageViewController.h"
#import "MainController.h"
#import "CreateUI.h"
#import "BrushColorViewController.h"
#import "ImageCache.h"

#define CLOCKBUTTON_TAG 10000
#define UNDO_TAG 1000
#define REDO_TAG 2000
#define DONE_TAG 3000
#define BRUSH_TAG 4000
#define USERPHOTO_TAG 5000
#define VIEW_TAG 6000
//保存线条颜色
static NSMutableArray *colors;
@interface ImageViewController ()
{
    NSString * time;
    MainController * mainVC;
    CreateUI * creat;
}
@end

@implementation ImageViewController
@synthesize image;
@synthesize imageSendProtocol;
@synthesize pickerController;
@synthesize drawView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    ImageCache * cache = [ImageCache sharedObject];
    UIButton * brush =(UIButton * )[self.view viewWithTag:BRUSH_TAG];
    [self.drawView setLineColor:[[cache getBrushColor] count]-1];
    brush.backgroundColor=[[cache getBrushColor]lastObject];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self.view setBackgroundColor:[UIColor blackColor]];
    timeArray = [[NSMutableArray alloc]initWithObjects:@"",@"永久保存",@"3s",@"4s",@"5s",@"6s",@"7s",@"8s",@"9s",@"10s", @"11s",@"12s",@"13s",@"14s",@"15s",nil];
    
    mainVC = [[MainController alloc]init];

    creat = [[CreateUI alloc]init];
    
    colors=[[NSMutableArray alloc]init];
    ImageCache * cache = [ImageCache sharedObject];
    
    //初始化颜色数组，将用到的颜色存储到数组里
    colors = [cache getBrushColor];
    if ([colors count]==0) {
        [colors addObject:[UIColor greenColor]];
    }
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frameBack = CGRectMake(10, 26, 32, 32);
    [backButton setFrame:frameBack];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];

    
    
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * brushButton = [creat setButtonFrame:CGRectMake(self.view.frame.size.width-50, 26, 30, 26) withTitle:@"nil" withImage:[UIImage imageNamed:@"brush.png"]];
    
    [brushButton addTarget:self action:@selector(paintbrushClicked) forControlEvents:UIControlEventTouchUpInside];
    brushButton.tag = BRUSH_TAG;
    [brushButton setBackgroundColor:[UIColor greenColor]];
    
    UIButton * undoButton = [creat setButtonFrame:CGRectMake(self.view.frame.size.width-130, 26, 30, 26) withTitle:@"nil" withImage:[UIImage imageNamed:@"undo.png"]];
    undoButton.hidden =YES;
    undoButton.tag=UNDO_TAG;
    [undoButton addTarget:self action:@selector(undoClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * redoButton = [creat setButtonFrame:CGRectMake(self.view.frame.size.width-90, 26, 30, 26) withTitle:@"nil" withImage:[UIImage imageNamed:@"redo.png"]];
    redoButton.hidden = YES;
    redoButton.tag=REDO_TAG;
    [redoButton addTarget:self action:@selector(redoClicked) forControlEvents:UIControlEventTouchUpInside];
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-120, 58, 100, 8)];
    v.tag = VIEW_TAG;
    v.hidden = YES;
    CALayer *l = [v layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:2.0];
    v.backgroundColor = [UIColor clearColor];
     [self.view addSubview:v];
    for (int i=0; i<1; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setFrame:CGRectMake(10*i, 0, 10, 8)];
         btn.tag = i;
        [btn setBackgroundColor:[colors objectAtIndex:i]];
        [btn addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:btn];
    }
   
    drawView = [[MyView alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width -40, 300)];
    drawView.userInteractionEnabled = YES;
    UIImage * newImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(self.view.frame.size.width -40, 300)];
    [drawView setBackgroundColor:[UIColor colorWithPatternImage:newImage]];
    [self.view addSubview:drawView];
    [self.view sendSubviewToBack:drawView];
    
    UIButton *useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(self.view.frame.size.width-53, self.view.frame.size.height-47, 32, 32);
    [useButton setFrame:frame];
    [useButton setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    [useButton addTarget:self action:@selector(sendImageClicked) forControlEvents:UIControlEventTouchUpInside];
    useButton.tag = USERPHOTO_TAG;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frameDone = CGRectMake(self.view.frame.size.width-53, self.view.frame.size.height-56, 45, 45);
    [doneButton setFrame:frameDone];
    [doneButton setImage:[UIImage imageNamed:@"tick512.png"] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];
    doneButton.tag = DONE_TAG;
    doneButton.hidden = YES;
    
    UIButton * clockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clockButton setFrame:CGRectMake(10, self.view.frame.size.height-49, 32, 32)];
    [clockButton setBackgroundImage:[UIImage imageNamed:@"clocknew.png"] forState:UIControlStateNormal];
    clockButton .tag = CLOCKBUTTON_TAG;
    clockButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [clockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clockButton addTarget:self action:@selector(clockClicled) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backButton];
    [self.view addSubview:drawView];
    [self.view addSubview:useButton];
    [self.view addSubview:clockButton];
    [self.view addSubview:undoButton];
    [self.view addSubview:redoButton];
    [self.view addSubview:brushButton];
    [self.view addSubview:doneButton];
}
-(void)setColor:(id)sender {
    
}
-(void)undoClicked{
    [ self.drawView revocation];
}
-(void) redoClicked{
    [ self.drawView refrom];
}
-(void)doneClicked {
    
    UIGraphicsBeginImageContext(drawView.bounds.size);
    [drawView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil);
    drawView.userInteractionEnabled = NO;
    image = newImage;

    drawView.userInteractionEnabled = NO;
    UIButton * undo =(UIButton * )[self.view viewWithTag:UNDO_TAG];
    UIButton * redo =(UIButton * )[self.view viewWithTag:REDO_TAG];
    UIButton * use =(UIButton * )[self.view viewWithTag:USERPHOTO_TAG];
    UIButton * done =(UIButton * )[self.view viewWithTag:DONE_TAG];
    UIView *v =(UIView *)[self.view viewWithTag:VIEW_TAG];
    v.hidden = YES;
    undo.hidden = YES;
    redo.hidden = YES;
    use.hidden = NO;
    done.hidden = YES;
}

-(void) paintbrushClicked {
    UIButton * undo =(UIButton * )[self.view viewWithTag:UNDO_TAG];
    UIButton * redo =(UIButton * )[self.view viewWithTag:REDO_TAG];
    UIButton * use =(UIButton * )[self.view viewWithTag:USERPHOTO_TAG];
    UIButton * done =(UIButton * )[self.view viewWithTag:DONE_TAG];
//    UIView *v =(UIView *)[self.view viewWithTag:VIEW_TAG];
//    v.hidden = NO;
//    UIButton * brush =(UIButton * )[self.view viewWithTag:BRUSH_TAG];
//    [brush addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchUpInside];
    BrushColorViewController  *colorVC = [[BrushColorViewController alloc]init];
    colorVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    colorVC.textColor = @"fontcolor";
    [self presentViewController:colorVC animated:YES completion:nil];
    undo.hidden = NO;
    redo.hidden = NO;
    use.hidden = YES;
    done.hidden = NO;
    
    NSLog(@"<#string#>");
}

-(void) back {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
    }];
}
-(void) sendImageClicked {
    [self setImageSendProtocol:mainVC];
    
    UIGraphicsBeginImageContext(drawView.bounds.size);
    [drawView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //    UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil);
    drawView.userInteractionEnabled = NO;
    image = newImage;
    [imageSendProtocol sendImages:image withTime:time ];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [pickerController dismissViewControllerAnimated:YES completion:NULL];
       
    }];
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
    UIButton * button = (UIButton *)[self.view viewWithTag:CLOCKBUTTON_TAG];
    if (row<2) {
        [button setTitle:@"" forState:UIControlStateNormal] ;
    }else{
        time = [timeArray objectAtIndex:row];
        
        [button setBackgroundImage:[UIImage imageNamed:@"clockselect.png"] forState:UIControlStateNormal];
        [button setTitle:time forState:UIControlStateNormal] ;
    }
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

-(UIImage*)imageWithImageSimple:(UIImage*)_image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UIButton * undo =(UIButton * )[self.view viewWithTag:UNDO_TAG];
    UIButton * redo =(UIButton * )[self.view viewWithTag:REDO_TAG];
    undo.hidden = NO;
    redo.hidden=NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
