//
//  LeftSideViewController.h
//  Homeless Helper
//
//  Created by Jessi on 9/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate_iPad.h"
#import "LeftSideJobsViewController.h"
#import "LeftSideGigsViewController.h"
#import "RightSideViewController.h"
#import "CustomListTableViewCell.h"
#import "Resource.h"

@class RightSideViewController;

@interface LeftSideViewController : UIViewController <ResourceDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, retain) Resource *currentResource;

@property (nonatomic, retain) RightSideViewController *rvc;

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) NSString *category;

@property (nonatomic, retain) UITableView *resourcesTableView;

@property (nonatomic, retain) NSMutableArray *resourcesArray, *gigsArray;

- (void)listResourcesActionForCategory:(NSString *)category
                          withLocation:(CLLocation *)location;

- (void)listResourcesActionFinish:(NSMutableArray *)resourcesArray;

@end