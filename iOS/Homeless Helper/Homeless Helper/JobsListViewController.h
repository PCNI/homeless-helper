//
//  JobsListViewController.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 4/12/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomListTableViewCell.h"
#import "JobProfileViewController.h"

@interface JobsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{

}

@property (nonatomic, retain) NSMutableArray *jobsArray;

@property (nonatomic, retain) UITableView *jobsTableView;

@end