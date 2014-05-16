//
//  GigsListViewController.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 4/12/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "GigsListViewController.h"

@interface GigsListViewController ()

@end

@implementation GigsListViewController

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
        ProfileViewController *vc = [[ProfileViewController alloc] init];
        [vc setCurrentResource:[self.gigsArray objectAtIndex:[indexPath row]]];
        [vc setCategory:self.navigationItem.title];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

- (void)action:(id)sender forEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.gigsTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.gigsTableView]];
    
    if ([[self.gigsTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else {
        ProfileViewController *vc = [[ProfileViewController alloc] init];
        [vc setCurrentResource:[self.gigsArray objectAtIndex:[indexPath row]]];
        [vc setCategory:self.navigationItem.title];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
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
    [self.gigsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:self.gigsTableView];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.gigsTableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.gigsTableView reloadData];
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
    [_gigsArray release];
    [_gigsTableView release];
    [super dealloc];
}

@end