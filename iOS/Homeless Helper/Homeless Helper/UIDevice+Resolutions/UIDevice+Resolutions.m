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

#import "UIDevice+Resolutions.h"

@implementation UIDevice (Resolutions)

NSString *NSStringFromResolution(UIDeviceResolution resolution)
{
	switch (resolution) {
		case UIDeviceResolution_iPhoneStandard:
			return @"iPhone Standard";
			break;
		case UIDeviceResolution_iPhoneRetina35:
			return @"iPhone Retina 3.5\"";
			break;
		case UIDeviceResolution_iPhoneRetina4:
			return @"iPhone Retina 4\"";
			break;
		case UIDeviceResolution_iPadStandard:
			return @"iPad Standard";
			break;
		case UIDeviceResolution_iPadRetina:
			return @"iPad Retina";
			break;
		case UIDeviceResolution_Unknown:
		default:
			return @"Unknown";
			break;
	}
}

- (UIDeviceResolution)resolution
{
	UIDeviceResolution resolution = UIDeviceResolution_Unknown;
	UIScreen *mainScreen = [UIScreen mainScreen];
	CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
	CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		if (scale == 2.0f) {
			if (pixelHeight == 960.0f)
				resolution = UIDeviceResolution_iPhoneRetina35;
			else if (pixelHeight == 1136.0f)
				resolution = UIDeviceResolution_iPhoneRetina4;
			
		} else if (scale == 1.0f && pixelHeight == 480.0f)
			resolution = UIDeviceResolution_iPhoneStandard;
		
    } else {
		if (scale == 2.0f && pixelHeight == 2048.0f) {
			resolution = UIDeviceResolution_iPadRetina;
			
		} else if (scale == 1.0f && pixelHeight == 1024.0f) {
			resolution = UIDeviceResolution_iPadStandard;
		}
	}
	
	return resolution;
}

@end
