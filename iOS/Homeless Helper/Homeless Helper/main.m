//
//  main.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate_iPhone.h"
#import "AppDelegate_iPad.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSString *appDelegateName;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            appDelegateName =  NSStringFromClass([AppDelegate_iPhone class]);
        } else {
            appDelegateName =  NSStringFromClass([AppDelegate_iPad class]);
        }
        return UIApplicationMain(argc, argv, nil, appDelegateName);
    }
}
