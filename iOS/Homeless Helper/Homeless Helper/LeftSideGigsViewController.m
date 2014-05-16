//
//  LeftSideGigsViewController.m
//  Homeless Helper
//
//  Created by Jessi on 9/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "LeftSideGigsViewController.h"

@interface LeftSideGigsViewController ()

@end

@implementation LeftSideGigsViewController

@synthesize gigsArray = _gigsArray;
@synthesize gigsTableView = _gigsTableView;

#pragma mark -
#pragma mark TABLEVIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.gigsArray count] > 0) {
        return [self.gigsArray count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.gigsArray count] == 0) {
        static NSString *NoResultsCellIdentifier = @"NoResultsCell";
        UITableViewCell *basicCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoResultsCellIdentifier] autorelease];

        [basicCell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackground.png"]] autorelease]];
        
        [basicCell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCellBackgroundSelected.png"]] autorelease]];
        [basicCell setTag:999];
        
        [[basicCell textLabel] setBackgroundColor:[UIColor clearColor]];
        [[basicCell textLabel] setTextColor:kHomelessHelperDarkBlue];
        [[basicCell textLabel] setFont:[UIFont fontWithName:@"Vollkorn-Bold" size:16]];
        
		[[basicCell textLabel] setText:@"No resources found"];
		
		return basicCell;
        
    } else {
        static NSString *cellIdentifier = @"CellIdentifier";
        CustomListTableViewCell *cell = (CustomListTableViewCell *)[self.gigsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
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
        
        Resource *gig = [self.gigsArray objectAtIndex:[indexPath row]];
        [cell setGig:gig];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.gigsTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else {
        AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
        NSArray *vcArray = del.splitViewController.viewControllers;
        UINavigationController *nvc = [vcArray objectAtIndex:1];
        RightSideViewController *rvc = [nvc.viewControllers objectAtIndex:0];

        [rvc.lvc setCurrentResource:[self.gigsArray objectAtIndex:[indexPath row]]];
        [rvc selectMapAnnotation];
        [rvc displayData];
    }
}

- (void)action:(id)sender forEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.gigsTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.gigsTableView]];
    
    if ([[self.gigsTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else {
        AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
        NSArray *vcArray = del.splitViewController.viewControllers;
        UINavigationController *nvc = [vcArray objectAtIndex:1];
        RightSideViewController *rvc = [nvc.viewControllers objectAtIndex:0];

        [rvc.lvc setCurrentResource:[self.gigsArray objectAtIndex:[indexPath row]]];
        [rvc selectMapAnnotation];
        [rvc displayData];
    }
}

#pragma mark -
#pragma mark VIEW CONTROL

- (void)dismissView
{
    AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
    NSArray *vcArray = del.splitViewController.viewControllers;
    UINavigationController *nvc = [vcArray objectAtIndex:1];
    RightSideViewController *rvc = [nvc.viewControllers objectAtIndex:0];
    
    [rvc clearInfoBoxes];
    
    [rvc.lvc setCategory:@"Employment"];
    [rvc reloadData];
    
    [self.gigsTableView deselectRowAtIndexPath:[self.gigsTableView indexPathForSelectedRow] animated:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark INITIAL VIEW SETUP

- (void)setUpNavBar
{
    [self.navigationItem setTitle:@"Jobs & Volunteer Opps"];
    
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

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.gigsArray = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    // set up tableview
    self.gigsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    [self.gigsTableView setDataSource:self];
    [self.gigsTableView setDelegate:self];
    [self.gigsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.gigsTableView setBackgroundColor:[UIColor clearColor]];
    [self.gigsTableView setRowHeight:62];
    [self.gigsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.gigsTableView];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.gigsTableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
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
    [_gigsArray release];
    [_gigsTableView release];
    [super dealloc];
}

@end