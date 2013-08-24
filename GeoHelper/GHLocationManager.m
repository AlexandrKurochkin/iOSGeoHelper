//
//  LocationManager.m
//  VisitNordsjaelland
//
//  Created by Alexandr Kurochkin on 6/13/12.
//  Copyright (c) 2012 OneClickDev. All rights reserved.
//

#import "GHLocationManager.h"

@interface GHLocationManager ()
@property (nonatomic, strong, readwrite) CLLocationManager *locationManager;
@property (nonatomic, weak, readwrite) NSTimer *timer;
@property (nonatomic, assign, readwrite) BOOL isNewCoordinate;
@end

@implementation GHLocationManager

@synthesize locationManager = _locationManager;
@synthesize currentLocationCoordinate = _currentLocationCoordinate;
@synthesize timer = _timer;
@synthesize isNewCoordinate = _isNewCoordinate;

static GHLocationManager *sharedInstance = nil;

+ (id)sharedManager {
	if (sharedInstance == nil) {
		sharedInstance = [[self alloc] init];
	}
	return sharedInstance;
}

- (id)init {
	self = [super init];
	if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 100; // 0,1 kilometer
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                        target:self 
                                                      selector:@selector(updateCoordinate) 
                                                      userInfo:nil 
                                                       repeats:YES];
        self.isNewCoordinate = NO;
        
	}
	return self;
}

- (void)dealloc {
    self.timer = nil;
    [self.locationManager stopUpdatingLocation];
}


- (CLLocationCoordinate2D)currentDeviceLoacationCoordinate {
    return self.currentLocationCoordinate;
}

- (void)updateCoordinate {
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    self.currentLocationCoordinate = newLocation.coordinate;
    [manager stopUpdatingLocation];
    self.isNewCoordinate = YES;
    //DLog(@"new current location");
}



@end
