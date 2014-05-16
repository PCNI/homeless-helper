//
//  LocationSearchViewController.m
//  Homeless Helper
//
//  Created by Jessi on 9/23/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "LocationSearchViewController.h"

@interface LocationSearchViewController ()

@end

@implementation LocationSearchViewController

@synthesize foursquareVenueSearch = _foursquareVenueSearch;
@synthesize googleAddressGeocodingSearch = _googleAddressGeocodingSearch;
@synthesize placeArray = _placeArray;
@synthesize currentLocation = _currentLocation, placeLocation = _placeLocation;
@synthesize doneBarButtonItem = _doneBarButtonItem;
@synthesize placeTypeSegmentedControl = _placeTypeSegmentedControl;
@synthesize searchBar = _searchBar;
@synthesize searchResultsTableView = _searchResultsTableView;
@synthesize mapView = _mapView;
@synthesize defaultRegion = _defaultRegion;
@synthesize placeType = _placeType;

#pragma mark -
#pragma mark SEARCH

- (void)loadSearchResults:(NSMutableArray *)venues
{
    // clear table
    if (self.placeArray) {
        self.placeArray = nil;
    }
    
    self.placeArray = [NSMutableArray arrayWithArray:venues];
    
    [self.searchResultsTableView reloadData];
    [self.searchResultsTableView flashScrollIndicators];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    if ([self.placeType isEqualToString:@"Place"]) {
        NSString *latString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
        NSString *longString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
        
        [self.searchBar resignFirstResponder];
        
        [self.foursquareVenueSearch searchVenues:[aSearchBar text] locationLat:latString locationLong:longString];
    } else if ([self.placeType isEqualToString:@"Address"]) {
        [self.searchBar resignFirstResponder];
        
        [self.googleAddressGeocodingSearch searchAddresses:[aSearchBar text]];
    }
}

- (void)searchByLocation
{
    NSString *latString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
    NSString *longString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
    
    [self.foursquareVenueSearch searchVenues:@"" locationLat:latString locationLong:longString];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    [aSearchBar resignFirstResponder];
}

#pragma mark -
#pragma mark TABLEVIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.placeArray count] > 0) {
        return [self.placeArray count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ([self.placeArray count] == 0) {
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
    } else {
        static NSString *cellIdentifier = @"CellIdentifier";
        CustomListTableViewCell *cell = (CustomListTableViewCell *)[self.searchResultsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[CustomListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
            [cell setAutoresizesSubviews:YES];
            [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackground.png"]] autorelease]];
            [cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackgroundSelected.png"]] autorelease]];
        }
        
        if ([self.placeType isEqualToString:@"Place"]) {
            FoursquareVenueSearch *venue = [self.placeArray objectAtIndex:[indexPath row]];
            [cell setVenue:venue];
        } else if ([self.placeType isEqualToString:@"Address"]) {
            GoogleAddressGeocodingSearch *address = [self.placeArray objectAtIndex:[indexPath row]];
            [cell setAddress:address];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    if ([[self.searchResultsTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else if ([self.placeType isEqualToString:@"Place"]) {
        FoursquareVenueSearch *place = [self.placeArray objectAtIndex:[[self.searchResultsTableView indexPathForSelectedRow] row]];
        self.placeLocation = [[[CLLocation alloc] initWithLatitude:[place.venueLat floatValue] longitude:[place.venueLong floatValue]] autorelease];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([self.placeLocation coordinate], 500, 500);
        [self.mapView setRegion:region animated:YES];
        [self.mapView setShowsUserLocation:NO];
        MapLocation *mp = [[MapLocation alloc] initWithCoordinate:[self.placeLocation coordinate]];
        [self.mapView addAnnotation:mp];
        [mp release];
        [self.doneBarButtonItem setEnabled:YES];
        
    } else if ([self.placeType isEqualToString:@"Address"]) {
        GoogleAddressGeocodingSearch *place = [self.placeArray objectAtIndex:[[self.searchResultsTableView indexPathForSelectedRow] row]];
        self.placeLocation = [[[CLLocation alloc] initWithLatitude:[place.addressLat floatValue] longitude:[place.addressLong floatValue]] autorelease];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([self.placeLocation coordinate], 500, 500);
        [self.mapView setRegion:region animated:YES];
        [self.mapView setShowsUserLocation:NO];
        MapLocation *mp = [[MapLocation alloc] initWithCoordinate:[self.placeLocation coordinate]];
        [self.mapView addAnnotation:mp];
        [mp release];
        [self.doneBarButtonItem setEnabled:YES];
    }
    
    DLog(@"Selected Row: %i", [indexPath row] + 1);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"De-Selected Row: %i", [indexPath row] + 1);
}

#pragma mark -
#pragma mark ACTIONS

- (void)done
{
    // get the index of the visible VC on the stack
    int currentVCIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
    // get a reference to the previous VC
    FirstViewController *prevVC = (FirstViewController *)[self.navigationController.viewControllers objectAtIndex:currentVCIndex - 1];
    
    if ([self.placeType isEqualToString:@"Place"]) {
        [prevVC performSelector:@selector(setVenue:) withObject:[self.placeArray objectAtIndex:[[self.searchResultsTableView indexPathForSelectedRow] row]]];
    } else if ([self.placeType isEqualToString:@"Address"]) {
        [prevVC performSelector:@selector(setAddress:) withObject:[self.placeArray objectAtIndex:[[self.searchResultsTableView indexPathForSelectedRow] row]]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark VIEW CONTROL

- (void)dismissView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark INITIAL VIEW SET UP

- (void)setUpNavBar
{    
    [[self navigationItem] setTitle:@"Place Search"];
    
    UIImageView *doneButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarDoneButton.png"]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(done)];
    [doneButtonView setUserInteractionEnabled:YES];
    [doneButtonView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    self.doneBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:doneButtonView] autorelease];
    [doneButtonView release];
    
    [[self navigationItem] setLeftBarButtonItem:self.doneBarButtonItem];
    [self.doneBarButtonItem setEnabled:NO];

    UIImageView *cancelButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarCancelButton.png"]];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [cancelButtonView setUserInteractionEnabled:YES];
    [cancelButtonView addGestureRecognizer:tapGesture2];
    [tapGesture2 release];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButtonView];
    [cancelButtonView release];
    
    [[self navigationItem] setRightBarButtonItem:cancelBarButtonItem];
    
    [cancelBarButtonItem release];
}

- (void)setUpSegmentedControl
{
    self.placeTypeSegmentedControl = [[[UISegmentedControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 80, self.view.frame.origin.y + 5, 160, 30)] autorelease];
    
    UIImage *segmentSelected = [[UIImage imageNamed:@"segmentedControlSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    UIImage *segmentDeselected = [[UIImage imageNamed:@"segmentedControlDeselected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segmentedControlSelUnsel.png"];
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segmentedControlUnselSel.png"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segmentedControlUnselUnsel.png"];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentDeselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

    [self.placeTypeSegmentedControl setBackgroundColor:[UIColor clearColor]];
    [[UISegmentedControl appearance] setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[UISegmentedControl appearance] setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//    [self.placeTypeSegmentedControl setContentPositionAdjustment:UIOffsetMake(-5, 1) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
//    [self.placeTypeSegmentedControl setContentPositionAdjustment:UIOffsetMake(5, 0) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];
    [self.placeTypeSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.placeTypeSegmentedControl setUserInteractionEnabled:YES];
    [self.placeTypeSegmentedControl insertSegmentWithTitle:@"Address" atIndex:0 animated:NO];
    [self.placeTypeSegmentedControl insertSegmentWithTitle:@"Place" atIndex:1 animated:NO];

    [self.placeTypeSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGB(1.0, 56.0, 79.0), UITextAttributeTextColor, [UIColor lightGrayColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, [UIFont systemFontOfSize:14], UITextAttributeFont, nil] forState:UIControlStateNormal];
    [self.placeTypeSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, RGB(1.0, 71.0, 106.0), UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont boldSystemFontOfSize:14], UITextAttributeFont, nil] forState:UIControlStateSelected];

    [self.placeTypeSegmentedControl setWidth:80 forSegmentAtIndex:0];
    [self.placeTypeSegmentedControl setWidth:80 forSegmentAtIndex:1];
    [self.placeTypeSegmentedControl setSelectedSegmentIndex:0];
    self.placeType = @"Address";
    [self.placeTypeSegmentedControl addTarget:self action:@selector(selectSegment:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.placeTypeSegmentedControl];
}

- (void)setUpSearchBar
{
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.placeTypeSegmentedControl.frame.origin.y + self.placeTypeSegmentedControl.frame.size.height + 5, self.view.frame.size.width, 43)] autorelease];
    
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.searchBar setDelegate:self];
    [self.searchBar setKeyboardType:UIKeyboardTypeAlphabet];
    [self.searchBar setPlaceholder:@"Enter address here"];
    [self.searchBar setShowsBookmarkButton:NO];
    [self.searchBar setShowsCancelButton:NO];
    [self.searchBar setShowsScopeBar:NO];
    [self.searchBar setShowsSearchResultsButton:NO];
    [self.searchBar setUserInteractionEnabled:YES];
    
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"searchBarBackground.png"]];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchBarTextField.png"] forState:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"searchBar icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [searchField setTextColor:kHomelessHelperSearchFieldText];
/*
    UIButton *cancelButton;
    for (id button in self.searchBar.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            cancelButton = (UIButton *)button;
            break;
        }
    }
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"searchBarCancelButton.png"] forState:UIControlStateNormal];
    [cancelButton setTitle:@"" forState:UIControlStateNormal];
*/    
    [self.view addSubview:self.searchBar];
}

- (void)setUpTableView
{
    self.searchResultsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.mapView.frame.origin.y + self.mapView.frame.size.height + 10, self.view.frame.size.width, self.view.frame.size.height - (self.mapView.frame.origin.y + self.mapView.frame.size.height + 10))] autorelease];
    [self.searchResultsTableView setAllowsSelection:YES];
    [self.searchResultsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.searchResultsTableView setBackgroundColor:[UIColor clearColor]];
    [self.searchResultsTableView setDataSource:self];
    [self.searchResultsTableView setDelegate:self];
    [self.searchResultsTableView setRowHeight:62];
    [self.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchResultsTableView setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:self.searchResultsTableView];
}

- (void)setUpMapView
{
    self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(10, self.searchBar.frame.origin.y + self.searchBar.frame.size.height + 10, self.view.frame.size.width - 20, 100)] autorelease];
    [self.mapView setDelegate:self];
    [self.mapView setMapType:MKMapTypeStandard];
    [self.view addSubview:self.mapView];
    
    self.defaultRegion = [self.mapView region];
}

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.placeArray = [[[NSMutableArray alloc] init] autorelease];
        self.currentLocation = [[[CLLocation alloc] init] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    [self setUpSegmentedControl];
    [self setUpSearchBar];
    [self setUpMapView];
    [self setUpTableView];

    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_foursquareVenueSearch release];
    [_googleAddressGeocodingSearch release];
    [_placeArray release];
    [_currentLocation release];
    [_placeLocation release];
    [_doneBarButtonItem release];
    [_placeTypeSegmentedControl release];
    [_searchBar release];
    [_searchResultsTableView release];
    [_mapView release];
    [_placeType release];
    [super dealloc];
}

#pragma mark -
#pragma mark SEGMENTED CONTROL

- (void)selectSegment:(id)sender
{
    [self.placeArray removeAllObjects];
    [self.searchResultsTableView reloadData];
    [self.doneBarButtonItem setEnabled:NO];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView setRegion:self.defaultRegion];

    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.placeType = @"Address";
            [self.searchResultsTableView setHidden:NO];
            [self.searchBar setText:@""];
            [self.searchBar setPlaceholder:@"Enter address here"];
            break;
        case 1:
            self.placeType = @"Place";
            [self.searchResultsTableView setHidden:NO];
            [self.searchBar setText:@""];
            [self.searchBar setPlaceholder:@"Enter search terms here"];
            break;
        default:
            self.placeType = @"Address";
            break;
    }
    DLog(@"placeType: %@", self.placeType);
}

#pragma mark -
#pragma mark LAZY INSTANTIATION

- (FoursquareVenueSearch *)foursquareVenueSearch
{
    if (!_foursquareVenueSearch)
    {
        _foursquareVenueSearch = [[FoursquareVenueSearch alloc] init];
        [_foursquareVenueSearch setDelegate:self];
    }
    return _foursquareVenueSearch;
}

- (GoogleAddressGeocodingSearch *)googleAddressGeocodingSearch
{
    if (!_googleAddressGeocodingSearch)
    {
        _googleAddressGeocodingSearch = [[GoogleAddressGeocodingSearch alloc] init];
        [_googleAddressGeocodingSearch setDelegate:self];
    }
    return _googleAddressGeocodingSearch;
}

@end