//
//  MapViewController.m
//  talk
//
//  Created by wangsh on 14-3-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "MapViewController.h"
#import "MainController.h"

@interface MapViewController ()
{
    float latitude;
    float longitude;
    __block NSString * address;
    MainController * mainVC;
    UILabel *label ;
}
@end

@implementation MapViewController
@synthesize myMapView;
@synthesize myGeoCoder;
@synthesize myLocationManager;
@synthesize sendLocationDelegate;

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
-(void)sendCurrentLocation {
    [self setSendLocationDelegate:mainVC];
    [sendLocationDelegate sendCurrendLocation:address latitude:latitude longitude:longitude];
    [self performSelectorInBackground:@selector(dismissMap) withObject:nil];
    
}
-(void) dismissMap {
    [self dismissViewControllerAnimated:NO completion:NULL];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    mainVC = [[MainController alloc]init];
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
    //forward.png
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(self.view.frame.size.width-50, 25, 40, 40)];
    [sendButton setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:sendButton];
    label = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, self.view.frame.size.width-100, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.text = address;
    label.font = [UIFont systemFontOfSize:12];
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
    
//    myLocationManager = [[CLLocationManager alloc] init];
//	[myLocationManager setDelegate:self];
//	[myLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
//	[myLocationManager startUpdatingLocation];
    myGeoCoder = [[CLGeocoder alloc]init];
}
-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 3000, 3000);
    [myMapView setRegion:[myMapView regionThatFits:viewRegion] animated:YES];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = userLocation.coordinate;
    point.title = @"当前位置";
    point.subtitle = @"";//设置一些显示的信息
    [myMapView addAnnotation:point];
    latitude = userLocation.location.coordinate.latitude;
    longitude =userLocation.location.coordinate.longitude;
    NSLog(@"latitude=%f,longitude= %f",latitude,longitude);
//    mapView.showsUserLocation = NO;
    [myGeoCoder reverseGeocodeLocation:userLocation.location
                     completionHandler:^(NSArray *placemarks, NSError *error){
                         if (error==nil) {
                             CLPlacemark *placemark= [placemarks lastObject];
                             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                             address = locatedAt;
                             if (address) {
                                 mapView.showsUserLocation = NO;
                                 label.text = address;
                             }
                             NSLog(@"I am currently at %@",locatedAt);
//                             NSDictionary *dict = placemark.addressDictionary;
//                             NSLog(@"1%@,2%@,3%@,4%@,5%@,6%@,7%@,8%@,9%@,10%@,11%@,12%@,13%@",placemark.name,placemark.thoroughfare,placemark.subThoroughfare,placemark.locality,placemark.subLocality,placemark.administrativeArea,placemark.subAdministrativeArea,placemark.postalCode,placemark.ISOcountryCode,placemark.country,placemark.inlandWater,placemark.ocean,placemark.areasOfInterest);
                             point.title = @"当前位置";
                             point.subtitle = locatedAt;
                         }else{
//                             dispatch_async(dispatch_get_main_queue(), ^{
//                                 UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Error" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
//                                 [alert show];
//                             });
                         }
                         
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
