//
//  JobProfileViewController.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 4/12/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "JobProfileViewController.h"

@interface JobProfileViewController ()

@end

@implementation JobProfileViewController

@synthesize currentJob = _currentJob;
@synthesize nameLabel = _nameLabel;
@synthesize webView = _webView;

#pragma mark -
#pragma mark INFO MGMT

- (void)displayData
{
    [self.nameLabel setText:[self.currentJob name1]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.currentJob url]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0]];
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

- (void)setUpImage
{
    UIImage *image;
    if (NSStringFromResolution([[UIDevice currentDevice] resolution]) == @"iPhone Retina 4\"") {
        image = [UIImage imageNamed:@"jobsInfoBox-iPhone5.png"];
    } else {
        image = [UIImage imageNamed:@"jobsInfoBox.png"];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(20, 20, image.size.width, image.size.height)];
    [self.view addSubview:imageView];
    [imageView release];
}

- (void)setUpTextBoxes
{
    [self.nameLabel setFont:[UIFont fontWithName:@"Vollkorn-BoldItalic" size:18]];
    [self.view bringSubviewToFront:self.nameLabel];
}

- (void)setUpWebView
{
    int i = 0;
    if (NSStringFromResolution([[UIDevice currentDevice] resolution]) == @"iPhone Retina 4\"") i = 88;
    
    self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(23, 63, 275, 328 + i)] autorelease];
    [self.webView setDelegate:self];
    [self.webView.scrollView setScrollEnabled:YES];
    [self.webView.scrollView setBounces:YES];
    [self.webView setScalesPageToFit:YES];
    [self.view addSubview:self.webView];
}

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentJob = [[[Resource alloc] init] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];
    [self setUpImage];
    [self setUpTextBoxes];
    [self setUpWebView];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
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
    [_currentJob release];
    [_nameLabel release];
    [_webView release];
    [super dealloc];
}

@end