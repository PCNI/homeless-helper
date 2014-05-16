//
//  MapLocation.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapLocation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c;

@end