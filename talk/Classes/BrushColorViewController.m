//
//  BrushColorViewController.m
//  talk
//
//  Created by wangsh on 14-1-13.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "BrushColorViewController.h"
#import "ImageCache.h"

@interface BrushColorViewController ()
{
    UIColor * color;
}
@end

@implementation BrushColorViewController

@synthesize textColor;
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	color = [[UIColor alloc]init];
	UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 60, 30)];
	[btnClose addTarget:self action:@selector(closeSelected:) forControlEvents:UIControlEventTouchUpInside];
	[btnClose.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
	[btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[btnClose setTitle:@"Close" forState:UIControlStateNormal];
	[self.view addSubview:btnClose];
	
	UIButton *btnDone = [[UIButton alloc] initWithFrame:CGRectMake(65, 5, 60, 30)];
	[btnDone addTarget:self action:@selector(doneSelected:) forControlEvents:UIControlEventTouchUpInside];
	[btnDone.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
	[btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[btnDone setTitle:@"Done" forState:UIControlStateNormal];
	[self.view addSubview:btnDone];
	
	self.selectedColorView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 35 - 5, 5, 35, 30)];
	self.selectedColorView.backgroundColor = [UIColor blackColor];
	self.selectedColorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.selectedColorView.layer.borderWidth = 1;
	self.selectedColorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[self.view addSubview:self.selectedColorView];
	
	self.colorsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colors.jpg"]];;
	self.colorsImageView.frame = CGRectMake(2, 40, self.view.frame.size.width-4, self.view.frame.size.height - 40 - 2);
	self.colorsImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.colorsImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.colorsImageView.layer.borderWidth = 1;
	[self.view addSubview:self.colorsImageView];
	
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolbar];
    
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(doneSelected:)];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(closeSelected:)];
    
    UIBarButtonItem *selectedColorItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectedColorView];
    
    [toolbar setItems:@[doneItem, selectedColorItem, flexibleSpaceItem , closeItem]];
    [self.view addSubview:toolbar];
    
    self.colorsImageView.frame = CGRectMake(2, 46, self.view.frame.size.width-4, self.view.frame.size.height - 46 - 2);
    
    self.contentSizeForViewInPopover = CGSizeMake(300, 240);
}

#pragma mark - Private Methods -

- (void)populateColorsForPoint:(CGPoint)point
{
    CGImageRef inImage = [UIImage imageNamed:@"colors.jpg"].CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL)
        return ;
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    unsigned char* data = CGBitmapContextGetData (cgctx);

    if (data != NULL) {
        @try {
            int offset = 4*((w*round(point.y))+round(point.x));
            NSLog(@"offset: %d", offset);
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
            color  = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        }
        @catch (NSException * e) {
            NSLog(@"%@",[e reason]);
        }
        @finally {
        }
        
    }
    CGContextRelease(cgctx);
    if (data) { free(data); }

	self.selectedColorView.backgroundColor = color;
    
    
    
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
#pragma mark - IBActions -

- (void)doneSelected:(id)sender
{
    ImageCache * cache =[ImageCache sharedObject];
    if (color) {
        [cache setBrushColor:color];
    }
    
	[self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
    }];
}

- (void)closeSelected:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"back");
        
    }];
}

#pragma mark - Touch Detection -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.colorsImageView];
	[self populateColorsForPoint:locationPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.colorsImageView];
	[self populateColorsForPoint:locationPoint];
}

@end
