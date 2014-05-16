//
//  AppDelegate.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/22/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "AppDelegate_iPhone.h"

@implementation AppDelegate_iPhone

@synthesize window = _window;
@synthesize navigationController = _navigationController;

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
//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    UIViewController *viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController1] autorelease];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, kHomelessHelperDarkBlue, UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Vollkorn-BoldItalic" size:21.0], UITextAttributeFont, nil]];
    
    self.window.rootViewController = self.navigationController;

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
    [_navigationController release];
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