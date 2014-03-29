//
//  ImageViewController.m
//  RefreshDemo
//
//  Created by wangsh on 14-1-3.
//  Copyright (c) 2014年 wangsh. All rights reserved.
//

#import "ImageViewController.h"
#import "MBProgressHUD.h"
#import "MainController.h"
#import "CreateUI.h"
#import "ImageCache.h"
#import "MyToolbar.h"
#import "ImageUtil.h"
#import "ColorMatrix.h"
#import "IphoneScreen.h"

#define CLOCKBUTTON_TAG 10000
#define UNDO_TAG 1000
#define REDO_TAG 2000
#define DONE_TAG 3000
#define BRUSH_TAG 4000
#define USERPHOTO_TAG 5000
#define VIEW_TAG 6000
#define TOOLBAR_TAG 7000
//保存线条颜色
static NSMutableArray *colors;
@interface ImageViewController ()
{
    NSString * time;
    MainController * mainVC;
    CreateUI * creat;
    UIImageView *colorsImageView;
    NSData * data;
    NSArray * itemsarray;
    NSArray * donearray;
}
@end

@implementation ImageViewController
@synthesize image;
@synthesize imageSendProtocol;
@synthesize drawView;

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
    timeArray = [[NSMutableArray alloc]initWithObjects:@"",@"Never Expire",@"3s",@"4s",@"5s",@"6s",@"7s",@"8s",@"9s",@"10s", @"11s",@"12s",@"13s",@"14s",@"15s",nil];
    
    mainVC = [[MainController alloc]init];

    creat = [[CreateUI alloc]init];
    
    colors=[[NSMutableArray alloc]init];
    ImageCache * cache = [ImageCache sharedObject];
    
    //初始化颜色数组，将用到的颜色存储到数组里
    colors = [cache getBrushColor];
    if ([colors count]==0) {
        [colors addObject:[UIColor greenColor]];
    }
    UIImage *newImg = [self imageWithImageSimple:image scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    drawView = [[MyView alloc]initWithFrame:self.view.frame];
    drawView.userInteractionEnabled = YES;
    [drawView setBackgroundColor:[UIColor colorWithPatternImage:newImg]];
    [self.view sendSubviewToBack:drawView];
    currentImage = newImg;
    
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    topView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    
    UIView * colorView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-20, 90, 20, 264)];
    colorView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frameBack = CGRectMake(10, 5, 40, 40);
    [backButton setFrame:frameBack];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * brushButton = [creat setButtonFrame:CGRectMake(self.view.frame.size.width-50, 10, 32, 30) withTitle:@"nil" withImage:[UIImage imageNamed:@"brush.png"]];
    
    [brushButton addTarget:self action:@selector(paintbrushClicked) forControlEvents:UIControlEventTouchUpInside];
    brushButton.tag = BRUSH_TAG;
    [brushButton setBackgroundColor:[UIColor greenColor]];
    
    UIButton * undoButton = [creat setButtonFrame:CGRectMake(self.view.frame.size.width-130, 10, 32, 30) withTitle:@"nil" withImage:[UIImage imageNamed:@"undo.png"]];
    undoButton.hidden =YES;
    undoButton.tag=UNDO_TAG;
    [undoButton addTarget:self action:@selector(undoClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * redoButton = [creat setButtonFrame:CGRectMake(self.view.frame.size.width-90, 10, 32, 30) withTitle:@"nil" withImage:[UIImage imageNamed:@"redo.png"]];
    redoButton.hidden = YES;
    redoButton.tag=REDO_TAG;
    [redoButton addTarget:self action:@selector(redoClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [topView addSubview:backButton];
    [topView addSubview:brushButton];
    [topView addSubview:undoButton];
    [topView addSubview:redoButton];

    //colorsimageview
    colorsImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 2, 10, 260)];
    CALayer *ll = [colorsImageView layer];
    [ll setMasksToBounds:YES];
    [ll setCornerRadius:6.0];
    [colorsImageView setImage:[UIImage imageNamed:@"color.png"]];
    [colorsImageView setUserInteractionEnabled:YES];
    [colorView addSubview:colorsImageView];
    
    MyToolbar *toolBar=[[MyToolbar alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height-40,self.view.frame.size.width,40)];
    toolBar.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    toolBar.tag =TOOLBAR_TAG;
    
    UIButton *useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(260, 0, 40, 40);
    [useButton setFrame:frame];
    [useButton setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    [useButton addTarget:self action:@selector(sendStart) forControlEvents:UIControlEventTouchDown];
    [useButton addTarget:self action:@selector(sendImageClicked) forControlEvents:UIControlEventTouchUpInside];
    useButton.tag = USERPHOTO_TAG;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frameDone = CGRectMake(260, 0, 40, 40);
    [doneButton setFrame:frameDone];
    [doneButton setImage:[UIImage imageNamed:@"tick512.png"] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];
    doneButton.tag = DONE_TAG;
//    doneButton.hidden = YES;
    
    UIButton * clockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clockButton setFrame:CGRectMake(10,0, 40, 40)];
    [clockButton setBackgroundImage:[UIImage imageNamed:@"clocknew.png"] forState:UIControlStateNormal];
    clockButton .tag = CLOCKBUTTON_TAG;
    clockButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [clockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clockButton addTarget:self action:@selector(clockClicled) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:drawView];
    [self.view addSubview:topView];
    [self.view addSubview:colorView];
    UIBarButtonItem *fiexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * useitem = [[UIBarButtonItem alloc] initWithCustomView:useButton];
    UIBarButtonItem * doneitem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    UIBarButtonItem * clockitem = [[UIBarButtonItem alloc] initWithCustomView:clockButton];
    
    donearray =[[NSArray alloc]initWithObjects:clockitem,fiexibleSpace,useitem, nil];
    toolBar.items =donearray;
    itemsarray = [[NSArray alloc]initWithObjects:clockitem,fiexibleSpace,doneitem, nil];
    [self.view addSubview:toolBar];
    
    NSArray *arr = [NSArray arrayWithObjects:@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"锐色",@"淡雅",@"酒红",@"青柠",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色", nil];
    UIView * filterView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 110, self.view.frame.size.width, 64)];
    filterView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    scrollerView.backgroundColor = [UIColor clearColor];
    scrollerView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scrollerView.showsHorizontalScrollIndicator = NO;
    scrollerView.showsVerticalScrollIndicator = NO;//关闭纵向滚动条
    scrollerView.bounces = NO;
    
    float x ;
    for(int i=0;i<14;i++)
    {
        x = 10 + 51*i;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setImageStyle:)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 44, 40, 20)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:[arr objectAtIndex:i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [label setTextColor:[UIColor whiteColor]];
        [label setUserInteractionEnabled:YES];
        [label setTag:i];
        
        [scrollerView addSubview:label];
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 5, 40, 40)];
        [bgImageView setTag:i];
        [bgImageView addGestureRecognizer:recognizer];
        [bgImageView setUserInteractionEnabled:YES];
        UIImage *bgImage = [self changeImage:i imageView:bgImageView];
        bgImageView.image = bgImage;
        [scrollerView addSubview:bgImageView];
        
    }
    scrollerView.contentSize = CGSizeMake(x + 55, 60);
    [filterView addSubview:scrollerView];
    [self.view addSubview:filterView];
    
}

- (void)setImageStyle:(UITapGestureRecognizer *)sender
{
    UIImage *_image =   [self changeImage:sender.view.tag imageView:nil];
    image = _image;
    [drawView setBackgroundColor:[UIColor colorWithPatternImage:_image]];
}
-(UIImage *)changeImage:(int)index imageView:(UIImageView *)imageView
{
    UIImage *_image;
    switch (index) {
        case 0:
        {
            return currentImage;
        }
            break;
        case 1:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_lomo];
        }
            break;
        case 2:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_heibai];
        }
            break;
        case 3:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_fugu];
        }
            break;
        case 4:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_gete];
        }
            break;
        case 5:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_ruihua];
        }
            break;
        case 6:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_danya];
        }
            break;
        case 7:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_jiuhong];
        }
            break;
        case 8:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_qingning];
        }
            break;
        case 9:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_langman];
        }
            break;
        case 10:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_guangyun];
        }
            break;
        case 11:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_landiao];
            
        }
            break;
        case 12:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_menghuan];
            
        }
            break;
        case 13:
        {
            _image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_yese];
            
        }
    }
    return _image;
}

-(void)undoClicked{
    [ self.drawView revocation];
}
-(void) redoClicked{
    [ self.drawView refrom];
}
-(void)doneClicked {
    
    MyToolbar * toolBar = (MyToolbar *)[self.view viewWithTag:TOOLBAR_TAG];
    toolBar.items = donearray;
    UIGraphicsBeginImageContext(drawView.bounds.size);
    [drawView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = newImage;
    UIButton * undo =(UIButton * )[self.view viewWithTag:UNDO_TAG];
    UIButton * redo =(UIButton * )[self.view viewWithTag:REDO_TAG];
    undo.hidden = YES;
    redo.hidden = YES;
}

-(void) paintbrushClicked {
    [drawView setUserInteractionEnabled:YES];
    UIButton * undo =(UIButton * )[self.view viewWithTag:UNDO_TAG];
    UIButton * redo =(UIButton * )[self.view viewWithTag:REDO_TAG];
    UIButton * use =(UIButton * )[self.view viewWithTag:USERPHOTO_TAG];
    UIButton * done =(UIButton * )[self.view viewWithTag:DONE_TAG];
    undo.hidden = NO;
    redo.hidden = NO;
    use.hidden = YES;
    done.hidden = NO;
    NSLog(@"");
}

-(void) back {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
    }];
}
-(void) sendStart {
    
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
    
    return [self imageWithImage:image scaledToSize:newSize];
}
-(void) sendImageClicked {
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"sending photo...";
    [self.view addSubview:HUD];
    data = UIImageJPEGRepresentation(image, 1.0);
    NSInteger t = [data length]/1024;
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self setImageSendProtocol:mainVC];
        CGFloat maxWidth=self.view.frame.size.width;
        CGFloat maxheight=self.view.frame.size.height;
        if (t>100) {
            UIImage *_image = [self imageWithImage:image
                                  scaledToMaxWidth:maxWidth
                                         maxHeight:maxheight];
            data = UIImageJPEGRepresentation(_image, 0.3);
        }
        ImageCache *imageCache = [ImageCache sharedObject];
        [imageCache saveTablecontentOffset:0 withUser:[imageCache getFriendID]];
      [imageSendProtocol sendImages:data withTime:time ];
    }completionBlock:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
        [HUD removeFromSuperview];
        HUD = nil;
        
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
    lable.text = @"Expire after";
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

#pragma mark - Touch Detection -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    MyToolbar * toolBar = (MyToolbar *)[self.view viewWithTag:TOOLBAR_TAG];
    toolBar.items = itemsarray;
    UIButton * undo =(UIButton * )[self.view viewWithTag:UNDO_TAG];
    UIButton * redo =(UIButton * )[self.view viewWithTag:REDO_TAG];
    UIButton * done =(UIButton * )[self.view viewWithTag:DONE_TAG];
    UIButton * use =(UIButton * )[self.view viewWithTag:USERPHOTO_TAG];
    use.hidden = YES;
    undo.hidden = NO;
    redo.hidden=NO;
    done.hidden=NO;
    
	CGPoint locationPoint = [[touches anyObject] locationInView:colorsImageView];
    if ((locationPoint.x>0&& locationPoint.x<20)&&((locationPoint.y>0&& locationPoint.y<300))) {
        [self populateColorsForPoint:locationPoint];
    }
//    NSLog(@"x=%f,y=%f",locationPoint.x,locationPoint.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:colorsImageView];
	if ((locationPoint.x>0&& locationPoint.x<20)&&((locationPoint.y>0&& locationPoint.y<300))) {
        [self populateColorsForPoint:locationPoint];
        
    }
//     NSLog(@"x1=%f,y1=%f",locationPoint.x,locationPoint.y);
}
- (void)populateColorsForPoint:(CGPoint)point
{
    CGImageRef inImage = [UIImage imageNamed:@"color.png"].CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    UIColor *color= [[UIColor alloc]init];
    if (cgctx == NULL)
        return ;
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    unsigned char* _data = CGBitmapContextGetData (cgctx);
    
    if (_data != NULL) {
        @try {
            int offset = 4*((w*round(point.y))+round(point.x));
            ///NSLog(@"offset: %d", offset);
            int alpha =  _data[offset];
            int red = _data[offset+1];
            int green = _data[offset+2];
            int blue = _data[offset+3];
            //NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
            color  = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        }
        @catch (NSException * e) {
            //NSLog(@"%@",[e reason]);
        }
        @finally {
        }
        
    }
    CGContextRelease(cgctx);
    if (_data) { free(_data); }
    
    UIButton * brush = (UIButton *)[self.view viewWithTag:BRUSH_TAG];
    [colors addObject:color];
    [brush setBackgroundColor:color];
    ImageCache * cache = [ImageCache sharedObject];
    [cache setBrushColor:color];
    [self.drawView setLineColor:[colors count]-1];
}
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIImage*)imageWithImageSimple:(UIImage*)_image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
