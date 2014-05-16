//
//  CustomToolbarLabel.m
//  Homeless Helper
//
//  Created by Jessi on 9/30/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "CustomToolbarLabel.h"

@implementation CustomToolbarLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFont:[UIFont systemFontOfSize:10]];
        [self setNumberOfLines:1];
        [self setTextAlignment:UITextAlignmentCenter];
        [self setTextColor:kHomelessHelperDarkBlue];
        [self setAdjustsFontSizeToFitWidth:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end