//
//  GHLocationManager.h
//  iOSGeoHelper
//
//  Created by Alexandr Kurochkin on 6/13/12.
//  Copyright (c) 2012 OneClickDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

@interface GHLocationManager : NSObject  < CLLocationManagerDelegate > {
@private
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _currentLocationCoordinate;
    NSTimer *__weak _timer;
    BOOL _isNewCoordinate;
}

@property (nonatomic, assign, readwrite) CLLocationCoordinate2D currentLocationCoordinate;
@property (nonatomic, assign, readonly) BOOL isNewCoordinate;

+ (id)sharedManager;
- (CLLocationCoordinate2D)currentDeviceLoacationCoordinate;
- (void)updateCoordinate;
 
@end
