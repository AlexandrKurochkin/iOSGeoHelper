//
//  RCViewController.m
//  RoutesCalculating
//
//  Created by Alex Kurochkin on 8/20/13.
//  Copyright (c) 2013 Alex Kurochkin. All rights reserved.
//

#import "GHViewController.h"
#import "GHDrawRoutesManager.h"
#import "GHAnnotationModel.h"
#import "GHLocationManager.h"

@interface GHViewController ()
@property (nonatomic, strong, readwrite) GHAnnotationModel *currentAnnotationModel;
@end

@implementation GHViewController

@synthesize mapView, distanceLabel, currentAnnotationModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [[GHLocationManager sharedManager] currentDeviceLoacationCoordinate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.mapView.delegate = nil;
}

#pragma mark -
#pragma mark - MapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation) {
        NSLog(@"viewForAnnotation");
        
        static NSString *annotationIdentifier = @"AnnotationIdentifier";
        
        MKPinAnnotationView *pinView = (MKPinAnnotationView *) [mapView
                                                                dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc]
                       initWithAnnotation:annotation
                       reuseIdentifier:annotationIdentifier];
            
            [pinView setPinColor:MKPinAnnotationColorGreen];
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
        } else {
            pinView.annotation = annotation;
        }        
    } else {
        [self.mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}

- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay {
    return [[GHDrawRoutesManager sharedManager] routePolylineView];
}


- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    
    [self.mapView removeAnnotation:self.currentAnnotationModel];
    [self.mapView removeOverlays:[self.mapView overlays]];
    
    CLLocationCoordinate2D currentCoord = [[GHLocationManager sharedManager] currentDeviceLoacationCoordinate];
    CLLocationCoordinate2D distanceCoord = [self.mapView convertPoint:[sender locationInView:self.view] toCoordinateFromView:self.view];

    self.currentAnnotationModel = [GHAnnotationModel new];
    self.currentAnnotationModel .coordinate = distanceCoord;
	[self.mapView addAnnotation:self.currentAnnotationModel ];
    
    [[GHDrawRoutesManager sharedManager] drawRoutFromPoint:currentCoord to:distanceCoord onMapView:self.mapView];
    [[GHDrawRoutesManager sharedManager] centerMapView:self.mapView];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%lf km", [[GHDrawRoutesManager sharedManager] metrsOfCurrentDistanceFrom:currentCoord to:distanceCoord]/1000.0];
}

@end
