//
//  SinglePlacePhotosAnnotations.m
//  Flicker
//
//  Created by Pan Ma on 7/23/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "SinglePlacePhotosAnnotations.h"
#import "FlickrFetcher.h"

@implementation SinglePlacePhotosAnnotations
@synthesize photo = _photo;

+ (SinglePlacePhotosAnnotations *)annotationForSingPlacePhotos:(NSDictionary *)photo
{
    SinglePlacePhotosAnnotations *annotation = [[SinglePlacePhotosAnnotations alloc] init];
    annotation.photo = photo;
    return annotation;
}

- (NSString *)title
{
    NSString *title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if(title != nil && ![title isEqualToString:@""]) {
        return title;
    }
    else if(description && ![description isEqualToString:@""]) {
        return description;
    }
    else {
        return @"Unknown";
    }
}

- (NSString *)subtitle
{
    NSString *title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if(title != nil && ![title isEqualToString:@""]) {
        return description;
    }
    else {
        return @"";
    }
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
