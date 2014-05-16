//
//  JobProfileViewController.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 4/12/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDevice+Resolutions.h"
#import "Resource.h"

@interface JobProfileViewController : UIViewController <UIWebViewDelegate>
{    

}

@property (nonatomic, retain) Resource *currentJob;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (void)displayData;

@end