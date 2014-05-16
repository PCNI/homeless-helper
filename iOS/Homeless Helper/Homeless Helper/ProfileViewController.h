//
//  ProfileViewController.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "UIDevice+Resolutions.h"
#import "MapLocation.h"
#import "Resource.h"

@interface ProfileViewController : UIViewController <ResourceDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
{    

}

@property (nonatomic, retain) Resource *currentResource;
@property (nonatomic, retain) NSString *alertString;
@property (nonatomic, retain) NSString *category;

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel, *addressLabel, *bedsLabel;
@property (nonatomic, retain) IBOutlet UITextView *hoursTextView, *notesTextView;
@property (nonatomic, retain) IBOutlet UIButton *directionsButton, *callButton, *shareButton;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIImageView *vaLogo;

- (IBAction)getDirections:(UIButton *)button;
- (IBAction)callPhone:(UIButton *)button;
- (IBAction)share:(UIButton *)button;

- (void)shareResourceWithResourceId:(NSString *)resourceId
                            forKind:(NSString *)kind
                    withDestination:(NSString *)destination;

@end