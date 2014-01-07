//
//  DownloadImage.m
//  Flicker
//
//  Created by Pan Ma on 7/28/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "DownloadImage.h"
#import "FlickrFetcher.h"

@implementation DownloadImage 
@synthesize delegate = _delegate;
@synthesize photos = _photos;
@synthesize appEntry = _appEntry;
@synthesize appRecordArray = _appRecordArray;

- (id)initWithPhotosArray:(NSArray *)photos delegate:(id <DownloadImageDelegate>)theDelegate
{
    self = [super init];
    if (self != nil) {
        self.photos = photos;
        self.delegate = theDelegate;
    }
    return self;
    // return an NSOperation object.
}

- (void)main
{
    //self.appEntry = [[AppRecord alloc] init];
    self.appRecordArray = [[NSMutableArray alloc] init];
    for (NSDictionary *photo in self.photos) {
        // have to REdeclare it every time so that won't just add the same object
        self.appEntry = [[AppRecord alloc] init];
        NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
        NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        if(title != nil && ![title isEqualToString:@""]) {
            self.appEntry.appName = title;
            self.appEntry.appDescription = description;
        }
        else if(description && ![description isEqualToString:@""]) {
            self.appEntry.appName = description;
            self.appEntry.appDescription = @"";
        }
        else {
            self.appEntry.appName = @"Unknown";
            self.appEntry.appDescription = @"";
        }        
        self.appEntry.imageURLString = [[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]absoluteString];
        [self.appRecordArray addObject:self.appEntry];
    }
    [self.delegate didFinishDownloading:self.appRecordArray];
}

@end
