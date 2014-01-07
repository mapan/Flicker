//
//  FlickerViewController.h
//  Flicker
//
//  Created by Pan Ma on 6/29/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TopPlacesViewController;

@protocol TopPlacesViewControllerDelegate
- (void)topPlacesViewControllerDelegate:(TopPlacesViewController *)sender
                             showPhotos:(NSArray *)photo;
@end  

@interface TopPlacesViewController : UITableViewController
@property (nonatomic,strong)NSArray *places;
@property (nonatomic,strong)NSArray *singlePlacePhotos;

@property (nonatomic,weak) id <TopPlacesViewControllerDelegate> delegate;

@end
