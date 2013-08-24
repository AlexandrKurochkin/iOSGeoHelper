//
//  RCAnnotationModel.h
//  RCRoutesCalculating
//
//  Created by Alex Kurochkin on 8/24/13.
//  Copyright (c) 2013 Alex Kurochkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface GHAnnotationModel : NSObject < MKAnnotation >

@property (nonatomic, assign, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readwrite) NSString *title;

@end
