//
//  SinglePlacePhotosViewController.h
//  Flicker
//
//  Created by Pan Ma on 6/30/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface SinglePlacePhotosViewController : UITableViewController <SplitViewBarButtonItemPresenter>
@property (nonatomic,strong)NSArray *photos;
@property (nonatomic,strong)NSDictionary *photo;
@property (nonatomic,strong)NSString *topTitle;
// has to be public if other files want to use the accessor methods.


@end
