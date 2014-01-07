//
//  TopPlacesAnnotations.m
//  Flicker
//
//  Created by Pan Ma on 7/22/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "TopPlacesAnnotations.h"
#import "FlickrFetcher.h"

@implementation TopPlacesAnnotations
@synthesize place = _place;

+ (TopPlacesAnnotations *)annotationForTopPlaces:(NSDictionary *)place
{
    TopPlacesAnnotations *annotation = [[TopPlacesAnnotations alloc] init];
    annotation.place = place;
    return annotation;
}

- (NSString *)title
{
    NSString *placeName = [self.place objectForKey:FLICKR_PLACE_NAME];
    NSRange firstComma = [placeName rangeOfString:@","];
    NSUInteger endIndex = firstComma.location;
    return [placeName substringToIndex:endIndex];
}

- (NSString *)subtitle
{
    NSString *placeName = [self.place objectForKey:FLICKR_PLACE_NAME];
    NSRange firstComma = [placeName rangeOfString:@","];
    NSUInteger endIndex = firstComma.location;
    return [placeName substringFromIndex:endIndex+2];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
