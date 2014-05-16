//
//  FirstViewController.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/22/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocalyticsSession.h"
#import "TestFlight.h"
#import "UIDevice+Resolutions.h"
#import "UILabel+VerticalAlignment.h"
#import "ListViewController.h"
#import "AdminViewController.h"
#import "LocationSearchViewController.h"
#import "CustomServicesLabel.h"
#import "Resource.h"

@class ListViewController;
@class FoursquareVenueSearch;
@class GoogleAddressGeocodingSearch;

@interface FirstViewController : UIViewController <ResourceDelegate, CLLocationManagerDelegate>
{    

}

@property (nonatomic, retain) ListViewController *vc2;
@property (nonatomic, retain) Resource *currentResource;

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) UIButton *shelterButton, *foodButton, *medicalButton, *hotlinesButton, *socialServicesButton, *legalAssistanceButton, *employmentServicesButton, *shelterAdminButton;
@property (nonatomic, retain) CustomServicesLabel *searchingNearLabel, *searchingLocationLabel;
@property (nonatomic, retain) UIImageView *searchLocationPopup;
@property (nonatomic, retain) UIButton *searchPopupShowHideButton, *changeLocationButton;
@property BOOL searchPopupIsExpanded;

- (void)listResourcesActionForCategory:(NSString *)category
                          withLocation:(CLLocation *)location;

- (void)listResourcesActionFinish:(NSMutableArray *)resourcesArray;

- (void)setVenue:(FoursquareVenueSearch *)venue;

- (void)setAddress:(GoogleAddressGeocodingSearch *)address;

- (void)searchPopupShowHide;

@end