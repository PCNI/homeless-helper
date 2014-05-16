//
//  RightSideViewController.h
//  Homeless Helper
//
//  Created by Jessi on 9/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocalyticsSession.h"
#import "TestFlight.h"
#import "AppDelegate_iPad.h"
#import "CustomServicesLabel.h"
#import "CustomToolbarLabel.h"
#import "LeftSideViewController.h"
#import "LocationSearchPopupViewController.h"
#import "Resource.h"

@class LeftSideViewController;
@class FoursquareVenueSearch;
@class GoogleAddressGeocodingSearch;

@interface RightSideViewController : UIViewController <LocationSearchPopupViewControllerDelegate, UISplitViewControllerDelegate, UIPopoverControllerDelegate, MKMapViewDelegate, UIWebViewDelegate>
{
    
}

@property (nonatomic, retain) Resource *currentResource;

@property (nonatomic, retain) LeftSideViewController *lvc;

@property (nonatomic, retain) UIPopoverController *barButtonItemPopoverController, *changeLocationPopoverController;

@property (nonatomic, retain) NSMutableArray *resourcesArray;

@property (nonatomic, retain) MKMapView *mapView;

@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) UIWebView *webView;

@property (nonatomic, retain) UIToolbar *toolbar;

@property (nonatomic, retain) UIButton *shelterButton, *foodButton, *medicalButton, *hotlinesButton, *socialServicesButton, *legalAssistanceButton, *employmentServicesButton, *shelterAdminButton;

@property (nonatomic, retain) UILabel *shelterLabel, *foodLabel, *medicalLabel, *hotlinesLabel, *socialServicesLabel, *legalAssistanceLabel, *employmentServicesLabel, *shelterAdminLabel;

@property (nonatomic, retain) NSString *alertString;

@property (nonatomic, retain) UIButton *directionsButton, *callButton, *shareButton;

@property (nonatomic, retain) UIImageView *topInfoBox, *bottomInfoBox;

@property (nonatomic, retain) UILabel *nameLabel, *addressLabel, *bedsLabel;
@property (nonatomic, retain) UITextView *hoursTextView, *notesTextView;
@property (nonatomic, retain) UIImageView *vaLogo;

- (void)buttonTapped:(UIButton *)button;

- (void)showMapAnnotations;

- (void)selectMapAnnotation;

- (void)showWebViewWithUrl:(NSURL *)url;

- (void)removeWebView;

- (void)displayData;

- (void)clearInfoBoxes;

- (void)reloadData;

- (void)setVenue:(FoursquareVenueSearch *)venue;

- (void)setAddress:(GoogleAddressGeocodingSearch *)address;

@end