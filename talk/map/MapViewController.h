//
//  MapViewController.h
//  talk
//
//  Created by wangsh on 14-3-26.
//  Copyright (c) 2014年 wangshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol SendLocationDelegate <NSObject>

-(void)sendCurrendLocation:(NSString *)address latitude:(float)latitude longitude:(float)longitude withImage:(UIImage *)image;
@end

@interface MapViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property(nonatomic,strong)MKMapView *myMapView;

@property(nonatomic,strong)CLLocationManager *myLocationManager;

@property (nonatomic,strong) CLGeocoder *myGeoCoder;

@property (nonatomic)id <SendLocationDelegate> sendLocationDelegate;

@property (nonatomic,strong) UISearchBar * searchBar;
@end
