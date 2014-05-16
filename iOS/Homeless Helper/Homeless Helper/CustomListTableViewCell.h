//
//  CustomListTableViewCell.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class Resource;
@class FoursquareVenueSearch;
@class GoogleAddressGeocodingSearch;

@interface CustomListTableViewCell : UITableViewCell

- (void)setResource:(Resource *)resource
         atLocation:(CLLocation *)location;

- (void)setJob:(Resource *)job;

- (void)setGig:(Resource *)gig;

- (void)setVenue:(FoursquareVenueSearch *)venue;

- (void)setAddress:(GoogleAddressGeocodingSearch *)address;

@end