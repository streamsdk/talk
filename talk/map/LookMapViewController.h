//
//  LookMapViewController.h
//  talk
//
//  Created by wangsh on 14-3-27.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LookMapViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>

@property(nonatomic,strong)MKMapView *myMapView;

@property (nonatomic,retain) NSString * address;

@property (nonatomic,assign) float latitude;

@property (nonatomic,assign) float longitude;
@end
