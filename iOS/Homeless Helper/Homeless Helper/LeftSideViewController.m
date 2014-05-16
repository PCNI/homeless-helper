//
//  LeftSideViewController.m
//  Homeless Helper
//
//  Created by Jessi on 9/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "LeftSideViewController.h"

@interface LeftSideViewController ()

@end

@implementation LeftSideViewController

@synthesize currentResource = _currentResource;
@synthesize rvc = _rvc;
@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;
@synthesize category = _category;
@synthesize resourcesTableView = _resourcesTableView;
@synthesize resourcesArray = _resourcesArray, gigsArray = _gigsArray;

#pragma mark -
#pragma mark RESOURCES/LIST

- (void)listResourcesActionForCategory:(NSString *)category
                          withLocation:(CLLocation *)location
{
    [self.navigationItem setTitle:self.category];
    
    NSString *latString = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    
    NSString *longString = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    Resource *aResource = [[Resource alloc] init];
    [aResource setDelegate:self];
    
    [aResource listResourcesForCategory:category withLatitude:latString andLongitude:longString];
}

- (void)listResourcesActionFinish:(NSMutableArray *)resourcesArray
{
    if ([self.category isEqualToString:@"Jobs"]) {
        LeftSideJobsViewController *vc3 = [[[LeftSideJobsViewController alloc] initWithNibName:@"LeftSideJobsViewController" bundle:nil] autorelease];
        [vc3.jobsArray removeAllObjects];
        [vc3 setJobsArray:resourcesArray];
        [self.navigationController pushViewController:vc3 animated:YES];
    } else if ([self.category isEqualToString:@"Jobs & Volunteer Opps"]) {
        LeftSideGigsViewController *vc4 = [[[LeftSideGigsViewController alloc] init] autorelease];
        [vc4.gigsArray removeAllObjects];
        [vc4 setGigsArray:resourcesArray];
        [self setGigsArray:vc4.gigsArray];
        [self.rvc showMapAnnotations];
        [self.navigationController pushViewController:vc4 animated:YES];
    } else {
        [self.resourcesArray removeAllObjects];
        [self setResourcesArray:resourcesArray];
        [self.resourcesTableView reloadData];
        [self.rvc showMapAnnotations];
    }
}

#pragma mark -
#pragma mark TABLEVIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.category isEqualToString:@"Employment"]) {
        return [self.resourcesArray count] + 3;
    } else if ([self.resourcesArray count] > 0) {
        return [self.resourcesArray count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
    NSInteger row = [indexPath row];
    
    if ([self.resourcesArray count] == 0) {
        static NSString *NoResultsCellIdentifier = @"NoResultsCell";
        UITableViewCell *basicCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoResultsCellIdentifier] autorelease];

        [basicCell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackground.png"]] autorelease]];
        
        [basicCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [basicCell setTag:999];
        
        [[basicCell textLabel] setBackgroundColor:[UIColor clearColor]];
        [[basicCell textLabel] setTextColor:kHomelessHelperDarkBlue];
        [[basicCell textLabel] setFont:[UIFont fontWithName:@"Vollkorn-Bold" size:16]];
        
		[[basicCell textLabel] setText:@"No resources found"];
		
		return basicCell;
    } else if ([self.category isEqualToString:@"Employment"] && row == sectionRows - 3) {
        static NSString *jobsCellIdentifier = @"jobsCell";
        CustomListTableViewCell *cell = (CustomListTableViewCell *)[self.resourcesTableView dequeueReusableCellWithIdentifier:jobsCellIdentifier];
        if (cell == nil) {
            cell = [[[CustomListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jobsCellIdentifier] autorelease];
            UIButton *accessory = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *accessoryImage = [UIImage imageNamed:@"tableCellAccessory.png"];
            UIImage *accessorySelectedImage = [UIImage imageNamed:@"tableCellAccessorySelected.png"];
            [accessory setImage:accessoryImage forState:UIControlStateNormal];
            [accessory setImage:accessorySelectedImage forState:UIControlStateSelected];
            [accessory setImage:accessorySelectedImage forState:UIControlStateHighlighted];
            [accessory setFrame:CGRectMake(cell.frame.size.width - accessoryImage.size.width * 2, 0, accessoryImage.size.width, accessoryImage.size.height)];
            [accessory setUserInteractionEnabled:YES];
            [accessory addTarget:self action:@selector(action:forEvent:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:accessory];
            [cell setAutoresizesSubviews:YES];
            [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackground.png"]] autorelease]];
            [cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackgroundSelected.png"]] autorelease]];
            [cell setTag:998];
            
            [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
            [[cell textLabel] setTextColor:kHomelessHelperDarkBlue];
            [[cell textLabel] setFont:[UIFont fontWithName:@"Vollkorn-Bold" size:16]];
            
            [[cell textLabel] setText:@"View internet job listings"];
        }
        return cell;
        
    } else if ([self.category isEqualToString:@"Employment"] && row == sectionRows - 2) {
        static NSString *gigsCellIdentifier = @"gigsCell";
        CustomListTableViewCell *cell = (CustomListTableViewCell *)[self.resourcesTableView dequeueReusableCellWithIdentifier:gigsCellIdentifier];
        if (cell == nil) {
            cell = [[[CustomListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:gigsCellIdentifier] autorelease];
            UIButton *accessory = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *accessoryImage = [UIImage imageNamed:@"tableCellAccessory.png"];
            UIImage *accessorySelectedImage = [UIImage imageNamed:@"tableCellAccessorySelected.png"];
            [accessory setImage:accessoryImage forState:UIControlStateNormal];
            [accessory setImage:accessorySelectedImage forState:UIControlStateSelected];
            [accessory setImage:accessorySelectedImage forState:UIControlStateHighlighted];
            [accessory setFrame:CGRectMake(cell.frame.size.width - accessoryImage.size.width * 2, 0, accessoryImage.size.width, accessoryImage.size.height)];
            [accessory setUserInteractionEnabled:YES];
            [accessory addTarget:self action:@selector(action:forEvent:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:accessory];
            [cell setAutoresizesSubviews:YES];
            [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackground.png"]] autorelease]];
            [cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackgroundSelected.png"]] autorelease]];
            [cell setTag:997];
            
            [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
            [[cell textLabel] setTextColor:kHomelessHelperDarkBlue];
            [[cell textLabel] setFont:[UIFont fontWithName:@"Vollkorn-Bold" size:16]];
            
            [[cell textLabel] setText:@"View local job and volunteer opportunities"];
            [[cell textLabel] setNumberOfLines:2];
        }
        return cell;
        
    } else if ([self.category isEqualToString:@"Employment"] && row == sectionRows - 1) {
        static NSString *postGigsCellIdentifier = @"postGigsCell";
        CustomListTableViewCell *cell = (CustomListTableViewCell *)[self.resourcesTableView dequeueReusableCellWithIdentifier:postGigsCellIdentifier];
        if (cell == nil) {
            cell = [[[CustomListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postGigsCellIdentifier] autorelease];
            UIButton *accessory = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *accessoryImage = [UIImage imageNamed:@"tableCellAccessory.png"];
            UIImage *accessorySelectedImage = [UIImage imageNamed:@"tableCellAccessorySelected.png"];
            [accessory setImage:accessoryImage forState:UIControlStateNormal];
            [accessory setImage:accessorySelectedImage forState:UIControlStateSelected];
            [accessory setImage:accessorySelectedImage forState:UIControlStateHighlighted];
            [accessory setFrame:CGRectMake(cell.frame.size.width - accessoryImage.size.width * 2, 0, accessoryImage.size.width, accessoryImage.size.height)];
            [accessory setUserInteractionEnabled:YES];
            [accessory addTarget:self action:@selector(action:forEvent:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:accessory];
            [cell setAutoresizesSubviews:YES];
            [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackground.png"]] autorelease]];
            [cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackgroundSelected.png"]] autorelease]];
            [cell setTag:996];
            
            [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
            [[cell textLabel] setTextColor:kHomelessHelperDarkBlue];
            [[cell textLabel] setFont:[UIFont fontWithName:@"Vollkorn-Bold" size:16]];
            
            [[cell textLabel] setText:@"Post a job or volunteer opportunity"];
        }
        return cell;
        
    } else {
        static NSString *cellIdentifier = @"CellIdentifier";
        CustomListTableViewCell *cell = (CustomListTableViewCell *)[self.resourcesTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[CustomListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
            UIButton *accessory = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *accessoryImage = [UIImage imageNamed:@"tableCellAccessory.png"];
            UIImage *accessorySelectedImage = [UIImage imageNamed:@"tableCellAccessorySelected.png"];
            [accessory setImage:accessoryImage forState:UIControlStateNormal];
            [accessory setImage:accessorySelectedImage forState:UIControlStateSelected];
            [accessory setImage:accessorySelectedImage forState:UIControlStateHighlighted];
            [accessory setFrame:CGRectMake(cell.frame.size.width - accessoryImage.size.width * 2, 0, accessoryImage.size.width, accessoryImage.size.height)];
            [accessory setUserInteractionEnabled:YES];
            [accessory addTarget:self action:@selector(action:forEvent:) forControlEvents:UIControlEventTouchDown];
            [cell addSubview:accessory];
            [cell setAutoresizesSubviews:YES];
            [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackground.png"]] autorelease]];
            [cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackgroundSelected.png"]] autorelease]];
        }
        
        Resource *resource = [self.resourcesArray objectAtIndex:[indexPath row]];
        [cell setResource:resource atLocation:self.currentLocation];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Selected Row: %i", [indexPath row] + 1);
    
    if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 998) {
        [self.rvc.mapView removeAnnotations:[self.rvc.mapView annotations]];
        [self.rvc clearInfoBoxes];
        [self.rvc removeWebView];
        [self listResourcesActionForCategory:@"job" withLocation:self.currentLocation];
        [self setCategory:@"Jobs"];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 997) {
        [self.rvc.mapView removeAnnotations:[self.rvc.mapView annotations]];
        [self.rvc clearInfoBoxes];
        [self.rvc removeWebView];
        [self listResourcesActionForCategory:@"job_gig" withLocation:self.currentLocation];
        [self setCategory:@"Jobs & Volunteer Opps"];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 996) {
        [self.rvc showWebViewWithUrl:[NSURL URLWithString:kHomelessHelperPostGigsURL]];
    } else {
        [self setCurrentResource:[self.resourcesArray objectAtIndex:[indexPath row]]];
        [self.rvc removeWebView];
        [self.rvc selectMapAnnotation];
        [self.rvc displayData];
    }
}

- (void)action:(id)sender forEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.resourcesTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.resourcesTableView]];
    DLog(@"OTHER METHOD: Tapped Accessory Button on row %i", [indexPath row] + 1);
    
    if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 998) {
        [self.rvc.mapView removeAnnotations:[self.rvc.mapView annotations]];
        [self.rvc clearInfoBoxes];
        [self.rvc removeWebView];
        [self listResourcesActionForCategory:@"job" withLocation:self.currentLocation];
        [self setCategory:@"Jobs"];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 997) {
        [self.rvc.mapView removeAnnotations:[self.rvc.mapView annotations]];
        [self.rvc clearInfoBoxes];
        [self.rvc removeWebView];
        [self listResourcesActionForCategory:@"job_gig" withLocation:self.currentLocation];
        [self setCategory:@"Jobs & Volunteer Opps"];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 996) {
        [self.rvc showWebViewWithUrl:[NSURL URLWithString:kHomelessHelperPostGigsURL]];
    } else {
        [self setCurrentResource:[self.resourcesArray objectAtIndex:[indexPath row]]];
        [self.rvc removeWebView];
        [self.rvc selectMapAnnotation];
        [self.rvc displayData];
    }
}

#pragma mark -
#pragma mark INITIAL VIEW SETUP

- (void)setUpNavBar
{
    [self.navigationItem setTitle:self.category];
}

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.resourcesArray = [[[NSMutableArray alloc] init] autorelease];
        self.currentLocation = [[[CLLocation alloc] init] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    // set up location
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:5];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    self.currentResource = [[[Resource alloc] init] autorelease];
    [self.currentResource setDelegate:self];
    
    if (TARGET_IPHONE_SIMULATOR) {
#ifndef OPENHMIS
//      self.currentLocation = [[CLLocation alloc] initWithLatitude:38.901454 longitude:-77.037506]; // Washington DC
        self.currentLocation = [[[CLLocation alloc] initWithLatitude:40.348482 longitude:-74.075693] autorelease]; // Soul Kitchen
//      self.currentLocation = [[CLLocation alloc] initWithLatitude:47.611024 longitude:-122.330704]; // Seattle
#endif
        
#ifdef OPENHMIS
        self.currentLocation = [[[CLLocation alloc] initWithLatitude:33.762595 longitude:-84.3853] autorelease]; // Atlanta GA
#endif
        self.rvc.currentLocation = self.currentLocation;
        
    } else {
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingLocation];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Enable location services to search resources" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }

    // set up tableview
    self.resourcesTableView = [[[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    [self.resourcesTableView setDataSource:self];
    [self.resourcesTableView setDelegate:self];
    [self.resourcesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.resourcesTableView setBackgroundColor:[UIColor clearColor]];
    [self.resourcesTableView setRowHeight:62];
    [self.resourcesTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:self.resourcesTableView];

    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_currentResource release];
    [_rvc release];
    [_currentLocation release];
    [_locationManager release];
    [_category release];
    [_resourcesTableView release];
    [_resourcesArray release];
    [_gigsArray release];
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
    
    [newLocation retain];
    self.currentLocation = newLocation;
    self.rvc.currentLocation = self.currentLocation;
    
    [self.rvc buttonTapped:self.rvc.shelterButton];
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

- (Resource *)currentResource
{
    if (!_currentResource) {
        _currentResource = [[Resource alloc] init];
        [_currentResource setDelegate:self];
    }
    return _currentResource;
}

- (RightSideViewController *)rvc
{
    if (_rvc) {
        _rvc = [[RightSideViewController alloc] init];
    }
    AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
    NSArray *vcArray = del.splitViewController.viewControllers;
    UINavigationController *nvc = [vcArray objectAtIndex:1];
    _rvc = [nvc.viewControllers objectAtIndex:0];
    return _rvc;
}

- (void)setRvc:(RightSideViewController *)rvc
{
    AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
    NSArray *vcArray = del.splitViewController.viewControllers;
    UINavigationController *nvc = [vcArray objectAtIndex:1];
    rvc = [nvc.viewControllers objectAtIndex:0];
    _rvc = rvc;
}

@end