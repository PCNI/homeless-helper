//
//  GigsListViewController.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 4/12/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomListTableViewCell.h"
#import "ProfileViewController.h"

@interface GigsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{

}

@property (nonatomic, retain) NSMutableArray *gigsArray;

@property (nonatomic, retain) UITableView *gigsTableView;

@end