//
//  RCViewController.h
//  RoutesCalculating
//
//  Created by Alex Kurochkin on 8/20/13.
//  Copyright (c) 2013 Alex Kurochkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

@interface GHViewController : UIViewController < MKMapViewDelegate >

@property (nonatomic, strong, readwrite) IBOutlet MKMapView *mapView;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *distanceLabel;

- (IBAction)tapAction:(UITapGestureRecognizer *)sender;

@end
