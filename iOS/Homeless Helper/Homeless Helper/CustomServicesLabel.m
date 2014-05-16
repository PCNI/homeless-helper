//
//  CustomServicesLabel.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/24/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "CustomServicesLabel.h"

@implementation CustomServicesLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFont:[UIFont fontWithName:@"Vollkorn-Bold" size:12]];
        [self setNumberOfLines:1];
        [self setTextAlignment:UITextAlignmentCenter];
        [self setTextColor:kHomelessHelperDarkBlue];
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