//
//  DownloadImage.h
//  Flicker
//
//  Created by Pan Ma on 7/28/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppRecord.h"

@class DownloadImage;
@protocol DownloadImageDelegate <NSObject>

- (void)didFinishDownloading:(NSArray *)AppRecordArray;

@end

@interface DownloadImage : NSOperation 

@property (nonatomic,weak) id<DownloadImageDelegate> delegate;
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,strong) AppRecord *appEntry;
@property (nonatomic,strong) NSMutableArray *appRecordArray;

- (id)initWithPhotosArray:(NSArray *)photos delegate:(id <DownloadImageDelegate>)theDelegate;

@end
