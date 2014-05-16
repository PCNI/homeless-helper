//
//  Resource.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/26/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "Resource.h"

@implementation Resource

@synthesize delegate;

@synthesize resourceId = _resourceId, lastUpdated = _lastUpdated, resourceType = _resourceType, adminCode = _adminCode, vaStatus = _vaStatus, name1 = _name1, name2 = _name2, street1 = _street1, street2 = _street2, city = _city, state = _state, zipcode = _zipcode, locationLat = _locationLat, locationLong = _locationLong, phone = _phone, url = _url, hours = _hours, notes = _notes, emailAddress = _emailAddress, opportunityType = _opportunityType;
@synthesize beds = _beds;
@synthesize locationCoords = _locationCoords;
@synthesize annotation = _annotation;

@synthesize resourcesArray = _resourcesArray;
@synthesize fullUrl = _fullUrl;

#pragma mark -
#pragma mark RESOURCES/LIST

- (void)listResourcesForCategory:(NSString *)category
                    withLatitude:(NSString *)latitude
                    andLongitude:(NSString *)longitude
{
    // call webservice
    WebService *ws = [[WebService alloc] init];
    [ws setDelegate:self];
    
    NSString *encodedCategory = (NSString *)[EncodedString URLEncodedString:category];
    NSString *encodedLatString = (NSString *)[EncodedString URLEncodedString:latitude];
    NSString *encodedLongString = (NSString *)[EncodedString URLEncodedString:longitude];

#ifdef RELEASE
    self.fullUrl = [NSString stringWithFormat:kHomelessHelperListResourcesURL, kHomelessHelperBaseURL, encodedCategory, encodedLatString, encodedLongString];
#endif
    
#ifndef RELEASE
    self.fullUrl = [NSString stringWithFormat:kHomelessHelperListResourcesURL, kHomelessHelperDevURL, encodedCategory, encodedLatString, encodedLongString];
#endif
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.fullUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    [request setHTTPMethod:@"GET"];
    
    DLog(@"resources/list URL: %@", self.fullUrl);
    
    [ws callWebService:request];
    
    [ws release];
    ws = nil;
}

- (void)listResourcesFinish:(NSDictionary *)resultData
{    
    NSDictionary *response = [resultData valueForKey:@"response"];
    
    self.resourcesArray = [NSMutableArray array];
    
    // loop through all results
    for (NSDictionary *resource in response) {
        
        Resource *singleResource = [[Resource alloc] init];
        
        [singleResource setResourceId:[resource objectForKey:@"resource_id"]];
        [singleResource setLastUpdated:[resource objectForKey:@"last_updated"]];
        [singleResource setResourceType:[resource objectForKey:@"resource_type"]];
        [singleResource setAdminCode:[resource objectForKey:@"admin_code"]];
        [singleResource setBeds:[resource objectForKey:@"beds"]];
        [singleResource setVaStatus:[resource objectForKey:@"va_status"]];
        [singleResource setName1:[resource objectForKey:@"name_1"]];
        [singleResource setName2:[resource objectForKey:@"name_2"]];
        [singleResource setStreet1:[resource objectForKey:@"street_1"]];
        [singleResource setStreet2:[resource objectForKey:@"street_2"]];
        [singleResource setCity:[resource objectForKey:@"city"]];
        [singleResource setState:[resource objectForKey:@"state"]];
        [singleResource setZipcode:[resource objectForKey:@"zipcode"]];
        [singleResource setLocationCoords:[resource objectForKey:@"location"]];
        [singleResource setLocationLat:[[[singleResource locationCoords] objectAtIndex:0] stringValue]];
        [singleResource setLocationLong:[[[singleResource locationCoords] objectAtIndex:1] stringValue]];
        [singleResource setPhone:[resource objectForKey:@"phone"]];
        [singleResource setUrl:[resource objectForKey:@"url"]];
        [singleResource setHours:[resource objectForKey:@"hours"]];
        [singleResource setNotes:[resource objectForKey:@"notes"]];
        [singleResource setEmailAddress:[resource objectForKey:@"email_address"]];
        [singleResource setOpportunityType:[resource objectForKey:@"opp_type"]];
        
        if ([[singleResource resourceType] isEqualToString:@"job_gig"]) {
            [singleResource setName1:[resource objectForKey:@"title"]];
            [singleResource setStreet1:[resource objectForKey:@"address"]];
            [singleResource setNotes:[resource objectForKey:@"description"]];
            [singleResource setEmailAddress:[resource objectForKey:@"email"]];
        }
        
        ResourceAnnotation *singleAnnotation = [[ResourceAnnotation alloc] init];
        [singleAnnotation setLatitude:[singleResource.locationLat doubleValue]];
        [singleAnnotation setLongitude:[singleResource.locationLong doubleValue]];
        [singleAnnotation setName:singleResource.name1];
        [singleAnnotation setAddress:[NSString stringWithFormat:@"%@, %@", singleResource.street1, singleResource.city]];
        
        [singleResource setAnnotation:singleAnnotation];
        [singleAnnotation release];
        
        [self.resourcesArray addObject:singleResource];
        [singleResource release];
    }
    
    DLog(@"resourcesArray: %@", self.resourcesArray);
    
    [delegate listResourcesActionFinish:self.resourcesArray];
}

#pragma mark -
#pragma mark RESOURCE/SHARE

- (void)shareResourceWithResourceId:(NSString *)resId
                            forKind:(NSString *)kind
                    withDestination:(NSString *)destination
{
    // call webservice
    WebService *ws = [[WebService alloc] init];
    [ws setDelegate:self];
    
    NSString *encodedResourceId = (NSString *)[EncodedString URLEncodedString:resId];
    NSString *encodedKind = (NSString *)[EncodedString URLEncodedString:kind];
    NSString *encodedDestination = (NSString *)[EncodedString URLEncodedString:destination];
    
#ifdef RELEASE
    self.fullUrl = [NSString stringWithFormat:kHomelessHelperShareResourceURL, kHomelessHelperBaseURL, encodedResourceId, encodedKind, encodedDestination];
#endif
    
#ifndef RELEASE
    self.fullUrl = [NSString stringWithFormat:kHomelessHelperShareResourceURL, kHomelessHelperDevURL, encodedResourceId, encodedKind, encodedDestination];
#endif
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.fullUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    [request setHTTPMethod:@"POST"];
    
    DLog(@"resource/share URL: %@", self.fullUrl);
    
    [ws callWebService:request];
    
    [ws release];
    ws = nil;
}

- (void)shareResourceFinish:(NSDictionary *)resultData
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Listing Shared" message:@"This listing has been shared successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
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
    
    if (dict == nil) {
        return;
    } else {
        // check for method identifier (api returns the method name)
        NSString *apiMethod = [meta valueForKey:@"method_name"];
        NSString *status = [meta valueForKey:@"status"];
        DLog(@"status: %@", status);
        
        if (![status isEqualToString:@"OK"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occurred" message:@"Something went wrong!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
            if ([apiMethod isEqualToString:@"/resource/list"]) {
                [self listResourcesFinish:dict];
            } else if ([apiMethod isEqualToString:@"/resource/share"]) {
                [self shareResourceFinish:dict];
            }
        }
    }
    
    [jsonParser release];
    [responseString release];
}

#pragma mark -
#pragma mark INFO MGMT

- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", self.name1, self.street1, self.city, self.state, self.zipcode];
    return descriptionString;
}

#pragma mark -
#pragma mark APP MGMT

- (void)dealloc
{
    [_resourceId release];
    [_lastUpdated release];
    [_resourceType release];
    [_adminCode release];
    [_vaStatus release];
    [_name1 release];
    [_name2 release];
    [_street1 release];
    [_street2 release];
    [_city release];
    [_state release];
    [_zipcode release];
    [_locationLat release];
    [_locationLong release];
    [_locationCoords release];
    [_annotation release];
    [_phone release];
    [_url release];
    [_hours release];
    [_notes release];
    [_emailAddress release];
    [_opportunityType release];
    [_beds release];
    [_resourcesArray release];
    [_fullUrl release];
    [super dealloc];
}

@end