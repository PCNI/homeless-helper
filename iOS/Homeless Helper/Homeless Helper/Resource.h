//
//  Resource.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/26/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebService.h"
#import "EncodedString.h"
#import "ResourceAnnotation.h"

@protocol ResourceDelegate

@optional
- (void)listResourcesActionFinish:(NSMutableArray *)resourcesArray;
- (void)shareResourceActionFinish;

@end

@interface Resource : NSObject <WebServiceDelegate>
{
    id<ResourceDelegate> delegate;
}

@property (assign) id<ResourceDelegate> delegate;

@property (nonatomic, retain) NSString *resourceId, *lastUpdated, *resourceType, *adminCode, *vaStatus, *name1, *name2, *street1, *street2, *city, *state, *zipcode, *locationLat, *locationLong, *phone, *url, *hours, *notes, *emailAddress, *opportunityType;
@property (nonatomic, retain) NSNumber *beds;
@property (nonatomic, retain) NSArray *locationCoords;
@property (nonatomic, retain) ResourceAnnotation *annotation;

@property (nonatomic, retain) NSMutableArray *resourcesArray;

@property (nonatomic, retain) NSString *fullUrl;

- (void)listResourcesForCategory:(NSString *)category
                    withLatitude:(NSString *)latitude
                    andLongitude:(NSString *)longitude;

- (void)listResourcesFinish:(NSDictionary *)resultData;

- (void)shareResourceWithResourceId:(NSString *)resourceId
                            forKind:(NSString *)kind
                    withDestination:(NSString *)destination;

- (void)shareResourceFinish:(NSDictionary *)resultData;

@end