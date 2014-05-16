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
#import "FirstViewController.h"

@interface AppDelegate_iPhone : UIResponder <UIApplicationDelegate>
{

}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@end