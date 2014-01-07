//
//  SinglePlacePhotosAnnotations.h
//  Flicker
//
//  Created by Pan Ma on 7/23/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@interface SinglePlacePhotosAnnotations : NSObject <MKAnnotation>
+ (SinglePlacePhotosAnnotations *)annotationForSingPlacePhotos:(NSDictionary *)photo;

@property (nonatomic,strong) NSDictionary *photo;

@end
