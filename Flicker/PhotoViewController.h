//
//  PhotoViewController.h
//  Flicker
//
//  Created by Pan Ma on 7/3/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PhotoViewController;
@protocol PhotoViewControllerDelegate <NSObject> 

- (void)photoViewController:(PhotoViewController *)sender
               addToRecents:(NSDictionary *)photo;

@end

@interface PhotoViewController : UIViewController 
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,weak) id <PhotoViewControllerDelegate> delegate;

@end
