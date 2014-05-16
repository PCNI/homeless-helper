//
//  ListViewController.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/22/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomListTableViewCell.h"
#import "CustomServicesLabel.h"
#import "ProfileViewController.h"
#import "JobsListViewController.h"
#import "GigsListViewController.h"
#import "PostGigsViewController.h"
#import "HotlineProfileViewController.h"
#import "Resource.h"

@interface ListViewController : UIViewController <ResourceDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{

}

@property (nonatomic, retain) JobsListViewController *vc3;

@property (nonatomic, retain) GigsListViewController *vc4;

@property (nonatomic, retain) NSString *category;

@property (nonatomic, retain) UILabel *sortingLabel;

@property (nonatomic, retain) UITableView *resourcesTableView;

@property (nonatomic, retain) NSMutableArray *resourcesArray;

@property (nonatomic, retain) MKMapView *mapView;

@property (nonatomic, retain) CLLocation *currentLocation;

- (void)listResourcesAction:(NSString *)category;

- (void)listResourcesActionFinish:(NSMutableArray *)jobsArray;

@end