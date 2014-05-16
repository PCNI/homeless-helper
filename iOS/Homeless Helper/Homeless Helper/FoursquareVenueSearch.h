//
//  FoursquareVenueSearch.h
//  Homeless Helper
//
//  Created by Jessi on 9/23/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebService.h"

@protocol FoursquareVenueSearchDelegate

- (void)loadSearchResults:(NSMutableArray *)venues;

@end

@interface FoursquareVenueSearch : NSObject <WebServiceDelegate>
{
    id<FoursquareVenueSearchDelegate> delegate;
}

@property (assign) id<FoursquareVenueSearchDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *venueArray;
@property (nonatomic, retain) NSString *venueId, *venueName, *venueDescription, *venueLat, *venueLong;
@property (nonatomic, retain) NSString *fullUrl;

- (void)searchVenues:(NSString *)searchString
         locationLat:(NSString *)locationLat
        locationLong:(NSString *)locationLong;

- (void)searchVenuesFinish:(NSString *)resultData;

@end