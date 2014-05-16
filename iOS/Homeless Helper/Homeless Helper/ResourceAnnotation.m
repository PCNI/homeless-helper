//
//  ResourceAnnotation.m
//  Homeless Helper
//
//  Created by Jessi on 9/20/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "ResourceAnnotation.h"

@implementation ResourceAnnotation

@synthesize title = _title;
@synthesize address = _address;

- (CLLocationCoordinate2D) coordinate
{
	CLLocationCoordinate2D coord = {self.latitude, self.longitude};
	return coord;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

- (NSString *)description
{
    return self.name;
}

@end