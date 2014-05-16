//
//  HotlineProfileViewController.h
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/31/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDevice+Resolutions.h"
#import "Resource.h"

@interface HotlineProfileViewController : UIViewController <ResourceDelegate, UIAlertViewDelegate>
{

}

@property (nonatomic, retain) Resource *currentResource;
@property (nonatomic, retain) NSString *alertString;
@property (nonatomic, retain) NSString *category;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel, *phoneLabel;
@property (nonatomic, retain) IBOutlet UIButton *callButton, *shareButton;

- (IBAction)callPhone:(UIButton *)button;
- (IBAction)share:(UIButton *)button;

- (void)shareResourceWithResourceId:(NSString *)resourceId
                            forKind:(NSString *)kind
                    withDestination:(NSString *)destination;

@end