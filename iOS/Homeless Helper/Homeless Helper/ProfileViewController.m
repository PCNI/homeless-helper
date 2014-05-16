//
//  ProfileViewController.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize currentResource = _currentResource;
@synthesize alertString = _alertString;
@synthesize category = _category;

@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;

@synthesize nameLabel = _nameLabel, addressLabel = _addressLabel, bedsLabel = _bedsLabel;
@synthesize hoursTextView = _hoursTextView, notesTextView = _notesTextView;
@synthesize directionsButton = _directionsButton, callButton = _callButton, shareButton = _shareButton;
@synthesize mapView = _mapView;
@synthesize vaLogo = _vaLogo;

#pragma mark -
#pragma mark RESOURCE/SHARE

- (void)shareResourceWithResourceId:(NSString *)resourceId
                            forKind:(NSString *)kind
                    withDestination:(NSString *)destination
{
    if ([destination length] > 0) {
        [self.currentResource shareResourceWithResourceId:resourceId forKind:kind withDestination:destination];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Field Left Blank" message:@"No destination entered." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark -
#pragma mark INFO MGMT

- (void)displayData
{
    if ([[self.currentResource resourceType] isEqualToString:@"shelter"]) {
        [self.bedsLabel setHidden:NO];
        [self.hoursTextView setFrame:CGRectMake(22, 281, 138, 68)];
        [self.notesTextView setFrame:CGRectMake(160, 281, 138, 68)];
    } else if ([[self.currentResource resourceType] isEqualToString:@"job_gig"]) {
        [self.bedsLabel setHidden:YES];
        [self.hoursTextView setHidden:YES];
        [self.notesTextView setFrame:CGRectMake(22, 253, 276, 96)];
    } else {
        [self.bedsLabel setHidden:YES];
        [self.hoursTextView setFrame:CGRectMake(22, 253, 138, 96)];
        [self.notesTextView setFrame:CGRectMake(160, 253, 138, 96)];
    }

    // update va logo
    if ([[self.currentResource vaStatus] intValue] == 1) {
        [self.vaLogo setHidden:NO];
    } else {
        [self.vaLogo setHidden:YES];
    }
    
    // update hours and notes
    if (![self.currentResource.name1 isMemberOfClass:[NSNull class]]) {
        [self.nameLabel setText:[self.currentResource name1]];
    } else {
        [self.nameLabel setText:@""];
    }
    if (![[self.currentResource hours] isMemberOfClass:[NSNull class]]) {
        [self.hoursTextView setText:[self.currentResource hours]];
    } else {
        [self.hoursTextView setText:@""];
    }
    if (![[self.currentResource notes] isMemberOfClass:[NSNull class]]) {
        [self.notesTextView setText:[self.currentResource notes]];
    } else {
        [self.notesTextView setText:@""];
    }
    
    // update address, url, phone
    if ([[self.currentResource resourceType] isEqualToString:@"hotline"]) {
        [self.addressLabel setText:[self.currentResource phone]];
    } else {
        NSMutableString *addressString = [NSMutableString stringWithFormat:@"%@\n%@, %@ %@", [self.currentResource street1], [self.currentResource city], [self.currentResource state], [self.currentResource zipcode]];
        if (![self.currentResource.url isMemberOfClass:[NSNull class]] && self.currentResource.url.length > 0) {
            [addressString appendString:[NSMutableString stringWithFormat:@"\n%@", [self.currentResource url]]];
        }
        if (![self.currentResource.phone isMemberOfClass:[NSNull class]] && self.currentResource.phone.length > 0) {
            [addressString appendString:[NSMutableString stringWithFormat:@"\n%@", [self.currentResource phone]]];
        }
        if (![self.currentResource.emailAddress isMemberOfClass:[NSNull class]] && self.currentResource.emailAddress.length > 0) {
            [addressString appendString:[NSMutableString stringWithFormat:@"\n%@", [self.currentResource emailAddress]]];
        }
        [self.addressLabel setText:[addressString stringByReplacingOccurrencesOfString:@"<null>" withString:@""]];
    }
    
    // update mapView
    if ([[self.currentResource resourceType] isEqualToString:@"hotline"]) {
        [self.mapView setHidden:YES];
    } else {
        [self.mapView setHidden:NO];
        [self.mapView removeAnnotations:[self.mapView annotations]];
        CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[self.currentResource.locationLat floatValue] longitude:[self.currentResource.locationLong floatValue]];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([placeLocation coordinate], 500, 500);
        [self.mapView setRegion:region animated:YES];
        [self.mapView setShowsUserLocation:NO];
        MapLocation *mp = [[MapLocation alloc] initWithCoordinate:[placeLocation coordinate]];
        [self.mapView addAnnotation:mp];
        [placeLocation release];
        [mp release];
    }
    
    // update bed availability
    if ([[self.currentResource resourceType] isEqualToString:@"shelter"]) {
        if ([[self.currentResource beds] intValue] == 1) {
            [self.bedsLabel setText:[NSString stringWithFormat:@"%i bed available", [[self.currentResource beds] intValue]]];
        } else {
            [self.bedsLabel setText:[NSString stringWithFormat:@"%i beds available", [[self.currentResource beds] intValue]]];
        }
    }
/*    
    // update bed availability
    if ([[self.currentResource resourceType] isEqualToString:@"shelter"]) {
        NSDate *updatedDate = [NSDate dateWithTimeIntervalSince1970:[[self.currentResource lastUpdated] doubleValue]];
        NSDate *todayDate = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *components = [cal components:unitFlags fromDate:updatedDate toDate:todayDate options:0];
        
        NSInteger hours = [components hour];
        NSInteger minutes = [components minute];
        
        NSUInteger dayOfYearUpdated = [cal ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:updatedDate];
        NSUInteger dayOfYearForToday = [cal ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:todayDate];
        
        NSMutableString *lastUpdatedString;
        
        if (dayOfYearUpdated < (dayOfYearForToday-1)) {
            lastUpdatedString = [NSMutableString stringWithFormat:@"updated %i days ago", dayOfYearForToday - dayOfYearUpdated];
        } else if (dayOfYearUpdated == (dayOfYearForToday-1)) {
            lastUpdatedString = [NSMutableString stringWithFormat:@"updated yesterday"];
        } else {
            if (hours > 1) {
                lastUpdatedString = [NSMutableString stringWithFormat:@"updated %i hours ago", hours];
            } else if (hours == 1) {
                lastUpdatedString = [NSMutableString stringWithFormat:@"updated %i hour ago", hours];
            } else if (minutes > 1) {
                lastUpdatedString = [NSMutableString stringWithFormat:@"updated %i minutes ago", minutes];
            } else if (minutes == 1) {
                lastUpdatedString = [NSMutableString stringWithFormat:@"updated %i minute ago", minutes];
            } else {
                lastUpdatedString = [NSMutableString stringWithFormat:@"updated just now"];
            }
        }
        
        if ([[self.currentResource beds] intValue] == 1) {
            [bedsLabel setText:[NSString stringWithFormat:@"%i bed available (%@)", [[self.currentResource beds] intValue], lastUpdatedString]];
        } else {
            [bedsLabel setText:[NSString stringWithFormat:@"%i beds available (%@)", [[self.currentResource beds] intValue], lastUpdatedString]];
        }
    }
*/
    // update buttons
    if ([[self.currentResource resourceType] isEqualToString:@"hotline"]) {
        [self.directionsButton setHidden:YES];
    } else {
        [self.directionsButton setHidden:NO];
    }
    if (![[self.currentResource phone] isMemberOfClass:[NSNull class]] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:+11111"]]) {
        [self.callButton setHidden:NO];
    } else {
        [self.callButton setHidden:YES];
    }
}

#pragma mark -
#pragma mark ACTIONS

- (void)getDirections:(UIButton *)button
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.currentResource.locationLat doubleValue], [self.currentResource.locationLong doubleValue]);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
    {
        [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
    } else {
        NSString *directionsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@,%@", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, self.currentResource.locationLat, self.currentResource.locationLong];
        DLog(@"directionsURL: %@", directionsURL);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[directionsURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    [placemark release];
    [destination release];
}

- (void)callPhone:(UIButton *)button
{
    if (![[self.currentResource phone] isMemberOfClass:[NSNull class]]) {
        NSCharacterSet *numberSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
        NSString *phoneString = [[[self.currentResource phone] componentsSeparatedByCharactersInSet:numberSet] componentsJoinedByString:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneString]]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to call" message:@"No phone number is available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void)share:(UIButton *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share Resource" message:@"Enter phone number or email address:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            self.alertString = nil;
            [self setAlertString:[[alertView textFieldAtIndex:0] text]];
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    DLog(@"alertView clicked button at index: %i", buttonIndex);
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            DLog(@"resourceId: %@, destination: %@", self.currentResource.resourceId, self.alertString);
            [self shareResourceWithResourceId:self.currentResource.resourceId forKind:@"auto" withDestination:self.alertString];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark VIEW CONTROL

- (void)dismissView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark INITIAL VIEW SETUP

- (void)setUpNavBar
{
//    [self.navigationItem setTitle:self.category];
    
    UIImageView *backButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarBackButton.png"]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [backButtonView setUserInteractionEnabled:YES];
    [backButtonView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    [backButtonView release];        
    
    [[self navigationItem] setLeftBarButtonItem:backBarButtonItem];
    
    [backBarButtonItem release];
}

- (void)setUpTextBoxes
{
    [self.nameLabel setFont:[UIFont fontWithName:@"Vollkorn-BoldItalic" size:18]];
    [self.addressLabel setFont:[UIFont fontWithName:@"Vollkorn-Regular" size:13]];
    [self.bedsLabel setFont:[UIFont fontWithName:@"Vollkorn-BoldItalic" size:15]];
    [self.hoursTextView setFont:[UIFont fontWithName:@"Vollkorn-Regular" size:12]];
    [self.hoursTextView setContentInset:UIEdgeInsetsMake(-7, -7, -7, -7)];
    [self.notesTextView setFont:[UIFont fontWithName:@"Vollkorn-Regular" size:12]];
    [self.notesTextView setContentInset:UIEdgeInsetsMake(-7, -7, -7, -7)];
}

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentResource = [[[Resource alloc] init] autorelease];
        [self.currentResource setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];
    [self setUpTextBoxes];
    
    [self.mapView setDelegate:self];
    [self.mapView setMapType:MKMapTypeStandard];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    // set up location
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:5];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    if (TARGET_IPHONE_SIMULATOR) {
#ifndef OPENHMIS
//        self.currentLocation = [[CLLocation alloc] initWithLatitude:38.901454 longitude:-77.037506]; // Washington DC
        self.currentLocation = [[[CLLocation alloc] initWithLatitude:40.348482 longitude:-74.075693] autorelease]; // Soul Kitchen
//        self.currentLocation = [[CLLocation alloc] initWithLatitude:47.611024 longitude:-122.330704]; // Seattle
#endif
        
#ifdef OPENHMIS
        self.currentLocation = [[[CLLocation alloc] initWithLatitude:33.762595 longitude:-84.3853] autorelease]; // Atlanta GA
#endif
    } else {
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingLocation];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Enable location services to get directions" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:self.category];
    [self displayData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)dealloc
{
    [_nameLabel release];
    [_addressLabel release];
    [_bedsLabel release];
    [_hoursTextView release];
    [_notesTextView release];
    [_mapView release];
    [_currentLocation release];
    [_locationManager release];
    [_currentResource release];
    [_alertString release];
    [_category release];
    [super dealloc];
}

#pragma mark -
#pragma mark CORE LOCATION

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    DLog(@"%@", newLocation);
    
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    if (t < -180) {
        return;
    }
    
    if ([newLocation horizontalAccuracy] < 500) [self.locationManager stopUpdatingLocation];
    
//    self.currentLocation = [[CLLocation alloc] init];
    self.currentLocation = newLocation;
//	[self.currentLocation retain];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DLog(@"Could not find location: %@", error);
}

- (CLLocation *)currentLocation
{
    if (!_currentLocation)
    {
        _currentLocation = [[CLLocation alloc] init];
    }
    return _currentLocation;
}

@end