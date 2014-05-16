//
//  ListViewController.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/22/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController

@synthesize vc3 = _vc3;
@synthesize vc4 = _vc4;
@synthesize category = _category;
@synthesize sortingLabel = _sortingLabel;
@synthesize resourcesTableView = _resourcesTableView;
@synthesize resourcesArray = _resourcesArray;
@synthesize mapView = _mapView;
@synthesize currentLocation = _currentLocation;

#pragma mark -
#pragma mark LIST JOBS

- (void)listResourcesAction:(NSString *)category
{
    Resource *currentResource = [[Resource alloc] init];
    [currentResource setDelegate:self];
    [currentResource listResourcesForCategory:category withLatitude:[NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude] andLongitude:[NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude]];
}

- (void)listResourcesActionFinish:(NSMutableArray *)jobsArray
{
    if ([[self.resourcesTableView cellForRowAtIndexPath:[self.resourcesTableView indexPathForSelectedRow]] tag] == 998) {
        self.vc3 = [[[JobsListViewController alloc] initWithNibName:@"JobsListViewController" bundle:nil] autorelease];
        [self.vc3.jobsArray removeAllObjects];
        [self.vc3 setJobsArray:jobsArray];
        [self.navigationController pushViewController:self.vc3 animated:YES];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:[self.resourcesTableView indexPathForSelectedRow]] tag] == 997) {
        self.vc4 = [[[GigsListViewController alloc] init] autorelease];
        [self.vc4.gigsArray removeAllObjects];
        [self.vc4 setGigsArray:jobsArray];
        [self.navigationController pushViewController:self.vc4 animated:YES];
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
        
//        UIImage *tableCellAccessory = [UIImage imageNamed:@"tableCellAccessory.png"];
        
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
        [self listResourcesAction:@"job"];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 997) {
        [self listResourcesAction:@"job_gig"];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 996) {
        PostGigsViewController *vc3 = [[PostGigsViewController alloc] initWithNibName:nil bundle:nil];
        [vc3 setCategory:@"Post Job & Volunteer Opps"];
        [self.navigationController pushViewController:vc3 animated:YES];
        [vc3 release];
    } else {
        if ([self.category isEqualToString:@"Hotlines"]) {
            HotlineProfileViewController *vc1 = [[HotlineProfileViewController alloc] init];
            [vc1 setCurrentResource:[self.resourcesArray objectAtIndex:[indexPath row]]];
            [vc1 setCategory:self.category];
            [self.navigationController pushViewController:vc1 animated:YES];
            [vc1 release];
        } else {
            ProfileViewController *vc = [[ProfileViewController alloc] init];
            [vc setCurrentResource:[self.resourcesArray objectAtIndex:[indexPath row]]];
            [vc setCategory:self.category];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
    }
}

- (void)action:(id)sender forEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.resourcesTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.resourcesTableView]];
    
    [self.resourcesTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    DLog(@"OTHER METHOD: Tapped Accessory Button on row %i", [indexPath row] + 1);
    
    if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 998) {
        [self listResourcesAction:@"job"];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 997) {
        [self listResourcesAction:@"job_gig"];
    } else if ([[self.resourcesTableView cellForRowAtIndexPath:indexPath] tag] == 996) {
        PostGigsViewController *vc3 = [[PostGigsViewController alloc] initWithNibName:nil bundle:nil];
        [vc3 setCategory:@"Post Job & Volunteer Opps"];
        [self.navigationController pushViewController:vc3 animated:YES];
        [vc3 release];
    } else {
        if ([self.category isEqualToString:@"Hotlines"]) {
            HotlineProfileViewController *vc1 = [[HotlineProfileViewController alloc] init];
            [vc1 setCurrentResource:[self.resourcesArray objectAtIndex:[indexPath row]]];
            [vc1 setCategory:self.category];
            [self.navigationController pushViewController:vc1 animated:YES];
            [vc1 release];
        } else {
            ProfileViewController *vc = [[ProfileViewController alloc] init];
            [vc setCurrentResource:[self.resourcesArray objectAtIndex:[indexPath row]]];
            [vc setCategory:self.category];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
    }
}

#pragma mark -
#pragma mark VIEW CONTROL

- (void)dismissView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)animateMapView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [self.view addSubview:self.mapView];
    [UIView commitAnimations];
    
    [self showMapView];
}

- (void)showMapView
{
    UIImageView *listButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarListViewButton.png"]];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showListView)];
    [listButtonView setUserInteractionEnabled:YES];
    [listButtonView addGestureRecognizer:tapGesture2];
    [tapGesture2 release];
    
    UIBarButtonItem *listBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:listButtonView];
    [listButtonView release];
    
    [[self navigationItem] setRightBarButtonItem:listBarButtonItem];
    
    [listBarButtonItem release];
    
    [self.mapView removeAnnotations:[self.mapView annotations]];

    for (int i = 0; i < self.resourcesArray.count; i++) {
        Resource *resource = [self.resourcesArray objectAtIndex:i];
        [self.mapView addAnnotation:resource.annotation];
        [resource.annotation setTag:i];
    }
/*
    int i = 0;
    
    for (Resource *resource in self.resourcesArray) {
        [self.mapView addAnnotation:resource.annotation];
        [resource.annotation setTag:i];
        i = i++;
    }
*/    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"map_shown"];
    
    [self.mapView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)showListView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [self.mapView removeFromSuperview];
    [UIView commitAnimations];
    
    UIImageView *mapButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarMapViewButton.png"]];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateMapView)];
    [mapButtonView setUserInteractionEnabled:YES];
    [mapButtonView addGestureRecognizer:tapGesture2];
    [tapGesture2 release];
    
    UIBarButtonItem *mapBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapButtonView];
    [mapButtonView release];
    
    [[self navigationItem] setRightBarButtonItem:mapBarButtonItem];
    
    [mapBarButtonItem release];
    
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"map_shown"];
}

#pragma mark -
#pragma mark INITIAL VIEW SETUP

- (void)setUpNavBar
{
    [self.navigationItem setTitle:self.category];

    UIImageView *backButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarBackButton.png"]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [backButtonView setUserInteractionEnabled:YES];
    [backButtonView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    [backButtonView release];        
    
    [[self navigationItem] setLeftBarButtonItem:backBarButtonItem];
    
    [backBarButtonItem release];
    
    if (![self.category isEqualToString:@"Hotlines"]) {
        UIImageView *mapButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarMapViewButton.png"]];
        UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateMapView)];
        [mapButtonView setUserInteractionEnabled:YES];
        [mapButtonView addGestureRecognizer:tapGesture2];
        [tapGesture2 release];
        
        UIBarButtonItem *mapBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapButtonView];
        [mapButtonView release];
        
        [[self navigationItem] setRightBarButtonItem:mapBarButtonItem];
        
        [mapBarButtonItem release];
    }
}

- (void)setUpMapView
{
    self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    
    [self.mapView setDelegate:self];
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 25000, 25000);
    [self.mapView setRegion:region animated:YES];
    [self.mapView setShowsUserLocation:YES];
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
    
    // set up tableview
    self.resourcesTableView = [[[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 20, self.view.frame.size.width, self.view.frame.size.height - 20)] autorelease];
    [self.resourcesTableView setDataSource:self];
    [self.resourcesTableView setDelegate:self];
    [self.resourcesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.resourcesTableView setBackgroundColor:[UIColor clearColor]];
    [self.resourcesTableView setRowHeight:62];
    [self.resourcesTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:self.resourcesTableView];
    
    // set up label
    self.sortingLabel = [[[CustomServicesLabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 20)] autorelease];
    [self.view addSubview:self.sortingLabel];
    
    [self setUpMapView];
 
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.resourcesArray count] == 0) {
        [self.sortingLabel setText:@""];
        [self.resourcesTableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    } else if ([self.category isEqualToString:@"Hotlines"]) {
        [self.sortingLabel setText:@""];
        [self.resourcesTableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    } else {
        [self.sortingLabel setText:@"Results sorted by distance (closest to farthest)"];
        [self.resourcesTableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 20, self.view.frame.size.width, self.view.frame.size.height - 20)];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"map_shown"] isEqualToString:@"YES"] && ![self.category isEqualToString:@"Hotlines"]) {
        [self.view addSubview:self.mapView];
        [self showMapView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{    
    [self.resourcesTableView reloadData];
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
    [_vc3 release];
    [_vc4 release];
    [_category release];
    [_sortingLabel release];
    [_resourcesTableView release];
    [_resourcesArray release];
    [_mapView release];
    [_currentLocation release];
    [super dealloc];
}

#pragma mark -
#pragma mark MAPVIEW

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    DLog(@"SELECTED VIEW: %@", view.annotation);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{    
    ProfileViewController *vc = [[ProfileViewController alloc] init];
    ResourceAnnotation *anno = (ResourceAnnotation *)view.annotation;
    [vc setCurrentResource:[self.resourcesArray objectAtIndex:anno.tag]];
    [vc setCategory:self.category];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation) {
        return nil;
    } else {
        MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
        if (pinAnnotation == nil) {
            pinAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotationView"] autorelease];
            
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinAnnotation.canShowCallout = YES;
            pinAnnotation.rightCalloutAccessoryView = infoButton;
        } else {
            pinAnnotation.annotation = annotation;
        }
        
        return pinAnnotation;
    }
}

@end