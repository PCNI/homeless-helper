//
//  UIDevice+Resolutions.m
//  Simple UIDevice Category for handling different iOSs hardware resolutions
//
//  Created by Daniele Margutti on 9/13/12.
//  web: http://www.danielemargutti.com
//  mail: daniele.margutti@gmail.com
//  Copyright (c) 2012 Daniele Margutti. All rights reserved.
//  Improvements by Evan Schoenberg (www.regularrateandrhythm.com). No rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	UIDeviceResolution_Unknown			= 0,
    UIDeviceResolution_iPhoneStandard	= 1,    // iPhone 1,3,3GS Standard Display	(320x480px)
    UIDeviceResolution_iPhoneRetina35	= 2,    // iPhone 4,4S Retina Display 3.5"	(640x960px)
    UIDeviceResolution_iPhoneRetina4	= 3,    // iPhone 5 Retina Display 4"		(640x1136px)
    UIDeviceResolution_iPadStandard		= 4,    // iPad 1,2 Standard Display		(1024x768px)
    UIDeviceResolution_iPadRetina		= 5     // iPad 3 Retina Display			(2048x1536px)
}; typedef NSUInteger UIDeviceResolution;

@interface UIDevice (Resolutions)

- (UIDeviceResolution)resolution;

NSString *NSStringFromResolution(UIDeviceResolution resolution);

@end
