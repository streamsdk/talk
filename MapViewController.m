//
//  MapViewController.m
//  talk
//
//  Created by wangsh on 14-3-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import "MapViewController.h"
#import "MainController.h"
#import "MBProgressHUD.h"
@interface MapViewController ()
{
    float latitude;
    float longitude;
    __block NSString * address;
    MainController * mainVC;
    UILabel *label ;
    UIImage *snapImage;
    __block MBProgressHUD *HUD;
}
@end

@implementation MapViewController
@synthesize myMapView;
@synthesize myGeoCoder;
@synthesize myLocationManager;
@synthesize sendLocationDelegate;
@synthesize searchBar = _searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) back {
    [_searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:NO completion:NULL];
}
-(void)sendCurrentLocation {
    [HUD show:YES];
    if (!address) address = @"I am currently at...";
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = myMapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = self.myMapView.frame.size;
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        UIImage *image = snapshot.image;
        CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:address];
        UIImage *pinImage = pin.image;
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        [image drawAtPoint:CGPointMake(0, 0)];
        
        for (id<MKAnnotation>annotation in self.myMapView.annotations)
        {
            CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
            if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
            {
                CGPoint pinCenterOffset = pin.centerOffset;
                point.x -= pin.bounds.size.width / 2.0;
                point.y -= pin.bounds.size.height / 2.0;
                point.x += pinCenterOffset.x;
                point.y += pinCenterOffset.y;
                
                [pinImage drawAtPoint:point];
            }
        }
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
//        NSData *data = UIImageJPEGRepresentation(finalImage, 0.1);
//        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil);
        snapImage = [self imageWithImage:finalImage scaledToMaxWidth:90 maxHeight:100];
        NSData *data = UIImageJPEGRepresentation(snapImage, 0.8);
        snapImage =[UIImage imageWithData:data];
        [self performSelectorInBackground:@selector(dismissMap) withObject:nil];
    }];
}
-(void) dismissMap {
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self setSendLocationDelegate:mainVC];
        [sendLocationDelegate sendCurrendLocation:address latitude:latitude longitude:longitude  withImage:snapImage];
    }completionBlock:^{
        [self dismissViewControllerAnimated:NO completion:NULL];
        [HUD removeFromSuperview];
        HUD = nil;
        
    }];
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
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, self.view.frame.size.width-100, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.text = address;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:label];

    myMapView = [[MKMapView alloc]init];
    [myMapView setFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100)];
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
    
    self.myLocationManager = [[CLLocationManager alloc] init];
    self.myLocationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.myLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.myLocationManager requestWhenInUseAuthorization];
    }
    [self.myLocationManager startUpdatingLocation];
    
    myGeoCoder = [[CLGeocoder alloc]init];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"sending...";
    [self.view addSubview:HUD];
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 40)];
    _searchBar.delegate = self;
    _searchBar.barStyle=UIBarStyleDefault;
    _searchBar.placeholder=@"search";
    _searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self.view addSubview:_searchBar];
   
}
-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 3000, 3000);
    [myMapView setRegion:[myMapView regionThatFits:viewRegion] animated:YES];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = userLocation.coordinate;
    point.title = @"Click To Send";
    point.subtitle = @"";
    [myMapView addAnnotation:point];
    latitude = userLocation.location.coordinate.latitude;
    longitude =userLocation.location.coordinate.longitude;
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
                             point.title = @"Click To Send";
                             point.subtitle = locatedAt;
                             [myMapView selectAnnotation:point animated:YES];
                         }else{
//                             dispatch_async(dispatch_get_main_queue(), ^{
//                                 UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Error" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
//                                 [alert show];
//                             });
                         }
                         
                     }];
}
#pragma mark searchBarDelegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *oreillyAddress = searchBar.text;
    myGeoCoder = [[CLGeocoder alloc] init];
    [myGeoCoder geocodeAddressString:oreillyAddress completionHandler:^(NSArray*placemarks, NSError *error) {
        
        if ([placemarks count] > 0 && error == nil){
            NSLog(@"Found %lu placemark(s).", (unsigned long)[placemarks count]);
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            NSLog(@"Longitude = %f", firstPlacemark.location.coordinate.longitude);
            NSLog(@"Latitude = %f", firstPlacemark.location.coordinate.latitude);
            latitude=firstPlacemark.location.coordinate.latitude;
            longitude =firstPlacemark.location.coordinate.longitude;
            address=oreillyAddress;
            CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(latitude,longitude);
            
            float zoomLevel = 0.02;
            MKCoordinateRegion region = MKCoordinateRegionMake(coords, MKCoordinateSpanMake(zoomLevel, zoomLevel));
            [myMapView setRegion:[myMapView regionThatFits:region] animated:YES];
            
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = coords;
            point.title = @"Click To Send";
            point.subtitle = oreillyAddress;
            [myMapView addAnnotation:point];
            label.text = oreillyAddress;
            [myMapView selectAnnotation:point animated:YES];
        }else if ([placemarks count] == 0 &&
                 error == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Error" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                [alert show];
            });
            NSLog(@"Found no placemarks.");
        }else if (error != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Error" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
                 [alert show];
            });
            NSLog(@"An error occurred = %@", error);
        }
    }];
    

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_searchBar resignFirstResponder];
}
#pragma mark mapView --delegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"PIN_ANNOTATION"];
    if(annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                         reuseIdentifier:@"PIN_ANNOTATION"] ;
    }
    annotationView.canShowCallout=YES;
    annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.animatesDrop = YES;
    annotationView.highlighted = YES;
    annotationView.annotation = annotation;
    annotationView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tappressGesutre=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendCurrentLocation)];
    tappressGesutre.numberOfTouchesRequired=1;
    [annotationView addGestureRecognizer:tappressGesutre];
    return annotationView;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark image scaled
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

@end
