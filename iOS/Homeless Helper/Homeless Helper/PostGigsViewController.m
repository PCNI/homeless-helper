//
//  PostGigsViewController.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/30/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "PostGigsViewController.h"

@interface PostGigsViewController ()

@end

@implementation PostGigsViewController

@synthesize category = _category;

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
}

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView setDelegate:self];
    [webView.scrollView setScrollEnabled:YES];
    [webView.scrollView setBounces:YES];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:webView];
    [webView release];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kHomelessHelperPostGigsURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0]];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)dealloc
{
    [_category release];
    [super dealloc];
}

@end