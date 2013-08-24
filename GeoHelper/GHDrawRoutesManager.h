//
//  GHDrawRoutesManager.h
//  iOSGeoHelper
//  Created by Alex Kurochkin on 8/19/13.
//  Copyright (c) 2013 Alex Kurochkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

@interface GHDrawRoutesManager : NSObject

@property (nonatomic, strong, readwrite) UIColor *fillColor;
@property (nonatomic, strong, readwrite) UIColor *strokeColor;
@property (nonatomic, assign, readwrite) CGFloat width;
//@property (nonatomic, assign, readwrite) double distanceAtMeters;

+ (instancetype)sharedManager;

- (void)drawRoutFromPoint:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination onMapView:(MKMapView *)mapView;
- (void)centerMapView:(MKMapView *)mapView;
- (MKPolylineView *)routePolylineView;
- (double)metrsOfCurrentDistanceFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination;


@end
