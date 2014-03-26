//
//  MapViewController.m
//  talk
//
//  Created by wangsh on 14-3-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize myMapView;
@synthesize myGeoCoder;
@synthesize myLocationManager;

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
    
    myLocationManager = [[CLLocationManager alloc] init];
	[myLocationManager setDelegate:self];
	[myLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[myLocationManager startUpdatingLocation];
    myGeoCoder = [[CLGeocoder alloc]init];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%d", [locations count]);
    CLLocation *currentLocation = [locations lastObject];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 3000, 3000);
   [myMapView setRegion:[myMapView regionThatFits:viewRegion] animated:YES];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = currentLocation.coordinate;
    point.title = @"当前位置";
    point.subtitle = @"";//设置一些显示的信息
    [myMapView addAnnotation:point];
    manager.delegate = nil;
    [manager stopUpdatingLocation];
    /*[myGeoCoder reverseGeocodeLocation:currentLocation
                     completionHandler:^(NSArray *placemarks, NSError *error){
                         if (error==nil) {
                             CLPlacemark *placemark= [placemarks lastObject];
//                             NSDictionary *dict = placemark.addressDictionary;
                             //                         NSLog(@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",placemark.name,placemark.thoroughfare,placemark.subThoroughfare,placemark.locality,placemark.subLocality,placemark.administrativeArea,placemark.subAdministrativeArea,placemark.postalCode,placemark.ISOcountryCode,placemark.country,placemark.inlandWater,placemark.ocean,placemark.areasOfInterest);
                             point.title = @"当前位置";
                             point.subtitle = placemark.name;
                         }else{
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Error" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                                 [alert show];
                             });
                         }
                         
                     }];*/
    

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
