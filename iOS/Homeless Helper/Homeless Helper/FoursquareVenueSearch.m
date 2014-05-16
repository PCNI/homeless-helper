//
//  FoursquareVenueSearch.m
//  Homeless Helper
//
//  Created by Jessi on 9/23/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "FoursquareVenueSearch.h"

@implementation FoursquareVenueSearch

@synthesize delegate;
@synthesize venueArray = _venueArray;
@synthesize venueId = _venueId, venueName = _venueName, venueDescription = _venueDescription, venueLat = _venueLat, venueLong = _venueLong;
@synthesize fullUrl = _fullUrl;

#pragma mark -
#pragma mark SEARCH VENUES

- (void)searchVenues:(NSString *)searchString
         locationLat:(NSString *)locationLat
        locationLong:(NSString *)locationLong
{
    // call webservice
    WebService *ws = [[WebService alloc] init];
    [ws setDelegate:self];
    
    self.fullUrl = [NSString stringWithFormat:kFoursquareVenueSearchURL, kFoursquareClientID, kFoursquareClientSecret, [locationLat stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [locationLong stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [searchString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.fullUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    [request setHTTPMethod:@"GET"];
    
    DLog(@"foursquare venue search URL: %@", self.fullUrl);
    
    [ws callWebService:request];
    
    [ws release];
    ws = nil;
}

- (void)searchVenuesFinish:(NSString *)resultData
{
    // initialize json parser
    SBJsonParser *jsonParser = [SBJsonParser new];
    
    // convert http response json data to dictionary
    NSDictionary *dict = (NSDictionary *)[jsonParser objectWithString:resultData];
    
    NSDictionary *response = [dict valueForKey:@"response"];
    NSDictionary *venues = [response valueForKey:@"venues"];
    
    self.venueArray = [NSMutableArray array];
    
    // loop through all results
    for (NSDictionary *venue in venues) {
        
        FoursquareVenueSearch *singleVenue = [[FoursquareVenueSearch alloc] init];
        
        [singleVenue setVenueId:[venue objectForKey:@"id"]];
        [singleVenue setVenueName:[venue objectForKey:@"name"]];
        NSDictionary *location = [venue objectForKey:@"location"];
        NSString *addressString = [NSMutableString stringWithFormat:@"%@, %@", [location objectForKey:@"address"], [location objectForKey:@"city"]];
        NSString *addressString2 = [addressString stringByReplacingOccurrencesOfString:@"(null), " withString:@""];
        NSString *addressString3 = [addressString2 stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        
        [singleVenue setVenueDescription:addressString3];
        [singleVenue setVenueLat:[location objectForKey:@"lat"]];
        [singleVenue setVenueLong:[location objectForKey:@"lng"]];
        
        [self.venueArray addObject:singleVenue];
        [singleVenue release];
    }
    
    DLog(@"venueArray: %@", self.venueArray);
    
    [jsonParser release];
    
    [delegate loadSearchResults:self.venueArray];
}

#pragma mark -
#pragma mark WEBSERVICE

- (void)webServiceCallFinished:(NSMutableData *)responseData
{
    // get http response data
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    // initialize json parser
    SBJsonParser *jsonParser = [SBJsonParser new];
    
    // convert http response json data to dictionary
    NSDictionary *dict = (NSDictionary *)[jsonParser objectWithString:responseString];
    DLog(@"API response dict: %@", dict);
    NSString *meta = [dict valueForKey:@"meta"];
    NSString *code = [[meta valueForKey:@"code"] stringValue];
    
    if ([code isEqualToString:@"200"]) {
        [self searchVenuesFinish:responseString];
    }
    
    [jsonParser release];
    [responseString release];
}

#pragma mark -
#pragma mark APP MGMT

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [_venueArray release];
    [_venueId release];
    [_venueName release];
    [_venueDescription release];
    [_venueLat release];
    [_venueLong release];
    [_fullUrl release];
    [super dealloc];
}

#pragma mark -
#pragma mark INFO MGMT

- (NSString *)description
{
    NSString *descriptionString = self.venueName;
    return descriptionString;
}

@end