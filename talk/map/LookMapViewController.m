//
//  LookMapViewController.m
//  talk
//
//  Created by wangsh on 14-3-27.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "LookMapViewController.h"

@interface LookMapViewController ()

@end

@implementation LookMapViewController

@synthesize myMapView;
@synthesize address,latitude,longitude;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) back {
    [self dismissViewControllerAnimated:NO completion:NULL];
}

-(void) dismissMap {
    [self dismissViewControllerAnimated:NO completion:NULL];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    topView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    [self.view addSubview:topView];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frameBack = CGRectMake(10, 25, 40, 40);
    [backButton setFrame:frameBack];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, self.view.frame.size.width-100, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.text = address;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:label];
    
    myMapView = [[MKMapView alloc]init];
    [myMapView setFrame:CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height-70)];
    [self.view addSubview:myMapView];
    if ([CLLocationManager locationServicesEnabled])
    {
        myMapView.mapType = MKMapTypeStandard;
        
        myMapView.delegate = self;
        myMapView.showsUserLocation =YES;
        [myMapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(latitude, longitude);
    
    float zoomLevel = 0.02;
    MKCoordinateRegion region = MKCoordinateRegionMake(coords, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [myMapView setRegion:[myMapView regionThatFits:region] animated:YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coords;
    point.title = @"当前位置";
    point.subtitle = address;//设置一些显示的信息
    [myMapView addAnnotation:point];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
