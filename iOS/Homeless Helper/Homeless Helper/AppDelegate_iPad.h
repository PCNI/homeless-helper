//
//  AppDelegate.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/22/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalyticsSession.h"
#import "TestFlight.h"
#import "LeftSideViewController.h"
#import "RightSideViewController.h"

@interface AppDelegate_iPad : UIResponder <UIApplicationDelegate>
{

}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end