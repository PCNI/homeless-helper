//
//  GoogleAddressGeocodingSearch.h
//  Homeless Helper
//
//  Created by Jessi on 9/23/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebService.h"

@protocol GoogleAddressGeocodingSearchDelegate

- (void)loadSearchResults:(NSMutableArray *)addresses;

@end

@interface GoogleAddressGeocodingSearch : NSObject <WebServiceDelegate>
{
    id<GoogleAddressGeocodingSearchDelegate> delegate;
}

@property (assign) id<GoogleAddressGeocodingSearchDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *addressArray;
@property (nonatomic, retain) NSString *addressName, *addressDescription, *addressLat, *addressLong;
@property (nonatomic, retain) NSString *fullUrl;

- (void)searchAddresses:(NSString *)searchString;

- (void)searchAddressesFinish:(NSString *)resultData;

@end