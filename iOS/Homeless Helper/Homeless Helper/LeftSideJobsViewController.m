//
//  LeftSideJobsViewController.m
//  Homeless Helper
//
//  Created by Jessi on 9/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "LeftSideJobsViewController.h"

@interface LeftSideJobsViewController ()

@end

@implementation LeftSideJobsViewController

@synthesize jobsArray = _jobsArray;
@synthesize jobsTableView = _jobsTableView;

#pragma mark -
#pragma mark TABLEVIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.jobsArray count] > 0) {
        return [self.jobsArray count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.jobsArray count] == 0) {
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
        CustomListTableViewCell *cell = (CustomListTableViewCell *)[self.jobsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
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
        
        Resource *job = [self.jobsArray objectAtIndex:[indexPath row]];
        [cell setJob:job];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.jobsTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else {
        AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
        NSArray *vcArray = del.splitViewController.viewControllers;
        UINavigationController *nvc = [vcArray objectAtIndex:1];
        RightSideViewController *rvc = [nvc.viewControllers objectAtIndex:0];

        Resource *currentJob;
        currentJob = [self.jobsArray objectAtIndex:[indexPath row]];
        NSURL *url2 = [NSURL URLWithString:currentJob.url];
        [rvc showWebViewWithUrl:url2];
    }
}

- (void)action:(id)sender forEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.jobsTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.jobsTableView]];
    
    if ([[self.jobsTableView cellForRowAtIndexPath:indexPath] tag] == 999) {
        return;
    } else {
        AppDelegate_iPad *del = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
        NSArray *vcArray = del.splitViewController.viewControllers;
        UINavigationController *nvc = [vcArray objectAtIndex:1];
        RightSideViewController *rvc = [nvc.viewControllers objectAtIndex:0];
        
        Resource *currentJob;
        currentJob = [self.jobsArray objectAtIndex:[indexPath row]];
        NSURL *url2 = [NSURL URLWithString:currentJob.url];
        [rvc showWebViewWithUrl:url2];
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
    [rvc removeWebView];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark INITIAL VIEW SETUP

- (void)setUpNavBar
{
    [self.navigationItem setTitle:@"Jobs"];
    
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
        self.jobsArray = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    // set up tableview
    self.jobsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    [self.jobsTableView setDataSource:self];
    [self.jobsTableView setDelegate:self];
    [self.jobsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.jobsTableView setBackgroundColor:[UIColor clearColor]];
    [self.jobsTableView setRowHeight:62];
    [self.jobsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.jobsTableView];
    
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
    [_jobsArray release];
    [_jobsTableView release];
    [super dealloc];
}

@end