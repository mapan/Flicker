//
//  RecentPhotosViewController.h
//  Flicker
//
//  Created by Pan Ma on 7/5/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentPhotosViewController : UITableViewController
@property (nonatomic,strong) NSDictionary *photo;
@property (nonatomic,strong) NSArray *recentPhotos;


@end
