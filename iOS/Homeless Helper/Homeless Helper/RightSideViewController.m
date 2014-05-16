//
//  RightSideViewController.m
//  Homeless Helper
//
//  Created by Jessi on 9/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "RightSideViewController.h"

const int labelTagPaddingIpad = 10;
const int shelterTagIpad = 1;
const int foodTagIpad = 2;
const int medicalTagIpad = 3;
const int hotlinesTagIpad = 4;
const int legalTagIpad = 5;
const int socialTagIpad = 6;
const int employmentTagIpad = 7;
const int adminTagIpad = 8;

@interface RightSideViewController ()

@end

@implementation RightSideViewController

@synthesize currentResource = _currentResource;
@synthesize lvc = _lvc;
@synthesize barButtonItemPopoverController = _barButtonItemPopoverController, changeLocationPopoverController = _changeLocationPopoverController;
@synthesize resourcesArray = _resourcesArray;
@synthesize mapView = _mapView;
@synthesize currentLocation = _currentLocation;
@synthesize webView = _webView;
@synthesize toolbar = _toolbar;
@synthesize shelterButton = _shelterButton, foodButton = _foodButton, medicalButton = _medicalButton, hotlinesButton = _hotlinesButton, socialServicesButton = _socialServicesButton, legalAssistanceButton = _legalAssistanceButton, employmentServicesButton = _employmentServicesButton, shelterAdminButton = _shelterAdminButton;
@synthesize shelterLabel = _shelterLabel, foodLabel = _foodLabel, medicalLabel = _medicalLabel, hotlinesLabel = _hotlinesLabel, socialServicesLabel = _socialServicesLabel, legalAssistanceLabel = _legalAssistanceLabel, employmentServicesLabel = _employmentServicesLabel, shelterAdminLabel = _shelterAdminLabel;
@synthesize alertString = _alertString;
@synthesize directionsButton = _directionsButton, callButton = _callButton, shareButton = _shareButton;
@synthesize topInfoBox = _topInfoBox, bottomInfoBox = _bottomInfoBox;
@synthesize nameLabel = _nameLabel, addressLabel = _addressLabel, bedsLabel = _bedsLabel;
@synthesize hoursTextView = _hoursTextView, notesTextView = _notesTextView;
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

- (void)showMapAnnotations
{
    [self.mapView removeAnnotations:[self.mapView annotations]];

    if ([self.lvc.category isEqualToString:@"Jobs & Volunteer Opps"]) {
        for (int i = 0; i < self.lvc.gigsArray.count; i++) {
            Resource *resource = [self.lvc.gigsArray objectAtIndex:i];
            [self.mapView addAnnotation:resource.annotation];
            [resource.annotation setTag:i];
        }
    } else {
        for (int i = 0; i < self.resourcesArray.count; i++) {
            Resource *resource = [self.resourcesArray objectAtIndex:i];
            [self.mapView addAnnotation:resource.annotation];
            [resource.annotation setTag:i];
        }
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 25000, 25000);
    [self.mapView setRegion:region animated:YES];
}

- (void)selectMapAnnotation
{
    if (![[self.currentResource resourceType] isEqualToString:@"hotline"]) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.currentResource.locationLat doubleValue], [self.currentResource.locationLong doubleValue]);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 25000, 25000);
        [self.mapView setRegion:region animated:YES];
        
        if ([self.currentResource.annotation.name isMemberOfClass:[NSNull class]] && [self.lvc.category isEqualToString:@"Jobs & Volunteer Opps"]) {
            [self.currentResource.annotation setName:self.currentResource.opportunityType];
        }
        
        [self.mapView selectAnnotation:self.currentResource.annotation animated:YES];
    }
}

- (void)displayData
{
    [self.topInfoBox setHidden:NO];
    [self.bottomInfoBox setHidden:NO];
    
    if ([[self.currentResource resourceType] isEqualToString:@"shelter"]) {
        [self.bedsLabel setHidden:NO];
        [self.hoursTextView setFrame:CGRectMake(self.bottomInfoBox.frame.origin.x, self.bedsLabel.frame.origin.y + self.bedsLabel.frame.size.height, self.bottomInfoBox.frame.size.width / 2, self.bottomInfoBox.frame.size.height - self.bedsLabel.frame.size.height)];
        [self.notesTextView setFrame:CGRectMake(self.hoursTextView.frame.origin.x + self.hoursTextView.frame.size.width, self.hoursTextView.frame.origin.y, self.bottomInfoBox.frame.size.width / 2, self.hoursTextView.frame.size.height)];
    } else if ([[self.currentResource resourceType] isEqualToString:@"job_gig"]) {
        [self.bedsLabel setHidden:YES];
        [self.notesTextView setFrame:CGRectMake(self.bottomInfoBox.frame.origin.x + 2, self.bottomInfoBox.frame.origin.y + 2, self.bottomInfoBox.frame.size.width - 4, self.bottomInfoBox.frame.size.height - 4)];
    } else {
        [self.bedsLabel setHidden:YES];
        [self.hoursTextView setFrame:CGRectMake(self.bottomInfoBox.frame.origin.x, self.bottomInfoBox.frame.origin.y, self.bottomInfoBox.frame.size.width / 2, self.bottomInfoBox.frame.size.height)];
        [self.notesTextView setFrame:CGRectMake(self.hoursTextView.frame.origin.x + self.hoursTextView.frame.size.width, self.hoursTextView.frame.origin.y, self.bottomInfoBox.frame.size.width / 2, self.hoursTextView.frame.size.height)];
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
    
    // update bed availability
    if ([[self.currentResource resourceType] isEqualToString:@"shelter"]) {
        if ([[self.currentResource beds] intValue] == 1) {
            [self.bedsLabel setText:[NSString stringWithFormat:@"%i bed available", [[self.currentResource beds] intValue]]];
        } else {
            [self.bedsLabel setText:[NSString stringWithFormat:@"%i beds available", [[self.currentResource beds] intValue]]];
        }
    }

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
    [self.shareButton setHidden:NO];
}

- (void)clearInfoBoxes
{
    [self.directionsButton setHidden:YES];
    [self.callButton setHidden:YES];
    [self.shareButton setHidden:YES];
    [self.topInfoBox setHidden:YES];
    [self.bottomInfoBox setHidden:YES];
    [self.nameLabel setText:@""];
    [self.addressLabel setText:@""];
    [self.bedsLabel setText:@""];
    [self.hoursTextView setText:@""];
    [self.notesTextView setText:@""];
    [self.vaLogo setHidden:YES];
}

- (void)setVenue:(FoursquareVenueSearch *)venue
{
    NSMutableString *venueNameString = [NSMutableString stringWithFormat:@"%@", [venue venueName]];
    if (![[venue venueDescription] isEqualToString:@""] && ![[venue venueDescription] isEqualToString:@"(null)"] && [venue venueDescription]) {
        [venueNameString appendString:[NSString stringWithFormat:@", %@", [venue venueDescription]]];
    }
    
//    [self.searchingLocationLabel setText:[NSString stringWithFormat:@"%@", venueNameString]];
    
    self.currentLocation = nil;
    self.currentLocation = [[[CLLocation alloc] initWithLatitude:[[venue venueLat] floatValue] longitude:[[venue venueLong] floatValue]] autorelease];
    self.lvc.currentLocation = self.currentLocation;
    [self reloadData];
    
//    [self adjustSearchLocationLabelAndButton];
}

- (void)setAddress:(GoogleAddressGeocodingSearch *)address
{
//    [self.searchingLocationLabel setText:[NSString stringWithFormat:@"%@", [address addressName]]];
    self.currentLocation = nil;
    self.currentLocation = [[[CLLocation alloc] initWithLatitude:[[address addressLat] floatValue] longitude:[[address addressLong] floatValue]] autorelease];
    self.lvc.currentLocation = self.currentLocation;
    [self reloadData];
    
//    [self adjustSearchLocationLabelAndButton];
}

- (void)reloadData
{
    if ([self.lvc.category isEqualToString:@"Shelter"]) {
        [self buttonTapped:self.shelterButton];
    } else if ([self.lvc.category isEqualToString:@"Food"]) {
        [self buttonTapped:self.foodButton];
    } else if ([self.lvc.category isEqualToString:@"Medical"]) {
        [self buttonTapped:self.medicalButton];
    } else if ([self.lvc.category isEqualToString:@"Hotlines"]) {
        [self buttonTapped:self.hotlinesButton];
    } else if ([self.lvc.category isEqualToString:@"Legal Assistance"]) {
        [self buttonTapped:self.legalAssistanceButton];
    } else if ([self.lvc.category isEqualToString:@"Social Services"]) {
        [self buttonTapped:self.socialServicesButton];
    } else if ([self.lvc.category isEqualToString:@"Employment"]) {
        [self buttonTapped:self.employmentServicesButton];
    }
}

#pragma mark -
#pragma mark ACTIONS

- (void)buttonTapped:(UIButton *)button
{
    UILabel *label = (UILabel *)[self.view viewWithTag:button.tag + labelTagPaddingIpad];
    [self.lvc setCategory:[label text]];
    [self resetButtons];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.lvc.resourcesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self removeWebView];
    [self clearInfoBoxes];
    
    for (ResourceAnnotation *anno in self.mapView.annotations) {
        [self.mapView deselectAnnotation:anno animated:YES];
    }

    if (self.lvc.navigationController.viewControllers.count > 1) {
        [self.lvc.navigationController popViewControllerAnimated:YES];
    }
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        if ([self.lvc.category isEqualToString:@"Caregiver"]) {
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
        } else {
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
        }
    }
    switch (button.tag) {
        case shelterTagIpad:
            DLog(@"%i: Shelter pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Shelter Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Shelter Search"];
#endif
            [self.shelterButton setBackgroundImage:[UIImage imageNamed:@"toolbarShelterIconSelected.png"] forState:UIControlStateNormal];
            [self.shelterLabel setTextColor:[UIColor whiteColor]];
            [self.lvc listResourcesActionForCategory:@"shelter" withLocation:self.currentLocation];;
            break;
        case foodTagIpad:
            DLog(@"%i: Food pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Food Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Food Search"];
#endif
            [self.foodButton setBackgroundImage:[UIImage imageNamed:@"toolbarFoodIconSelected.png"] forState:UIControlStateNormal];
            [self.foodLabel setTextColor:[UIColor whiteColor]];
            [self.lvc listResourcesActionForCategory:@"food" withLocation:self.currentLocation];
            break;
        case medicalTagIpad:
            DLog(@"%i: Medical pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Medical Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Medical Search"];
#endif
            [self.medicalButton setBackgroundImage:[UIImage imageNamed:@"toolbarMedicalIconSelected.png"] forState:UIControlStateNormal];
            [self.medicalLabel setTextColor:[UIColor whiteColor]];
            [self.lvc listResourcesActionForCategory:@"medical" withLocation:self.currentLocation];
            break;
        case hotlinesTagIpad:
            DLog(@"%i: Hotlines pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Hotline Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Hotline Search"];
#endif
            [self.hotlinesButton setBackgroundImage:[UIImage imageNamed:@"toolbarHotlinesIconSelected.png"] forState:UIControlStateNormal];
            [self.hotlinesLabel setTextColor:[UIColor whiteColor]];
            [self.lvc listResourcesActionForCategory:@"hotline" withLocation:self.currentLocation];
            break;
        case legalTagIpad:
            DLog(@"%i: Legal Assistance pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Legal Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Legal Search"];
#endif
            [self.legalAssistanceButton setBackgroundImage:[UIImage imageNamed:@"toolbarLegalAssistanceIconSelected.png"] forState:UIControlStateNormal];
            [self.legalAssistanceLabel setTextColor:[UIColor whiteColor]];
            [self.lvc listResourcesActionForCategory:@"legal" withLocation:self.currentLocation];
            break;
        case socialTagIpad:
            DLog(@"%i: Social Services pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Social Svcs Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Social Svcs Search"];
#endif
            [self.socialServicesButton setBackgroundImage:[UIImage imageNamed:@"toolbarSocialServicesIconSelected.png"] forState:UIControlStateNormal];
            [self.socialServicesLabel setTextColor:[UIColor whiteColor]];
            [self.lvc listResourcesActionForCategory:@"social" withLocation:self.currentLocation];
            break;
        case employmentTagIpad:
            DLog(@"%i: Employment pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Employment Search"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Employment Search"];
#endif
            [self.employmentServicesButton setBackgroundImage:[UIImage imageNamed:@"toolbarEmploymentServicesIconSelected.png"] forState:UIControlStateNormal];
            [self.employmentServicesLabel setTextColor:[UIColor whiteColor]];
            [self.lvc listResourcesActionForCategory:@"employment" withLocation:self.currentLocation];
            break;
        case adminTagIpad:
            DLog(@"%i: Shelter Admin pressed", button.tag);
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Admin Accessed"];
#ifdef TESTING
            [TestFlight passCheckpoint:@"Admin Accessed"];
#endif
            [self.shelterAdminButton setBackgroundImage:[UIImage imageNamed:@"toolbarShelterAdminIconSelected.png"] forState:UIControlStateNormal];
            [self.shelterAdminLabel setTextColor:[UIColor whiteColor]];
            [self.lvc.resourcesArray removeAllObjects];
            [self.lvc.resourcesTableView reloadData];
            [self.lvc.navigationItem setTitle:@"Caregiver"];
#ifndef RELEASE
            [self showWebViewWithUrl:[NSURL URLWithString:kHomelessHelperDevAdminURL]];
#endif
            
#ifdef RELEASE
            [self showWebViewWithUrl:[NSURL URLWithString:kHomelessHelperAdminURL]];
#endif
            break;
        default:
            break;
    }
}

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

- (void)showChangeLocationPopup
{
    if (!self.changeLocationPopoverController) {
        LocationSearchPopupViewController *vc1 = [[LocationSearchPopupViewController alloc] init];
        [vc1 setDelegate:self];
        [vc1 setCurrentLocation:self.currentLocation];
        [vc1 setContentSizeForViewInPopover:CGSizeMake(320, 480)];
        self.changeLocationPopoverController = [[[UIPopoverController alloc] initWithContentViewController:vc1] autorelease];
    }
    
    if (self.changeLocationPopoverController.popoverVisible) {
        [self.changeLocationPopoverController dismissPopoverAnimated:YES];
    } else {
        [self.changeLocationPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark -
#pragma mark VIEW CONTROL

- (void)showWebViewWithUrl:(NSURL *)url
{
    [self.webView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.toolbar.frame.size.height)];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0]];

    [self.view addSubview:self.webView];
}

- (void)removeWebView
{
    [self.webView removeFromSuperview];
    [self.webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
}

#pragma mark -
#pragma mark INITIAL VIEW SETUP

- (void)setUpNavBar
{
    [self.navigationItem setTitle:@"Homeless Helper"];
    
    UIImageView *changeLocationButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarChangeLocationButton.png"]];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showChangeLocationPopup)];
    [changeLocationButtonView setUserInteractionEnabled:YES];
    [changeLocationButtonView addGestureRecognizer:tapGesture2];
    [tapGesture2 release];
    
    UIBarButtonItem *changeLocationBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:changeLocationButtonView];
    [changeLocationButtonView release];
    
    [[self navigationItem] setRightBarButtonItem:changeLocationBarButtonItem];
    
    [changeLocationBarButtonItem release];
}

- (void)setUpToolbar
{
    UIImage *image = [UIImage imageNamed:@"toolbarBackground.png"];
    self.toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height - image.size.height, self.view.frame.size.width, image.size.height)] autorelease];
    [self.toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [self.toolbar setBackgroundImage:image forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.toolbar];
    
    self.shelterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shelterButton setFrame:CGRectMake(self.toolbar.frame.origin.x + 19, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.shelterButton setTag:shelterTagIpad];
    [self.shelterButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.shelterButton setEnabled:YES];
    [self.shelterButton setUserInteractionEnabled:YES];
    [self.shelterButton setBackgroundImage:[UIImage imageNamed:@"toolbarShelterIcon.png"] forState:UIControlStateNormal];
    [self.shelterButton setBackgroundImage:[UIImage imageNamed:@"toolbarShelterIconSelected.png"] forState:UIControlStateSelected];
    [self.shelterButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shelterButton];
    
    self.foodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.foodButton setFrame:CGRectMake(self.shelterButton.frame.origin.x + self.shelterButton.frame.size.width + 15, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.foodButton setTag:foodTagIpad];
    [self.foodButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.foodButton setEnabled:YES];
    [self.foodButton setUserInteractionEnabled:YES];
    [self.foodButton setBackgroundImage:[UIImage imageNamed:@"toolbarFoodIcon.png"] forState:UIControlStateNormal];
    [self.foodButton setBackgroundImage:[UIImage imageNamed:@"toolbarFoodIconSelected.png"] forState:UIControlStateSelected];
    [self.foodButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.foodButton];
    
    self.medicalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.medicalButton setFrame:CGRectMake(self.foodButton.frame.origin.x + self.foodButton.frame.size.width + 15, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.medicalButton setTag:medicalTagIpad];
    [self.medicalButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.medicalButton setEnabled:YES];
    [self.medicalButton setUserInteractionEnabled:YES];
    [self.medicalButton setBackgroundImage:[UIImage imageNamed:@"toolbarMedicalIcon.png"] forState:UIControlStateNormal];
    [self.medicalButton setBackgroundImage:[UIImage imageNamed:@"toolbarMedicalIconSelected.png"] forState:UIControlStateSelected];
    [self.medicalButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.medicalButton];
    
    self.hotlinesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hotlinesButton setFrame:CGRectMake(self.medicalButton.frame.origin.x + self.medicalButton.frame.size.width + 15, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.hotlinesButton setTag:hotlinesTagIpad];
    [self.hotlinesButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.hotlinesButton setEnabled:YES];
    [self.hotlinesButton setUserInteractionEnabled:YES];
    [self.hotlinesButton setBackgroundImage:[UIImage imageNamed:@"toolbarHotlinesIcon.png"] forState:UIControlStateNormal];
    [self.hotlinesButton setBackgroundImage:[UIImage imageNamed:@"toolbarHotlinesIconSelected.png"] forState:UIControlStateSelected];
    [self.hotlinesButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hotlinesButton];
    
    self.legalAssistanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.legalAssistanceButton setFrame:CGRectMake(self.hotlinesButton.frame.origin.x + self.hotlinesButton.frame.size.width + 15, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.legalAssistanceButton setTag:legalTagIpad];
    [self.legalAssistanceButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.legalAssistanceButton setEnabled:YES];
    [self.legalAssistanceButton setUserInteractionEnabled:YES];
    [self.legalAssistanceButton setBackgroundImage:[UIImage imageNamed:@"toolbarLegalAssistanceIcon.png"] forState:UIControlStateNormal];
    [self.legalAssistanceButton setBackgroundImage:[UIImage imageNamed:@"toolbarLegalAssistanceIconSelected.png"] forState:UIControlStateSelected];
    [self.legalAssistanceButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.legalAssistanceButton];
    
    self.socialServicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.socialServicesButton setFrame:CGRectMake(self.legalAssistanceButton.frame.origin.x + self.legalAssistanceButton.frame.size.width + 15, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.socialServicesButton setTag:socialTagIpad];
    [self.socialServicesButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.socialServicesButton setEnabled:YES];
    [self.socialServicesButton setUserInteractionEnabled:YES];
    [self.socialServicesButton setBackgroundImage:[UIImage imageNamed:@"toolbarSocialServicesIcon.png"] forState:UIControlStateNormal];
    [self.socialServicesButton setBackgroundImage:[UIImage imageNamed:@"toolbarSocialServicesIconSelected.png"] forState:UIControlStateSelected];
    [self.socialServicesButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.socialServicesButton];
    
    self.employmentServicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.employmentServicesButton setFrame:CGRectMake(self.socialServicesButton.frame.origin.x + self.socialServicesButton.frame.size.width + 15, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.employmentServicesButton setTag:employmentTagIpad];
    [self.employmentServicesButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.employmentServicesButton setEnabled:YES];
    [self.employmentServicesButton setUserInteractionEnabled:YES];
    [self.employmentServicesButton setBackgroundImage:[UIImage imageNamed:@"toolbarEmploymentServicesIcon.png"] forState:UIControlStateNormal];
    [self.employmentServicesButton setBackgroundImage:[UIImage imageNamed:@"toolbarEmploymentServicesIconSelected.png"] forState:UIControlStateSelected];
    [self.employmentServicesButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.employmentServicesButton];
    
    self.shelterAdminButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shelterAdminButton setFrame:CGRectMake(self.employmentServicesButton.frame.origin.x + self.employmentServicesButton.frame.size.width + 15, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.shelterAdminButton setTag:adminTagIpad];
    [self.shelterAdminButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.shelterAdminButton setEnabled:YES];
    [self.shelterAdminButton setUserInteractionEnabled:YES];
    [self.shelterAdminButton setBackgroundImage:[UIImage imageNamed:@"toolbarShelterAdminIcon.png"] forState:UIControlStateNormal];
    [self.shelterAdminButton setBackgroundImage:[UIImage imageNamed:@"toolbarShelterAdminIconSelected.png"] forState:UIControlStateSelected];
    [self.shelterAdminButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shelterAdminButton];
    
    self.shelterLabel = [[[CustomToolbarLabel alloc] initWithFrame:CGRectMake(self.shelterButton.frame.origin.x, self.shelterButton.frame.origin.y + self.shelterButton.frame.size.height - 13, self.shelterButton.frame.size.width, 10)] autorelease];
    [self.shelterLabel setText:@"Shelter"];
    [self.shelterLabel setTag:shelterTagIpad + labelTagPaddingIpad];
    [self.view addSubview:self.shelterLabel];
    
    self.foodLabel = [[[CustomToolbarLabel alloc] initWithFrame:CGRectMake(self.foodButton.frame.origin.x, self.foodButton.frame.origin.y + self.foodButton.frame.size.height - 13, self.foodButton.frame.size.width, 10)] autorelease];
    [self.foodLabel setText:@"Food"];
    [self.foodLabel setTag:foodTagIpad + labelTagPaddingIpad];
    [self.view addSubview:self.foodLabel];
    
    self.medicalLabel = [[[CustomToolbarLabel alloc] initWithFrame:CGRectMake(self.medicalButton.frame.origin.x, self.medicalButton.frame.origin.y + self.medicalButton.frame.size.height - 13, self.medicalButton.frame.size.width, 10)] autorelease];
    [self.medicalLabel setText:@"Medical"];
    [self.medicalLabel setTag:medicalTagIpad + labelTagPaddingIpad];
    [self.view addSubview:self.medicalLabel];
    
    self.hotlinesLabel = [[[CustomToolbarLabel alloc] initWithFrame:CGRectMake(self.hotlinesButton.frame.origin.x, self.hotlinesButton.frame.origin.y + self.hotlinesButton.frame.size.height - 13, self.hotlinesButton.frame.size.width, 10)] autorelease];
    [self.hotlinesLabel setText:@"Hotlines"];
    [self.hotlinesLabel setTag:hotlinesTagIpad + labelTagPaddingIpad];
    [self.view addSubview:self.hotlinesLabel];
    
    self.legalAssistanceLabel = [[[CustomToolbarLabel alloc] initWithFrame:CGRectMake(self.legalAssistanceButton.frame.origin.x, self.legalAssistanceButton.frame.origin.y + self.legalAssistanceButton.frame.size.height - 13, self.legalAssistanceButton.frame.size.width, 10)] autorelease];
    [self.legalAssistanceLabel setText:@"Legal Assistance"];
    [self.legalAssistanceLabel setTag:legalTagIpad + labelTagPaddingIpad];
    [self.view addSubview:self.legalAssistanceLabel];
    
    self.socialServicesLabel = [[[CustomToolbarLabel alloc] initWithFrame:CGRectMake(self.socialServicesButton.frame.origin.x, self.socialServicesButton.frame.origin.y + self.socialServicesButton.frame.size.height - 13, self.socialServicesButton.frame.size.width, 10)] autorelease];
    [self.socialServicesLabel setText:@"Social Services"];
    [self.socialServicesLabel setTag:socialTagIpad + labelTagPaddingIpad];
    [self.view addSubview:self.socialServicesLabel];
    
    self.employmentServicesLabel = [[[CustomToolbarLabel alloc] initWithFrame:CGRectMake(self.employmentServicesButton.frame.origin.x, self.employmentServicesButton.frame.origin.y + self.employmentServicesButton.frame.size.height - 13, self.employmentServicesButton.frame.size.width, 10)] autorelease];
    [self.employmentServicesLabel setText:@"Employment"];
    [self.employmentServicesLabel setTag:employmentTagIpad + labelTagPaddingIpad];
    [self.view addSubview:self.employmentServicesLabel];
    
    self.shelterAdminLabel = [[[CustomToolbarLabel alloc] initWithFrame:CGRectMake(self.shelterAdminButton.frame.origin.x, self.shelterAdminButton.frame.origin.y + self.shelterAdminButton.frame.size.height - 13, self.shelterAdminButton.frame.size.width, 10)] autorelease];
    [self.shelterAdminLabel setText:@"Caregiver"];
    [self.shelterAdminLabel setTag:adminTagIpad + labelTagPaddingIpad];
    [self.view addSubview:self.shelterAdminLabel];
}

- (void)setUpMapView
{
    self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 250)] autorelease];
    
    [self.mapView setDelegate:self];
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 25000, 25000);
    [self.mapView setRegion:region animated:YES];
    [self.mapView setShowsUserLocation:YES];
    [self.view addSubview:self.mapView];
}

- (void)setUpWebView
{
    self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.toolbar.frame.size.height)] autorelease];
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    [self.webView.scrollView setScrollEnabled:YES];
    [self.webView.scrollView setBounces:YES];
}

- (void)setUpButtons
{
    self.directionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *directionsImage = [UIImage imageNamed:@"directionsButton.png"];
    [self.directionsButton setFrame:CGRectMake(self.view.frame.size.width - directionsImage.size.width - 10, self.mapView.frame.origin.y + self.mapView.frame.size.height + 20, directionsImage.size.width, directionsImage.size.height)];
    [self.directionsButton setBackgroundImage:directionsImage forState:UIControlStateNormal];
    [self.directionsButton setBackgroundImage:[UIImage imageNamed:@"directionsButtonTapped.png"] forState:UIControlStateSelected];
    [self.directionsButton setUserInteractionEnabled:YES];
    [self.directionsButton setEnabled:YES];
    [self.directionsButton addTarget:self action:@selector(getDirections:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.directionsButton];
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.callButton setFrame:CGRectMake(self.directionsButton.frame.origin.x, self.directionsButton.frame.origin.y + self.directionsButton.frame.size.height + 20, self.directionsButton.frame.size.width, self.directionsButton.frame.size.height)];
    [self.callButton setBackgroundImage:[UIImage imageNamed:@"callButton.png"] forState:UIControlStateNormal];
    [self.callButton setBackgroundImage:[UIImage imageNamed:@"callButtonTapped.png"] forState:UIControlStateSelected];
    [self.callButton setUserInteractionEnabled:YES];
    [self.callButton setEnabled:YES];
    [self.callButton addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.callButton];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setFrame:CGRectMake(self.callButton.frame.origin.x, self.callButton.frame.origin.y + self.callButton.frame.size.height + 20, self.callButton.frame.size.width, self.callButton.frame.size.height)];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton.png"] forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"shareButtonTapped.png"] forState:UIControlStateSelected];
    [self.shareButton setUserInteractionEnabled:YES];
    [self.shareButton setEnabled:YES];
    [self.shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
}

- (void)setUpInfoBoxes
{
    UIImage *image1 = [UIImage imageNamed:@"topInfoBoxIpad.png"];
    self.topInfoBox = [[[UIImageView alloc] initWithFrame:CGRectMake(self.mapView.frame.origin.x + 10, self.mapView.frame.origin.y + self.mapView.frame.size.height + 10, image1.size.width, self.view.frame.size.height - self.mapView.frame.size.height - self.toolbar.frame.size.height - 20)] autorelease];
    [self.topInfoBox setImage:image1];
    [self.topInfoBox setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:self.topInfoBox];
    
    self.bottomInfoBox = [[[UIImageView alloc] initWithFrame:CGRectMake(self.topInfoBox.frame.origin.x + self.topInfoBox.frame.size.width + 10, self.topInfoBox.frame.origin.y, self.view.frame.size.width - self.topInfoBox.frame.size.width - self.directionsButton.frame.size.width - 40, self.topInfoBox.frame.size.height)] autorelease];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.bottomInfoBox setImage:[UIImage imageNamed:@"bottomInfoBoxIpadLandscape.png"]];
    } else {
        [self.bottomInfoBox setImage:[UIImage imageNamed:@"bottomInfoBoxIpadPortrait.png"]];
    }
    [self.bottomInfoBox setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:self.bottomInfoBox];
}

- (void)setUpLabelsAndTextViews
{
    self.nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.topInfoBox.frame.origin.x, self.topInfoBox.frame.origin.y, self.topInfoBox.frame.size.width, 40)] autorelease];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    [self.nameLabel setFont:[UIFont fontWithName:@"Vollkorn-BoldItalic" size:18]];
    [self.nameLabel setMinimumFontSize:10];
    [self.nameLabel setAdjustsFontSizeToFitWidth:YES];
    [self.nameLabel setShadowColor:kHomelessHelperMediumBlue];
    [self.nameLabel setTextAlignment:UITextAlignmentCenter];
    [self.nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.nameLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.nameLabel];
    
    self.addressLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height, self.nameLabel.frame.size.width, self.topInfoBox.frame.size.height - self.nameLabel.frame.size.height)] autorelease];
    [self.addressLabel setTextColor:kHomelessHelperDarkBlue];
    [self.addressLabel setFont:[UIFont fontWithName:@"Vollkorn" size:15]];
    [self.addressLabel setNumberOfLines:4];
    [self.addressLabel setMinimumFontSize:10];
    [self.addressLabel setAdjustsFontSizeToFitWidth:YES];
    [self.addressLabel setTextAlignment:UITextAlignmentCenter];
    [self.addressLabel setBackgroundColor:[UIColor clearColor]];
    [self.addressLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:self.addressLabel];
    
    self.bedsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.bottomInfoBox.frame.origin.x, self.bottomInfoBox.frame.origin.y, self.bottomInfoBox.frame.size.width, 30)] autorelease];
    [self.bedsLabel setTextColor:kHomelessHelperDarkBlue];
    [self.bedsLabel setFont:[UIFont fontWithName:@"Vollkorn-BoldItalic" size:18]];
    [self.bedsLabel setMinimumFontSize:10];
    [self.bedsLabel setAdjustsFontSizeToFitWidth:YES];
    [self.bedsLabel setTextAlignment:UITextAlignmentCenter];
    [self.bedsLabel setBackgroundColor:[UIColor clearColor]];
    [self.bedsLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.bedsLabel];
    
    self.hoursTextView = [[[UITextView alloc] initWithFrame:CGRectMake(self.bottomInfoBox.frame.origin.x, self.bedsLabel.frame.origin.y + self.bedsLabel.frame.size.height, self.bottomInfoBox.frame.size.width / 2, self.bottomInfoBox.frame.size.height - self.bedsLabel.frame.size.height)] autorelease];
    [self.hoursTextView setFont:[UIFont fontWithName:@"Vollkorn-Regular" size:15]];
    [self.hoursTextView setContentInset:UIEdgeInsetsMake(-7, -7, -7, -7)];
    [self.hoursTextView setTextColor:kHomelessHelperMediumBlue];
    [self.hoursTextView setScrollEnabled:YES];
    [self.hoursTextView setBounces:YES];
    [self.hoursTextView setShowsVerticalScrollIndicator:YES];
    [self.hoursTextView setBackgroundColor:[UIColor clearColor]];
    [self.hoursTextView setTextAlignment:UITextAlignmentRight];
    [self.hoursTextView setUserInteractionEnabled:NO];
    [self.hoursTextView setEditable:NO];
    [self.view addSubview:self.hoursTextView];
    
    self.notesTextView = [[[UITextView alloc] initWithFrame:CGRectMake(self.hoursTextView.frame.origin.x + self.hoursTextView.frame.size.width, self.hoursTextView.frame.origin.y, self.bottomInfoBox.frame.size.width / 2, self.hoursTextView.frame.size.height)] autorelease];
    [self.notesTextView setFont:[UIFont fontWithName:@"Vollkorn-Regular" size:12]];
    [self.notesTextView setContentInset:UIEdgeInsetsMake(-7, -7, -7, -7)];
    [self.notesTextView setTextColor:kHomelessHelperMediumBlue];
    [self.notesTextView setScrollEnabled:YES];
    [self.notesTextView setBounces:YES];
    [self.notesTextView setShowsVerticalScrollIndicator:YES];
    [self.notesTextView setBackgroundColor:[UIColor clearColor]];
    [self.notesTextView setTextAlignment:UITextAlignmentLeft];
    [self.notesTextView setUserInteractionEnabled:NO];
    [self.notesTextView setEditable:NO];
    [self.view addSubview:self.notesTextView];
    
    UIImage *vaImage = [UIImage imageNamed:@"va-logo.png"];
    self.vaLogo = [[[UIImageView alloc] initWithFrame:CGRectMake(self.topInfoBox.frame.origin.x + self.topInfoBox.frame.size.width - vaImage.size.width, self.topInfoBox.frame.origin.y + self.topInfoBox.frame.size.height - vaImage.size.height, vaImage.size.width, vaImage.size.height)] autorelease];
    [self.vaLogo setImage:vaImage];
    [self.view addSubview:self.vaLogo];
}

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];
    [self setUpToolbar];
    [self setUpMapView];
    [self setUpWebView];
    [self setUpButtons];
    [self setUpInfoBoxes];
    [self setUpLabelsAndTextViews];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];    

    [self clearInfoBoxes];

//	self.barButtonItemPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.lvc.navigationController];
//	self.barButtonItemPopoverController.popoverContentSize = CGSizeMake(280, 500);
//	self.barButtonItemPopoverController.delegate = self;

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fixToolbarButtonFrames];
    [self fixButtonFrames];
    [self fixInfoBoxFrames];
    [self fixLabelAndTextViewFrames];
    
    if (TARGET_IPHONE_SIMULATOR) {
        [self buttonTapped:self.shelterButton];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self fixToolbarButtonFrames];
    [self fixButtonFrames];
    [self fixInfoBoxFrames];
    [self fixLabelAndTextViewFrames];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_currentResource release];
    [_lvc release];
    [_barButtonItemPopoverController release];
    [_changeLocationPopoverController release];
    [_resourcesArray release];
    [_mapView release];
    [_currentLocation release];
    [_webView release];
    [_toolbar release];
    [_shelterButton release];
    [_foodButton release];
    [_medicalButton release];
    [_hotlinesButton release];
    [_socialServicesButton release];
    [_legalAssistanceButton release];
    [_employmentServicesButton release];
    [_shelterAdminButton release];
    [_shelterLabel release];
    [_foodLabel release];
    [_medicalLabel release];
    [_hotlinesLabel release];
    [_socialServicesLabel release];
    [_legalAssistanceLabel release];
    [_employmentServicesLabel release];
    [_shelterAdminLabel release];
    [_alertString release];
    [_directionsButton release];
    [_callButton release];
    [_shareButton release];
    [_topInfoBox release];
    [_bottomInfoBox release];
    [_nameLabel release];
    [_addressLabel release];
    [_bedsLabel release];
    [_hoursTextView release];
    [_notesTextView release];
    [_vaLogo release];
    [super dealloc];
}

#pragma mark -
#pragma mark SPLITVIEWCONTROLLER

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{    
    barButtonItem.title = @"";
    
    UIImageView *popoverButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarPopoverButton.png"]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:barButtonItem.target action:barButtonItem.action];
    [popoverButtonView setUserInteractionEnabled:YES];
    [popoverButtonView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    barButtonItem.customView = popoverButtonView;
    [popoverButtonView release];

    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.barButtonItemPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
    
    self.barButtonItemPopoverController = nil;
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    if (self.changeLocationPopoverController.popoverVisible) {
        [self.changeLocationPopoverController dismissPopoverAnimated:YES];
    }
    
//    if ([self.barButtonItemPopoverController isPopoverVisible]) {
//        [self.barButtonItemPopoverController dismissPopoverAnimated:YES];
//    }
    
//    self.barButtonItemPopoverController = pc;
}
/*
- (void)showPopoverFromBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.barButtonItemPopoverController.popoverVisible == NO) {
        [self.barButtonItemPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self.barButtonItemPopoverController dismissPopoverAnimated:YES];
    }
}
*/
#pragma mark -
#pragma mark MAPVIEW

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    DLog(@"SELECTED VIEW: %@", view.annotation);
    
    ResourceAnnotation *anno = (ResourceAnnotation *)view.annotation;
    
    if ([anno isKindOfClass:[MKUserLocation class]]) {
        return;
    } else if ([self.lvc.category isEqualToString:@"Jobs & Volunteer Opps"]) {
        [self.lvc setCurrentResource:[self.lvc.gigsArray objectAtIndex:anno.tag]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:anno.tag inSection:0];
        
        [self.lvc.resourcesTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self displayData];
    } else {
        [self.lvc setCurrentResource:[self.lvc.resourcesArray objectAtIndex:anno.tag]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:anno.tag inSection:0];
        
        [self.lvc.resourcesTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self displayData];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation) {
        return nil;
    } else {
        MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
        if (pinAnnotation == nil) {
            pinAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotationView"] autorelease];
            
            pinAnnotation.canShowCallout = YES;
        } else {
            pinAnnotation.annotation = annotation;
        }
        
        return pinAnnotation;
    }
}

#pragma mark -
#pragma mark TOOLBAR BUTTONS

- (void)resetButtons
{
    [self.shelterButton setBackgroundImage:[UIImage imageNamed:@"toolbarShelterIcon.png"] forState:UIControlStateNormal];
    [self.foodButton setBackgroundImage:[UIImage imageNamed:@"toolbarFoodIcon.png"] forState:UIControlStateNormal];
    [self.medicalButton setBackgroundImage:[UIImage imageNamed:@"toolbarMedicalIcon.png"] forState:UIControlStateNormal];
    [self.hotlinesButton setBackgroundImage:[UIImage imageNamed:@"toolbarHotlinesIcon.png"] forState:UIControlStateNormal];
    [self.legalAssistanceButton setBackgroundImage:[UIImage imageNamed:@"toolbarLegalAssistanceIcon.png"] forState:UIControlStateNormal];
    [self.socialServicesButton setBackgroundImage:[UIImage imageNamed:@"toolbarSocialServicesIcon.png"] forState:UIControlStateNormal];
    [self.employmentServicesButton setBackgroundImage:[UIImage imageNamed:@"toolbarEmploymentServicesIcon.png"] forState:UIControlStateNormal];
    [self.shelterAdminButton setBackgroundImage:[UIImage imageNamed:@"toolbarShelterAdminIcon.png"] forState:UIControlStateNormal];
    [self.shelterLabel setTextColor:kHomelessHelperDarkBlue];
    [self.foodLabel setTextColor:kHomelessHelperDarkBlue];
    [self.medicalLabel setTextColor:kHomelessHelperDarkBlue];
    [self.hotlinesLabel setTextColor:kHomelessHelperDarkBlue];
    [self.socialServicesLabel setTextColor:kHomelessHelperDarkBlue];
    [self.legalAssistanceLabel setTextColor:kHomelessHelperDarkBlue];
    [self.employmentServicesLabel setTextColor:kHomelessHelperDarkBlue];
    [self.shelterAdminLabel setTextColor:kHomelessHelperDarkBlue];
}

- (void)fixToolbarButtonFrames
{
    int spaceBetweenIcons = (self.toolbar.frame.size.width - 560) / 9;
    int spaceOnEnds = (self.toolbar.frame.size.width - 560 - spaceBetweenIcons * 7) / 2;
    
    [self.shelterButton setFrame:CGRectMake(self.toolbar.frame.origin.x + spaceOnEnds, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.foodButton setFrame:CGRectMake(self.shelterButton.frame.origin.x + self.shelterButton.frame.size.width + spaceBetweenIcons, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.medicalButton setFrame:CGRectMake(self.foodButton.frame.origin.x + self.foodButton.frame.size.width + spaceBetweenIcons, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.hotlinesButton setFrame:CGRectMake(self.medicalButton.frame.origin.x + self.medicalButton.frame.size.width + spaceBetweenIcons, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.legalAssistanceButton setFrame:CGRectMake(self.hotlinesButton.frame.origin.x + self.hotlinesButton.frame.size.width + spaceBetweenIcons, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.socialServicesButton setFrame:CGRectMake(self.legalAssistanceButton.frame.origin.x + self.legalAssistanceButton.frame.size.width + spaceBetweenIcons, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.employmentServicesButton setFrame:CGRectMake(self.socialServicesButton.frame.origin.x + self.socialServicesButton.frame.size.width + spaceBetweenIcons, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.shelterAdminButton setFrame:CGRectMake(self.employmentServicesButton.frame.origin.x + self.employmentServicesButton.frame.size.width + spaceBetweenIcons, self.toolbar.frame.origin.y, 70, self.toolbar.frame.size.height)];
    [self.shelterLabel setFrame:CGRectMake(self.shelterButton.frame.origin.x, self.shelterButton.frame.origin.y + self.shelterButton.frame.size.height - 13, self.shelterButton.frame.size.width, 10)];
    [self.foodLabel setFrame:CGRectMake(self.foodButton.frame.origin.x, self.foodButton.frame.origin.y + self.foodButton.frame.size.height - 13, self.foodButton.frame.size.width, 10)];
    [self.medicalLabel setFrame:CGRectMake(self.medicalButton.frame.origin.x, self.medicalButton.frame.origin.y + self.medicalButton.frame.size.height - 13, self.medicalButton.frame.size.width, 10)];
    [self.hotlinesLabel setFrame:CGRectMake(self.hotlinesButton.frame.origin.x, self.hotlinesButton.frame.origin.y + self.hotlinesButton.frame.size.height - 13, self.hotlinesButton.frame.size.width, 10)];
    [self.legalAssistanceLabel setFrame:CGRectMake(self.legalAssistanceButton.frame.origin.x, self.legalAssistanceButton.frame.origin.y + self.legalAssistanceButton.frame.size.height - 13, self.legalAssistanceButton.frame.size.width, 10)];
    [self.socialServicesLabel setFrame:CGRectMake(self.socialServicesButton.frame.origin.x, self.socialServicesButton.frame.origin.y + self.socialServicesButton.frame.size.height - 13, self.socialServicesButton.frame.size.width, 10)];
    [self.employmentServicesLabel setFrame:CGRectMake(self.employmentServicesButton.frame.origin.x, self.employmentServicesButton.frame.origin.y + self.employmentServicesButton.frame.size.height - 13, self.employmentServicesButton.frame.size.width, 10)];
    [self.shelterAdminLabel setFrame:CGRectMake(self.shelterAdminButton.frame.origin.x, self.shelterAdminButton.frame.origin.y + self.shelterAdminButton.frame.size.height - 13, self.shelterAdminButton.frame.size.width, 10)];
}

- (void)fixButtonFrames
{
    UIImage *directionsImage = [UIImage imageNamed:@"directionsButton.png"];
    [self.directionsButton setFrame:CGRectMake(self.view.frame.size.width - directionsImage.size.width - 10, self.mapView.frame.origin.y + self.mapView.frame.size.height + 20, directionsImage.size.width, directionsImage.size.height)];
    
    [self.callButton setFrame:CGRectMake(self.directionsButton.frame.origin.x, self.directionsButton.frame.origin.y + self.directionsButton.frame.size.height + 20, self.directionsButton.frame.size.width, self.directionsButton.frame.size.height)];
    
    [self.shareButton setFrame:CGRectMake(self.callButton.frame.origin.x, self.callButton.frame.origin.y + self.callButton.frame.size.height + 20, self.callButton.frame.size.width, self.callButton.frame.size.height)];
}

- (void)fixInfoBoxFrames
{
    UIImage *image1 = [UIImage imageNamed:@"topInfoBoxIpad.png"];
    [self.topInfoBox setFrame:CGRectMake(self.mapView.frame.origin.x + 10, self.mapView.frame.origin.y + self.mapView.frame.size.height + 10, image1.size.width, self.view.frame.size.height - self.mapView.frame.size.height - self.toolbar.frame.size.height - 20)];
    
    [self.bottomInfoBox setFrame:CGRectMake(self.topInfoBox.frame.origin.x + self.topInfoBox.frame.size.width + 10, self.topInfoBox.frame.origin.y, self.view.frame.size.width - self.topInfoBox.frame.size.width - self.directionsButton.frame.size.width - 40, self.topInfoBox.frame.size.height)];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.bottomInfoBox setImage:[UIImage imageNamed:@"bottomInfoBoxIpadLandscape.png"]];
    } else {
        [self.bottomInfoBox setImage:[UIImage imageNamed:@"bottomInfoBoxIpadPortrait.png"]];
    }
}

- (void)fixLabelAndTextViewFrames
{
    [self.nameLabel setFrame:CGRectMake(self.topInfoBox.frame.origin.x, self.topInfoBox.frame.origin.y, self.topInfoBox.frame.size.width, 40)];
    [self.addressLabel setFrame:CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height, self.nameLabel.frame.size.width, self.topInfoBox.frame.size.height - self.nameLabel.frame.size.height)];
    [self.bedsLabel setFrame:CGRectMake(self.bottomInfoBox.frame.origin.x, self.bottomInfoBox.frame.origin.y, self.bottomInfoBox.frame.size.width, 30)];
    
    UIImage *vaImage = [UIImage imageNamed:@"va-logo.png"];
    [self.vaLogo setFrame:CGRectMake(self.topInfoBox.frame.origin.x + self.topInfoBox.frame.size.width - vaImage.size.width, self.topInfoBox.frame.origin.y + self.topInfoBox.frame.size.height - vaImage.size.height, vaImage.size.width, vaImage.size.height)];
    
    if ([[self.currentResource resourceType] isEqualToString:@"shelter"]) {
        [self.hoursTextView setFrame:CGRectMake(self.bottomInfoBox.frame.origin.x, self.bedsLabel.frame.origin.y + self.bedsLabel.frame.size.height, self.bottomInfoBox.frame.size.width / 2, self.bottomInfoBox.frame.size.height - self.bedsLabel.frame.size.height)];
        [self.notesTextView setFrame:CGRectMake(self.hoursTextView.frame.origin.x + self.hoursTextView.frame.size.width, self.hoursTextView.frame.origin.y, self.bottomInfoBox.frame.size.width / 2, self.hoursTextView.frame.size.height)];
    } else if ([[self.currentResource resourceType] isEqualToString:@"Jobs & Volunteer Opps"]) {
        [self.notesTextView setFrame:CGRectMake(self.bottomInfoBox.frame.origin.x, self.bedsLabel.frame.origin.y + self.bedsLabel.frame.size.height, self.bottomInfoBox.frame.size.width, self.bottomInfoBox.frame.size.height - self.bedsLabel.frame.size.height)];
    } else {
        [self.hoursTextView setFrame:CGRectMake(self.bottomInfoBox.frame.origin.x, self.bottomInfoBox.frame.origin.y, self.bottomInfoBox.frame.size.width / 2, self.bottomInfoBox.frame.size.height)];
        [self.notesTextView setFrame:CGRectMake(self.hoursTextView.frame.origin.x + self.hoursTextView.frame.size.width, self.hoursTextView.frame.origin.y, self.bottomInfoBox.frame.size.width / 2, self.hoursTextView.frame.size.height)];
    }
}

#pragma mark -
#pragma mark INSTANTIATION

- (LeftSideViewController *)lvc
{
    if (_lvc) {
        _lvc = [[LeftSideViewController alloc] init];
    }
    AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
    NSArray *vcArray = del.splitViewController.viewControllers;
    UINavigationController *nvc = [vcArray objectAtIndex:0];
    _lvc = [nvc.viewControllers objectAtIndex:0];
    return _lvc;
}

- (void)setLvc:(LeftSideViewController *)lvc
{
    AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
    NSArray *vcArray = del.splitViewController.viewControllers;
    UINavigationController *nvc = [vcArray objectAtIndex:0];
    lvc = [nvc.viewControllers objectAtIndex:0];
    _lvc = lvc;
}

- (NSMutableArray *)resourcesArray
{
    if (_resourcesArray) {
        _resourcesArray = [[NSMutableArray alloc] init];
    }
    _resourcesArray = self.lvc.resourcesArray;
    return _resourcesArray;
}

- (void)setResourcesArray:(NSMutableArray *)resourcesArray
{
    self.lvc.resourcesArray = resourcesArray;
    _resourcesArray = resourcesArray;
}

- (Resource *)currentResource
{
    if (_currentResource) {
        _currentResource = [[Resource alloc] init];
    }
    _currentResource = self.lvc.currentResource;
    return _currentResource;
}

- (void)setCurrentResource:(Resource *)currentResource
{
    self.lvc.currentResource = currentResource;
    _currentResource = currentResource;
}

@end