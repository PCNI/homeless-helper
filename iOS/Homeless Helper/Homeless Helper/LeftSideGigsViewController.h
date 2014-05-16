//
//  LeftSideGigsViewController.h
//  Homeless Helper
//
//  Created by Jessi on 9/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_iPad.h"
#import "CustomListTableViewCell.h"
#import "Resource.h"

@class RightSideViewController;
@class LeftSideViewController;

@interface LeftSideGigsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, retain) NSMutableArray *gigsArray;

@property (nonatomic, retain) UITableView *gigsTableView;

@end