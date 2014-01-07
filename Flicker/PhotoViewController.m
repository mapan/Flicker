//
//  PhotoViewController.m
//  Flicker
//
//  Created by Pan Ma on 7/3/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotosViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak,nonatomic) UIImage *image;
@property (nonatomic,strong) NSDictionary *photo;


@end

@implementation PhotoViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize image = _image;
@synthesize url = _url;
@synthesize photo = _photo;
@synthesize delegate = _delegate;



- (void)setUrl:(NSURL *)url
{
    if(_url != url) {
        // check out the folder if the photo already exists
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSURL *libraryURL = [[filemanager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *photosURL = [libraryURL URLByAppendingPathComponent:@"Viewd Photos"];
        NSString *photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
        NSURL *singlePhotoURL = [photosURL URLByAppendingPathComponent:photoID];
        if ([filemanager fileExistsAtPath:singlePhotoURL.path]) {
            /*dispatch_queue_t getImage = dispatch_queue_create("getImage", NULL);
            dispatch_async(getImage, ^ { */
                _url = url; 
                UIImage *image = [UIImage imageWithContentsOfFile:singlePhotoURL.path];
                //dispatch_async(dispatch_get_main_queue(), ^ {
                    self.image = image;
                //});
            //});
        }
        else {
            _url = url;
            NSData *data = [NSData dataWithContentsOfURL:self.url];
            self.image = [UIImage imageWithData:data]; 
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.image;
    //[self.imageView initWithImage:self.image];
    // It also disables user interactions for the image view by default.
    
    //self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.zoomScale = 1;
    [self.scrollView setContentMode:UIViewContentModeScaleToFill];
    [self.scrollView sizeToFit];
    self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    self.scrollView.delegate = self;
    [self.scrollView flashScrollIndicators];
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.scrollEnabled = YES;
    // determines how much the content is currently scaled
    self.scrollView.zoomScale = 1.05; 
}

- (void)viewWillAppear:(BOOL)animated
{    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recents = [[defaults objectForKey:@"RecentPhotos"] mutableCopy];
    //   check if it's nil
    if(!recents) recents = [NSMutableArray array];
    if(recents.count > 20) 
        [recents removeObjectAtIndex:recents.count-1];
    NSString *photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
    for(int i = 0;i < recents.count;i++) {
        if ([photoID isEqualToString:[[recents objectAtIndex:i] objectForKey:FLICKR_PHOTO_ID]])             [recents removeObjectAtIndex:i];
    }
    [recents insertObject:self.photo atIndex:0];
    [defaults setObject:recents forKey:@"RecentPhotos"];
    [defaults synchronize];
    RecentPhotosViewController *rpvc = [[RecentPhotosViewController alloc] init];
    [rpvc viewWillAppear:YES];
    // store viewed photos in a folder
    [self storePhotosInFiles];
}

// store viewed photos in a folder
- (void)storePhotosInFiles
{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[filemanager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *photosURL = [libraryURL URLByAppendingPathComponent:@"Viewd Photos"];
    //create the "Viewed Photos" directory
    if (![filemanager fileExistsAtPath:photosURL.path]) {
        NSError *error;
        BOOL success = [filemanager createDirectoryAtURL:photosURL withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success) {
            NSLog(@"Couldn't create file,%@",error.localizedDescription);
        }
    }
    //check if there is a same photo ID file
    NSString *photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
    NSURL *singlePhotoURL = [photosURL URLByAppendingPathComponent:photoID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *filesSize = [[defaults objectForKey:@"FilesSize"] mutableCopy];
    if (![filemanager fileExistsAtPath:singlePhotoURL.path]) {
        NSData *photoData = [[NSData alloc] initWithContentsOfURL:self.url];
        [photoData writeToURL:singlePhotoURL atomically:YES];
        // use the NSuserdefaults to store all the files attributes
        if (!filesSize) { filesSize = [NSMutableArray array]; }
        NSDictionary *fileAttributes = [filemanager attributesOfItemAtPath:singlePhotoURL.path error:nil];
        [filesSize addObject:fileAttributes];
        [defaults setObject:filesSize forKey:@"FilesSize"];
        [defaults synchronize];
    }
    // get all the files size
    unsigned long long fileSize = 0;
    for (NSDictionary *attribute in filesSize) {
        fileSize += [attribute fileSize];
    }
    //meet the 10MB cache limit of the photosURL directory
    if (fileSize > 10*1024*1024) {
        // sort all files by the creation date
        NSArray *filesArray = [filemanager contentsOfDirectoryAtPath:photosURL.path error:nil];
        // get each file's path and creationDate
        NSMutableArray *filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
        for (NSString *filename in filesArray) {
            NSString *filePath = [[photosURL URLByAppendingPathComponent:filename] path];
            NSDictionary *fileProperties = [filemanager attributesOfItemAtPath:filePath error:nil];
            NSDate *creationDate = [fileProperties objectForKey:NSFileCreationDate];
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           filePath, @"filePath",
                                           creationDate, @"creationDate",
                                           nil]];  
        }
        // sort all files by the creation date
        NSArray *sortedFiles = [filesAndProperties sortedArrayUsingComparator:^(id path1,id path2) {
            NSComparisonResult comp = [[path1 objectForKey:@"creationDate"] compare:
                                           [path2 objectForKey:@"creationDate"]];
            return comp;  
        }];
        // delete the oldest photo file in the folder and userdefaults
        NSDictionary *oldestFile = [sortedFiles objectAtIndex:0];
        [filemanager removeItemAtPath:[oldestFile objectForKey:@"filePath"] error:nil];
        [filesSize removeObjectAtIndex:0];
        [defaults setObject:filesSize forKey:@"FilesSize"];
        [defaults synchronize];
    }
}

//################ want to update the recents list while showing the image#################
- (void)viewDidDisappear:(BOOL)animated 
{
    RecentPhotosViewController *rpvc = [[RecentPhotosViewController alloc] init];
    [rpvc viewWillAppear:YES];[rpvc.view setNeedsDisplay];//[rpvc.tableView reloadData];   
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
