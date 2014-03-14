//
//  ViewController.m
//  spike
//
//  Created by wangshuai on 27/02/2014.
//  Copyright (c) 2014 wangshuai. All rights reserved.
//

#import "ViewController.h"
#import "ScannerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"generate QR code";
	// Do any additional setup after loading the view, typically from a nib.
    self.textView.text = @"generate QR code";
    [self updatePressed:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updatePressed:(id)sender {
    NSString *data = self.textView.text;
    if (data && ![data isEqualToString:@""]) {
        [self.textView resignFirstResponder];
        
        ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
        ZXBitMatrix *result = [writer encode:data format:kBarcodeFormatQRCode width:self.imageView.frame.size.width height:self.imageView.frame.size.width error:nil];
        if (result) {
            self.imageView.image = [UIImage imageWithCGImage:[ZXImage imageWithMatrix:result].cgimage];
        } else {
            self.imageView.image = nil;
        }
    }

}

- (IBAction)scanPressed:(id)sender {
    [self.textView resignFirstResponder];
    ScannerViewController * scanVC = [[ScannerViewController alloc]initWithNibName:@"ScannerViewController" bundle:nil];
    [self.navigationController pushViewController:scanVC animated:NO];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
}
@end
