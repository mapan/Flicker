//
//  PhotoMapViewController.h
//  Flicker
//
//  Created by Pan Ma on 7/23/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"

@class PhotoMapViewController;
@protocol PhotoMapViewControllerDelegate <NSObject>

// get the image for an annotation
- (UIImage *)photoMapViewController:(PhotoMapViewController *)sender
                 imageForAnnotation:(id <MKAnnotation>)annotation;

@end

@interface PhotoMapViewController : UIViewController
@property (nonatomic,strong) NSArray *annotations; // model of id <MKAnnotation> so we need objects
@property (nonatomic,weak) id <PhotoMapViewControllerDelegate> delegate;


@end
