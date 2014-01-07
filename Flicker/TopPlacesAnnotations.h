//
//  TopPlacesAnnotations.h
//  Flicker
//
//  Created by Pan Ma on 7/22/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"

@interface TopPlacesAnnotations : NSObject <MKAnnotation>
+ (TopPlacesAnnotations *)annotationForTopPlaces:(NSDictionary *)place;

@property (nonatomic,strong) NSDictionary *place;

@end
