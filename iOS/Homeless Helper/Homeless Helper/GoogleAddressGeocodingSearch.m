//
//  GoogleAddressGeocodingSearch.m
//  Homeless Helper
//
//  Created by Jessi on 9/23/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "GoogleAddressGeocodingSearch.h"

@implementation GoogleAddressGeocodingSearch

@synthesize delegate;
@synthesize addressArray = _addressArray;
@synthesize addressName = _addressName, addressDescription = _addressDescription, addressLat = _addressLat, addressLong = _addressLong;
@synthesize fullUrl = _fullUrl;

#pragma mark -
#pragma mark ADDRESS SEARCH

- (void)searchAddresses:(NSString *)searchString
{
    // call webservice
    WebService *ws = [[WebService alloc] init];
    [ws setDelegate:self];
    
    self.fullUrl = [NSString stringWithFormat:kGoogleGeocodingURL, [searchString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.fullUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    [request setHTTPMethod:@"GET"];
    
    DLog(@"google address geocoding URL: %@", self.fullUrl);
    
    [ws callWebService:request];
    
    [ws release];
    ws = nil;
}

- (void)searchAddressesFinish:(NSString *)resultData
{
    // initialize json parser
    SBJsonParser *jsonParser = [SBJsonParser new];
    
    // convert http response json data to dictionary
    NSDictionary *dict = (NSDictionary *)[jsonParser objectWithString:resultData];
    
    NSDictionary *response = [dict valueForKey:@"results"];
    
    self.addressArray = [NSMutableArray array];
    
    // loop through all results
    for (NSDictionary *address in response) {
        
        GoogleAddressGeocodingSearch *singleAddress = [[GoogleAddressGeocodingSearch alloc] init];
        
        [singleAddress setAddressName:[address objectForKey:@"formatted_address"]];
        [singleAddress setAddressDescription:[address objectForKey:@"formatted_address"]];
        
        NSDictionary *geometry = [address objectForKey:@"geometry"];
        NSDictionary *location = [geometry objectForKey:@"location"];
        [singleAddress setAddressLat:[location objectForKey:@"lat"]];
        [singleAddress setAddressLong:[location objectForKey:@"lng"]];
        
        [self.addressArray addObject:singleAddress];
        [singleAddress release];
    }
    
    DLog(@"addressArray: %@", self.addressArray);
    
    [jsonParser release];
    
    [delegate loadSearchResults:self.addressArray];
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
    NSString *status = [dict valueForKey:@"status"];
    
    if ([status isEqualToString:@"OK"]) {
        [self searchAddressesFinish:responseString];
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
    [_addressArray release];
    [_addressName release];
    [_addressDescription release];
    [_addressLat release];
    [_addressLong release];
    [_fullUrl release];
    [super dealloc];
}

#pragma mark -
#pragma mark INFO MGMT

- (NSString *)description
{
    NSString *descriptionString = self.addressName;
    return descriptionString;
}

@end