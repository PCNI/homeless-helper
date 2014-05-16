//
//  FirstViewController.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/22/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "FirstViewController.h"

const int labelTagPadding = 10;
const int shelterTag = 1;
const int foodTag = 2;
const int medicalTag = 3;
const int hotlinesTag = 4;
const int legalTag = 5;
const int socialTag = 6;
const int employmentTag = 7;
const int adminTag = 8;

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize vc2 = _vc2;
@synthesize currentResource = _currentResource;

@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;

@synthesize shelterButton = _shelterButton, foodButton = _foodButton, medicalButton = _medicalButton, hotlinesButton = _hotlinesButton, socialServicesButton = _socialServicesButton, legalAssistanceButton = _legalAssistanceButton, employmentServicesButton = _employmentServicesButton, shelterAdminButton = _shelterAdminButton;

@synthesize searchingNearLabel = _searchingNearLabel, searchingLocationLabel = _searchingLocationLabel;
@synthesize searchLocationPopup = _searchLocationPopup;
@synthesize searchPopupShowHideButton = _searchPopupShowHideButton, changeLocationButton = _changeLocationButton;
@synthesize searchPopupIsExpanded = _searchPopupIsExpanded;

#pragma mark -
#pragma mark RESOURCES/LIST

- (void)listResourcesActionForCategory:(NSString *)category
                          withLocation:(CLLocation *)location
{
    NSString *latString = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    
    NSString *longString = [NSString stringWithFormat:@"%f", location.coordinate.longitude];

    [self.currentResource listResourcesForCategory:category withLatitude:latString andLongitude:longString];
}

- (void)listResourcesActionFinish:(NSMutableArray *)resourcesArray
{
    [self.vc2.resourcesArray removeAllObjects];
    [self.vc2 setResourcesArray:resourcesArray];
    [self.vc2 setCurrentLocation:self.currentLocation];

    [self.navigationController pushViewController:self.vc2 animated:YES];
}

#pragma mark -
#pragma mark ACTIONS

- (void)buttonTapped:(UIButton *)button
{
    self.vc2 = [[[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil] autorelease];
    UILabel *label = (UILabel *)[self.view viewWithTag:button.tag + labelTagPadding];
    [self.vc2 setCategory:[label text]];

    switch (button.tag) {
        case shelterTag:
            DLog(@"%i: Shelter pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Shelter Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Shelter Search"];
#endif
            [self listResourcesActionForCategory:@"shelter" withLocation:self.currentLocation];;
            break;
        case foodTag:
            DLog(@"%i: Food pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Food Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Food Search"];
#endif
           [self listResourcesActionForCategory:@"food" withLocation:self.currentLocation];
            break;
        case medicalTag:
            DLog(@"%i: Medical pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Medical Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Medical Search"];
#endif
            [self listResourcesActionForCategory:@"medical" withLocation:self.currentLocation];
            break;
        case hotlinesTag:
            DLog(@"%i: Hotlines pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Hotline Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Hotline Search"];
#endif
            [self listResourcesActionForCategory:@"hotline" withLocation:self.currentLocation];
            break;
        case legalTag:
            DLog(@"%i: Legal Assistance pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Legal Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Legal Search"];
#endif
            [self listResourcesActionForCategory:@"legal" withLocation:self.currentLocation];
            break;
        case socialTag:
            DLog(@"%i: Social Services pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Social Svcs Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Social Svcs Search"];
#endif
            [self listResourcesActionForCategory:@"social" withLocation:self.currentLocation];
            break;
        case employmentTag:
            DLog(@"%i: Employment pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Employment Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Employment Search"];
#endif
            [self listResourcesActionForCategory:@"employment" withLocation:self.currentLocation];
            break;
        case adminTag:
            DLog(@"%i: Shelter Admin pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Admin Accessed"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Admin Accessed"];
#endif
            AdminViewController *vc3 = [[AdminViewController alloc] initWithNibName:nil bundle:nil];
            UILabel *label = (UILabel *)[self.view viewWithTag:button.tag + labelTagPadding];
            [vc3 setCategory:[label text]];
            [self.navigationController pushViewController:vc3 animated:YES];
            [vc3 release];
            break;
        default:
            break;
    }
}

- (void)changeSearchLocation
{
    LocationSearchViewController *vc2 = [[LocationSearchViewController alloc] initWithNibName:nil bundle:nil];
    [vc2 setCurrentLocation:self.currentLocation];
    [self.navigationController pushViewController:vc2 animated:YES];
    [vc2 release];
}

- (void)searchPopupShowHide
{
    CGRect frame = self.searchLocationPopup.frame;
    CGRect frame2 = self.searchPopupShowHideButton.frame;
    CGRect frame3 = self.searchingLocationLabel.frame;
    CGRect frame4 = self.changeLocationButton.frame;
    CGRect frame5 = self.searchingNearLabel.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    if (!self.searchPopupIsExpanded)
    {
        self.searchPopupIsExpanded = YES;
        frame.origin.y -= 100;
        frame2.origin.y -= 100;
        frame3.origin.y -= 100;
        frame4.origin.y -= 100;
        frame5.origin.y -= 100;
        self.searchLocationPopup.frame = frame;
        self.searchPopupShowHideButton.frame = frame2;
        self.searchingLocationLabel.frame = frame3;
        self.changeLocationButton.frame = frame4;
        self.searchingNearLabel.frame = frame5;
        [self.searchPopupShowHideButton setImage:[UIImage imageNamed:@"searchLocationPopupButtonDown.png"] forState:UIControlStateNormal];
    } else {
        self.searchPopupIsExpanded = NO;
        frame.origin.y  += 100;
        frame2.origin.y += 100;
        frame3.origin.y += 100;
        frame4.origin.y += 100;
        frame5.origin.y += 100;
        self.searchLocationPopup.frame = frame;
        self.searchPopupShowHideButton.frame = frame2;
        self.searchingLocationLabel.frame = frame3;
        self.changeLocationButton.frame = frame4;
        self.searchingNearLabel.frame = frame5;
        [self.searchPopupShowHideButton setImage:[UIImage imageNamed:@"searchLocationPopupButtonUp.png"] forState:UIControlStateNormal];
    }
    
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark INFO MGMT

- (void)setVenue:(FoursquareVenueSearch *)venue
{
    NSMutableString *venueNameString = [NSMutableString stringWithFormat:@"%@", [venue venueName]];
    if (![[venue venueDescription] isEqualToString:@""] && ![[venue venueDescription] isEqualToString:@"(null)"] && [venue venueDescription]) {
        [venueNameString appendString:[NSString stringWithFormat:@", %@", [venue venueDescription]]];
    }
    
    [self.searchingLocationLabel setText:[NSString stringWithFormat:@"%@", venueNameString]];
    
    self.currentLocation = nil;
    self.currentLocation = [[[CLLocation alloc] initWithLatitude:[[venue venueLat] floatValue] longitude:[[venue venueLong] floatValue]] autorelease];
    
    [self adjustSearchLocationLabelAndButton];
}

- (void)setAddress:(GoogleAddressGeocodingSearch *)address
{    
    [self.searchingLocationLabel setText:[NSString stringWithFormat:@"%@", [address addressName]]];
    self.currentLocation = nil;
    self.currentLocation = [[[CLLocation alloc] initWithLatitude:[[address addressLat] floatValue] longitude:[[address addressLong] floatValue]] autorelease];
    
    [self adjustSearchLocationLabelAndButton];
}

- (void)adjustSearchLocationLabelAndButton
{
    CGRect frame3 = self.searchingLocationLabel.frame;
    CGRect frame4 = self.changeLocationButton.frame;
    
    frame3.size.height = [self.searchingLocationLabel frameForSizeOfTextWithMaxHeight:40];
    [self.searchingLocationLabel setFrame:frame3];
    frame4.origin.y = self.searchingLocationLabel.frame.origin.y + self.searchingLocationLabel.frame.size.height + 10;
    [self.changeLocationButton setFrame:frame4];
}

#pragma mark -
#pragma mark INITIAL VIEW SETUP

- (void)setUpNavBar
{
    [self.navigationItem setTitle:@"Homeless Helper"];
}

- (void)setUpButtons
{
    int spaceBetweenIcons = 0;
    int iconStartingYOrigin = 0;
    if (NSStringFromResolution([[UIDevice currentDevice] resolution]) == @"iPhone Retina 4\"") {
        spaceBetweenIcons = 45;
        iconStartingYOrigin = 44;
    } else {
        spaceBetweenIcons = 25;
        iconStartingYOrigin = 31;
    }
    
    DLog(NSStringFromResolution([[UIDevice currentDevice] resolution]));
    
    self.shelterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shelterButton setFrame:CGRectMake(40, iconStartingYOrigin, 70, 70)];
    [self.shelterButton setTag:shelterTag];
    [self.shelterButton setBackgroundImage:[UIImage imageNamed:@"shelterIcon.png"] forState:UIControlStateNormal];
    [self.shelterButton setUserInteractionEnabled:YES];
    [self.shelterButton setEnabled:YES];
    [self.shelterButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shelterButton];
    
    self.foodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.foodButton setFrame:CGRectMake(self.view.frame.size.width - 40 - 70, self.shelterButton.frame.origin.y, self.shelterButton.frame.size.width, self.shelterButton.frame.size.height)];
    [self.foodButton setTag:foodTag];
    [self.foodButton setBackgroundImage:[UIImage imageNamed:@"foodIcon.png"] forState:UIControlStateNormal];
    [self.foodButton setUserInteractionEnabled:YES];
    [self.foodButton setEnabled:YES];
    [self.foodButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.foodButton];
    
    self.medicalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.medicalButton setFrame:CGRectMake(self.shelterButton.frame.origin.x, self.shelterButton.frame.origin.y + self.shelterButton.frame.size.height + spaceBetweenIcons, self.shelterButton.frame.size.width, self.shelterButton.frame.size.height)];
    [self.medicalButton setTag:medicalTag];
    [self.medicalButton setBackgroundImage:[UIImage imageNamed:@"medicalIcon.png"] forState:UIControlStateNormal];
    [self.medicalButton setUserInteractionEnabled:YES];
    [self.medicalButton setEnabled:YES];
    [self.medicalButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.medicalButton];
    
    self.hotlinesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hotlinesButton setFrame:CGRectMake(self.foodButton.frame.origin.x, self.medicalButton.frame.origin.y, self.shelterButton.frame.size.width, self.shelterButton.frame.size.height)];
    [self.hotlinesButton setTag:hotlinesTag];
    [self.hotlinesButton setBackgroundImage:[UIImage imageNamed:@"hotlinesIcon.png"] forState:UIControlStateNormal];
    [self.hotlinesButton setUserInteractionEnabled:YES];
    [self.hotlinesButton setEnabled:YES];
    [self.hotlinesButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hotlinesButton];
    
    self.legalAssistanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.legalAssistanceButton setFrame:CGRectMake(self.shelterButton.frame.origin.x, self.medicalButton.frame.origin.y + self.medicalButton.frame.size.height + spaceBetweenIcons, self.shelterButton.frame.size.width, self.shelterButton.frame.size.height)];
    [self.legalAssistanceButton setTag:legalTag];
    [self.legalAssistanceButton setBackgroundImage:[UIImage imageNamed:@"legalAssistanceIcon.png"] forState:UIControlStateNormal];
    [self.legalAssistanceButton setUserInteractionEnabled:YES];
    [self.legalAssistanceButton setEnabled:YES];
    [self.legalAssistanceButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.legalAssistanceButton];
    
    self.socialServicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.socialServicesButton setFrame:CGRectMake(self.foodButton.frame.origin.x, self.legalAssistanceButton.frame.origin.y, self.shelterButton.frame.size.width, self.shelterButton.frame.size.height)];
    [self.socialServicesButton setTag:socialTag];
    [self.socialServicesButton setBackgroundImage:[UIImage imageNamed:@"socialServicesIcon.png"] forState:UIControlStateNormal];
    [self.socialServicesButton setUserInteractionEnabled:YES];
    [self.socialServicesButton setEnabled:YES];
    [self.socialServicesButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.socialServicesButton];
    
    self.employmentServicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.employmentServicesButton setFrame:CGRectMake(self.shelterButton.frame.origin.x, self.socialServicesButton.frame.origin.y + self.socialServicesButton.frame.size.height + spaceBetweenIcons, self.shelterButton.frame.size.width, self.shelterButton.frame.size.height)];
    [self.employmentServicesButton setTag:employmentTag];
    [self.employmentServicesButton setBackgroundImage:[UIImage imageNamed:@"employmentServicesIcon.png"] forState:UIControlStateNormal];
    [self.employmentServicesButton setUserInteractionEnabled:YES];
    [self.employmentServicesButton setEnabled:YES];
    [self.employmentServicesButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.employmentServicesButton];
    
    self.shelterAdminButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shelterAdminButton setFrame:CGRectMake(self.foodButton.frame.origin.x, self.employmentServicesButton.frame.origin.y, self.shelterButton.frame.size.width, self.shelterButton.frame.size.height)];
    [self.shelterAdminButton setTag:adminTag];
    [self.shelterAdminButton setBackgroundImage:[UIImage imageNamed:@"shelterAdminIcon.png"] forState:UIControlStateNormal];
    [self.shelterAdminButton setUserInteractionEnabled:YES];
    [self.shelterAdminButton setEnabled:YES];
    [self.shelterAdminButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shelterAdminButton];
}

- (void)setUpLabels
{
    CustomServicesLabel *shelterLabel = [[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.shelterButton.frame.origin.x, self.shelterButton.frame.origin.y + 50, self.shelterButton.frame.size.width, 20)];
    [shelterLabel setText:@"Shelter"];
    [shelterLabel setTag:shelterTag + labelTagPadding];
    [self.view addSubview:shelterLabel];
    [shelterLabel release];
    
    CustomServicesLabel *foodLabel = [[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.foodButton.frame.origin.x, self.foodButton.frame.origin.y + 50, self.foodButton.frame.size.width, 20)];
    [foodLabel setText:@"Food"];
    [foodLabel setTag:foodTag + labelTagPadding];
    [self.view addSubview:foodLabel];
    [foodLabel release];
    
    CustomServicesLabel *medicalLabel = [[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.medicalButton.frame.origin.x, self.medicalButton.frame.origin.y + 50, self.medicalButton.frame.size.width, 20)];
    [medicalLabel setText:@"Medical"];
    [medicalLabel setTag:medicalTag + labelTagPadding];
    [self.view addSubview:medicalLabel];
    [medicalLabel release];
    
    CustomServicesLabel *hotlinesLabel = [[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.hotlinesButton.frame.origin.x, self.hotlinesButton.frame.origin.y + 50, self.hotlinesButton.frame.size.width, 20)];
    [hotlinesLabel setText:@"Hotlines"];
    [hotlinesLabel setTag:hotlinesTag + labelTagPadding];
    [self.view addSubview:hotlinesLabel];
    [hotlinesLabel release];
    
    CustomServicesLabel *legalAssistanceLabel = [[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.legalAssistanceButton.frame.origin.x - 15, self.legalAssistanceButton.frame.origin.y + 50, self.legalAssistanceButton.frame.size.width + 30, 20)];
    [legalAssistanceLabel setText:@"Legal Assistance"];
    [legalAssistanceLabel setTag:legalTag + labelTagPadding];
    [self.view addSubview:legalAssistanceLabel];
    [legalAssistanceLabel release];
    
    CustomServicesLabel *socialServicesLabel = [[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.socialServicesButton.frame.origin.x - 10, self.socialServicesButton.frame.origin.y + 50, self.socialServicesButton.frame.size.width + 20, 20)];
    [socialServicesLabel setText:@"Social Services"];
    [socialServicesLabel setTag:socialTag + labelTagPadding];
    [self.view addSubview:socialServicesLabel];
    [socialServicesLabel release];
    
    CustomServicesLabel *employmentServicesLabel = [[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.employmentServicesButton.frame.origin.x - 5, self.employmentServicesButton.frame.origin.y + 50, self.employmentServicesButton.frame.size.width + 10, 20)];
    [employmentServicesLabel setText:@"Employment"];
    [employmentServicesLabel setTag:employmentTag + labelTagPadding];
    [self.view addSubview:employmentServicesLabel];
    [employmentServicesLabel release];
    
    CustomServicesLabel *shelterAdminLabel = [[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.shelterAdminButton.frame.origin.x - 10, self.shelterAdminButton.frame.origin.y + 50, self.shelterAdminButton.frame.size.width + 20, 20)];
    [shelterAdminLabel setText:@"Caregiver"];
    [shelterAdminLabel setTag:adminTag + labelTagPadding];
    [self.view addSubview:shelterAdminLabel];
    [shelterAdminLabel release];
}

- (void)setUpSearchLocationPopup
{
    UIImage *buttonImage = [UIImage imageNamed:@"searchLocationPopupButtonUp.png"];

    self.searchLocationPopup = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchLocationPopup.png"]] autorelease];
    [self.searchLocationPopup setFrame:CGRectMake(self.view.frame.origin.x + 50, self.view.frame.size.height - buttonImage.size.height - 6, self.view.frame.size.width - 100, 200)];
    [self.searchLocationPopup setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:self.searchLocationPopup];
    
    self.searchPopupShowHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchPopupShowHideButton setImage:buttonImage forState:UIControlStateNormal];
    [self.searchPopupShowHideButton setFrame:CGRectMake(self.searchLocationPopup.frame.origin.x + (self.searchLocationPopup.frame.size.width / 2) - (buttonImage.size.width / 2), self.searchLocationPopup.frame.origin.y + 3, buttonImage.size.width, buttonImage.size.height)];
    [self.searchPopupShowHideButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.searchPopupShowHideButton addTarget:self action:@selector(searchPopupShowHide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchPopupShowHideButton];
    
    self.searchPopupIsExpanded = NO;
    
    self.searchingNearLabel = [[[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.searchLocationPopup.frame.origin.x, self.searchPopupShowHideButton.frame.origin.y + self.searchPopupShowHideButton.frame.size.height, self.searchLocationPopup.frame.size.width, 20)] autorelease];
    [self.searchingNearLabel setFont:[UIFont fontWithName:@"Vollkorn-Bold" size:10]];
    [self.searchingNearLabel setText:@"Searching Near"];
    [self.searchingNearLabel setTextAlignment:UITextAlignmentCenter];
    [self.searchingNearLabel setNumberOfLines:1];
    [self.searchingNearLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:self.searchingNearLabel];
    
    self.searchingLocationLabel = [[[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.searchLocationPopup.frame.origin.x + 3, self.searchingNearLabel.frame.origin.y + self.searchingNearLabel.frame.size.height, self.searchLocationPopup.frame.size.width - 6, [self.searchingLocationLabel frameForSizeOfTextWithMaxHeight:100])] autorelease];
    [self.searchingLocationLabel setFont:[UIFont fontWithName:@"Vollkorn-Regular" size:10]];
    [self.searchingLocationLabel setText:@"Current Location"];
    [self.searchingLocationLabel setTextAlignment:UITextAlignmentCenter];
    [self.searchingLocationLabel setNumberOfLines:0];
    [self.searchingLocationLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:self.searchingLocationLabel];
    
    UIImage *buttonImage2 = [UIImage imageNamed:@"changeLocationButton.png"];
    self.changeLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.changeLocationButton setFrame:CGRectMake((self.view.frame.size.width / 2) - (buttonImage2.size.width / 2), self.searchingLocationLabel.frame.origin.y + self.searchingLocationLabel.frame.size.height + 10, buttonImage2.size.width, buttonImage2.size.height)];
    [self.changeLocationButton setBackgroundImage:buttonImage2 forState:UIControlStateNormal];
    [self.changeLocationButton setBackgroundImage:[UIImage imageNamed:@"changeLocationButtonTapped.png"] forState:UIControlStateHighlighted];
    [self.changeLocationButton setUserInteractionEnabled:YES];
    [self.changeLocationButton setEnabled:YES];
    [self.changeLocationButton addTarget:self action:@selector(changeSearchLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeLocationButton];
}

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.title = NSLocalizedString(@"First", @"First");        
    }
    return self;
}
							
- (void)viewDidLoad
{
    [self setUpNavBar];
    [self setUpButtons];
    [self setUpLabels];
    [self setUpSearchLocationPopup];
    
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Enable location services to search resources" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
    
    self.currentResource = [[[Resource alloc] init] autorelease];
    [self.currentResource setDelegate:self];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    CGRect frame3 = self.searchingLocationLabel.frame;
    CGRect frame4 = self.changeLocationButton.frame;

    frame3.size.height = [self.searchingLocationLabel frameForSizeOfTextWithMaxHeight:40];
    [self.searchingLocationLabel setFrame:frame3];
    frame4.origin.y = self.searchingLocationLabel.frame.origin.y + self.searchingLocationLabel.frame.size.height + 10;
    [self.changeLocationButton setFrame:frame4];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.searchPopupIsExpanded) {
        [self searchPopupShowHide];
    }
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
    [_vc2 release];
    [_currentResource release];
    [_currentLocation release];
    [_locationManager release];
    [_shelterButton release];
    [_foodButton release];
    [_medicalButton release];
    [_hotlinesButton release];
    [_socialServicesButton release];
    [_legalAssistanceButton release];
    [_employmentServicesButton release];
    [_shelterAdminButton release];
    [_searchingNearLabel release];
    [_searchingLocationLabel release];
    [_searchLocationPopup release];
    [_searchPopupShowHideButton release];
    [_changeLocationButton release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark CORE LOCATION

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    DLog(@"%@", newLocation);
    
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    if (t < -180) {
        return;
    }

    if ([newLocation horizontalAccuracy] < 500.0) [self.locationManager stopUpdatingLocation];
    
//    self.currentLocation = [[CLLocation alloc] init];
    [newLocation retain];
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