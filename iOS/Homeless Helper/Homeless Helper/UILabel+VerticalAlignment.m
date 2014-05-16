//
//  UILabel+VerticalAlignment.m
//  Homeless Helper
//
//  Created by Jessi on 9/24/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "UILabel+VerticalAlignment.h"

@implementation UILabel (VerticalAlignment)

- (float)frameForSizeOfTextWithMaxHeight:(int)maxHeight
{
    CGSize maximumSize = CGSizeMake(320, maxHeight);
    CGSize stringSize = [self.text sizeWithFont:self.font constrainedToSize:maximumSize lineBreakMode:self.lineBreakMode];
    return stringSize.height + 20;
}

@end