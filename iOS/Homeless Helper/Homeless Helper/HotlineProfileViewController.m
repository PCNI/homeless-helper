//
//  HotlineProfileViewController.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/31/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "HotlineProfileViewController.h"

@interface HotlineProfileViewController ()

@end

@implementation HotlineProfileViewController

@synthesize currentResource = _currentResource;
@synthesize alertString = _alertString;
@synthesize category = _category;

@synthesize nameLabel = _nameLabel, phoneLabel = _phoneLabel;
@synthesize callButton = _callButton, shareButton = _shareButton;

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

- (void)displayData
{
    [self.nameLabel setText:[self.currentResource name1]];

    [self.phoneLabel setText:[self.currentResource phone]];
}

#pragma mark -
#pragma mark ACTIONS

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
//    [self.navigationItem setTitle:self.category];
    
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

- (void)setUpTextBoxes
{
    [self.nameLabel setFont:[UIFont fontWithName:@"Vollkorn-BoldItalic" size:18]];
    [self.phoneLabel setFont:[UIFont fontWithName:@"Vollkorn-Regular" size:22]];
}

#pragma mark -
#pragma mark APP MGMT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentResource = [[[Resource alloc] init] autorelease];
        [self.currentResource setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpNavBar];
    [self setUpTextBoxes];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:self.category];
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
    [_nameLabel release];
    [_phoneLabel release];
    [_currentResource release];
    [_alertString release];
    [_category release];
    [super dealloc];
}

@end