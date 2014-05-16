//
//  ResourceAnnotation.h
//  Homeless Helper
//
//  Created by Jessi on 9/20/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ResourceAnnotation : NSObject <MKAnnotation>
{
    
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int tag;

@end