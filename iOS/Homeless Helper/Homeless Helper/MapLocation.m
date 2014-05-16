//
//  MapLocation.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "MapLocation.h"

@implementation MapLocation
@synthesize coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c
{
    self = [super init];
    if (self) {
        coordinate = c;
    }
    return self;
}

@end