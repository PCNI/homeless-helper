//
//  UILabel+VerticalAlignment.h
//  Homeless Helper
//
//  Created by Jessi on 9/24/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (VerticalAlignment)

- (float)frameForSizeOfTextWithMaxHeight:(int)maxHeight;

@end