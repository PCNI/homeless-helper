//
//  AppDelegate.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/22/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "AppDelegate_iPad.h"

@implementation AppDelegate_iPad

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
#ifdef DEBUG
    [[LocalyticsSession sharedLocalyticsSession] startSession:kLocalyticsKeyDev];
#endif
#ifdef RELEASE
    [[LocalyticsSession sharedLocalyticsSession] startSession:kLocalyticsKeyProd];
#endif
    
#ifdef TESTING
    [TestFlight takeOff:kTestflightKey];
#endif
    
    self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
    LeftSideViewController *vc1 = [[LeftSideViewController alloc] initWithNibName:@"LeftSideViewController" bundle:nil];
    UINavigationController *nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    [vc1 release];
    RightSideViewController *vc2 = [[RightSideViewController alloc] initWithNibName:@"RightSideViewController" bundle:nil];
//    RightSideViewController *vc3 = [[RightSideViewController alloc] initWithNibName:@"RightSideViewController" bundle:nil];

    UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    [vc2 release];
/*
    UINavigationController *nc3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    UITabBarController *tbc2 = [[UITabBarController alloc] init];
    [tbc2 setViewControllers:[NSArray arrayWithObjects:nc2, nc3, nil]];
    [nc2 setTitle:@"Shelter"];
    UITabBarItem *tbi2 = [[UITabBarItem alloc] initWithTitle:@"Shelter" image:[UIImage imageNamed:@"shelterIcon.png"] tag:1];
    [nc2 setTabBarItem:tbi2];
    [nc3 setTitle:@"Food"];
    UITabBarItem *tbi3 = [[UITabBarItem alloc] initWithTitle:@"Food" image:[UIImage imageNamed:@"foodIcon.png"] tag:2];
    [nc3 setTabBarItem:tbi3];
*/    
    [self.splitViewController setViewControllers:[NSArray arrayWithObjects:nc1, nc2, nil]];
    [nc1 release];
    [nc2 release];
    [self.splitViewController setDelegate:vc2];
        
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBarBackgroundIpad.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, kHomelessHelperDarkBlue, UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Vollkorn-BoldItalic" size:21.0], UITextAttributeFont, nil]];
    
//    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabBarBackground.png"]];
//    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabBarSelectionIndicator.png"]];

    self.window.rootViewController = self.splitViewController;
    
    if ([self.splitViewController respondsToSelector:@selector(setPresentsWithGesture:)])
        [self.splitViewController setPresentsWithGesture:YES];

    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end