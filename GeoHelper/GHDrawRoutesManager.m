//
//  DrawRoutesManager.m
//
//  Created by Alex Kurochkin on 8/19/13.
//  Copyright (c) 2013 Alex Kurochkin. All rights reserved.
//

#import "GHDrawRoutesManager.h"
#import "RegexKitLite.h"


@interface GHDrawRoutesManager ()

@property (nonatomic, strong, readwrite) MKPolyline *objPolyline;
@property (nonatomic, strong, readwrite) NSArray *arrayPoints;

@end

@implementation GHDrawRoutesManager

#pragma mark -
#pragma mark - initialization
#pragma mark -

@synthesize objPolyline;
@synthesize fillColor;
@synthesize strokeColor;
@synthesize arrayPoints;
@synthesize width;
//@synthesize distanceAtMeters;

static GHDrawRoutesManager *sharedInstance = nil;

+ (instancetype)sharedManager {
    if (sharedInstance == nil) {
		sharedInstance = [[self alloc] init];
	}
	return sharedInstance;

}



#pragma mark -
#pragma mark - interface
#pragma mark -

- (MKPolylineView *)routePolylineView {
    MKPolylineView *view = [[MKPolylineView alloc] initWithPolyline:self.objPolyline];
    view.fillColor = (self.fillColor) ? self.fillColor : [UIColor blueColor];
    view.strokeColor = (self.strokeColor) ? self.strokeColor : [UIColor blueColor];
    view.lineWidth = (width > 0) ? width : 4;
    return view;
}

- (void)drawRoutFromPoint:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination onMapView:(MKMapView *)mapView {
     self.arrayPoints = [self getRoutePointFrom:origin to:destination];
    [self drawRoute:self.arrayPoints onTheMapView:mapView];
}

- (void)centerMapView:(MKMapView *)mapView {
    [self centerMap:mapView forRoutePoints:self.arrayPoints];
}

#pragma mark -
#pragma mark - Calcultions of the Routes
#pragma mark - 

- (NSArray*)getRoutePointFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination {
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError *error;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

- (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedString {
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [encodedString length])];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithDouble:lng * 1e-5];
        printf("\n[%f,", [latitude doubleValue]);
        printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

- (double)metrsOfCurrentDistanceFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)destination {
    
    if (!self.arrayPoints) {
        self.arrayPoints = [self getRoutePointFrom:origin to:destination];
    }
    
    double returnDistance = 0;
    for (int i = 0; i < [self.arrayPoints count]-1; i++) {
        CLLocation* first = (self.arrayPoints)[i];
        CLLocation* second = (self.arrayPoints)[(i+1)];
        CLLocationDistance distance = [first distanceFromLocation:second];
        returnDistance += distance;
    }
    return returnDistance;
}


#pragma mark -
#pragma mark - Drawing on the map
#pragma mark -

- (void)drawRoute:(NSArray *)arrRoutePoints onTheMapView:(MKMapView *)mapView {
    
    int numPoints = [arrRoutePoints count];
    if (numPoints > 1) {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++) {
            CLLocation* current = arrRoutePoints[i];
            coords[i] = current.coordinate;
        }
        
        self.objPolyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        [mapView addOverlay:objPolyline];
        [mapView setNeedsDisplay];
    }
}

- (void)centerMap:(MKMapView *)mapView forRoutePoints:(NSArray *)arrRoutePoints {
    MKCoordinateRegion region;
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int idx = 0; idx < arrRoutePoints.count; idx++)
    {
        CLLocation* currentLocation = arrRoutePoints[idx];
        
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    [mapView setRegion:region animated:YES];
}

@end
