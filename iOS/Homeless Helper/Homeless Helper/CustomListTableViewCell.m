//
//  CustomListTableViewCell.m
//  Homeless Helper
//
//  Created by Jessi Schoenleber on 3/27/12.
//  Copyright (c) 2012 JJAppCo, LLC. All rights reserved.
//

#import "CustomListTableViewCell.h"
#import "Resource.h"
#import "FoursquareVenueSearch.h"
#import "GoogleAddressGeocodingSearch.h"

@implementation CustomListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[self textLabel] setTextColor:kHomelessHelperDarkBlue];
        [[self textLabel] setFont:[UIFont fontWithName:@"Vollkorn-Bold" size:14]];
        
        [[self detailTextLabel] setTextColor:kHomelessHelperDarkBlue];
        [[self detailTextLabel] setFont:[UIFont fontWithName:@"Vollkorn-Regular" size:12]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setResource:(Resource *)resource
         atLocation:(CLLocation *)location
{
    [[self textLabel] setText:[resource name1]];
    if ([[resource resourceType] isEqualToString:@"hotline"]) {
        [[self detailTextLabel] setText:@""];
    } else {
        // format distance
        CLLocation *resourceLoc = [[CLLocation alloc] initWithLatitude:[[resource locationLat] doubleValue] longitude:[[resource locationLong] doubleValue]];
        CLLocationDistance distance = [location distanceFromLocation:resourceLoc];
        [resourceLoc release];
        
        float resourceDistance = distance * 3.28083989501312;
        
        NSMutableString *resourceDistanceString;
        
        if (resourceDistance < 528) {
            resourceDistanceString = [NSMutableString stringWithFormat:@"%.1f feet away", resourceDistance];
        } else {
            resourceDistance = resourceDistance / 5280;
            resourceDistanceString = [NSMutableString stringWithFormat:@"%.1f miles away", resourceDistance];
        }
        
        [[self detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %@, %@", resourceDistanceString, [resource city], [resource state]]];
    }
}

- (void)setJob:(Resource *)job
{
    [self.detailTextLabel setText:[job name1]];
    [self.detailTextLabel setNumberOfLines:2];
}

- (void)setGig:(Resource *)gig
{
    if (![[gig name1] isMemberOfClass:[NSNull class]]) {
        [self.textLabel setText:[gig name1]];
    }
    [self.detailTextLabel setText:[NSString stringWithFormat:@"%@ - %@, %@", [gig opportunityType], [gig city], [gig state]]];
}

- (void)setVenue:(FoursquareVenueSearch *)venue
{
    [self.textLabel setText:[venue venueName]];
    [self.detailTextLabel setText:[venue venueDescription]];
}

- (void)setAddress:(GoogleAddressGeocodingSearch *)address
{
    [self.textLabel setText:[address addressName]];
    [self.textLabel setNumberOfLines:2];
    [self.textLabel setBackgroundColor:[UIColor clearColor]];

    [self.detailTextLabel setText:@""];
    [self.detailTextLabel setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.textLabel.frame;
    CGRect frame2 = self.detailTextLabel.frame;
    
    frame.size.width = self.frame.size.width - 35;
    frame2.size.width = self.frame.size.width - 35;
    [self.textLabel setFrame:frame];
    [self.detailTextLabel setFrame:frame2];
}

@end