//
//  RecentPhotosViewController.m
//  Flicker
//
//  Created by Pan Ma on 7/5/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "RecentPhotosViewController.h"
#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "PhotoMapViewController.h"
#import "SinglePlacePhotosAnnotations.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface RecentPhotosViewController () <PhotoMapViewControllerDelegate>

@end

@implementation RecentPhotosViewController
@synthesize photo = _photo;
@synthesize recentPhotos = _recentPhotos;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSArray *)photoAnnotations
{
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSDictionary *photo in self.recentPhotos) { 
        [annotations addObject:[SinglePlacePhotosAnnotations annotationForSingPlacePhotos:photo]];
    }
    return annotations;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.recentPhotos = [[NSUserDefaults standardUserDefaults] objectForKey:@"RecentPhotos"];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recentPhotos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recents";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    self.photo = [self.recentPhotos objectAtIndex:indexPath.row];
    NSString *title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if(title != nil && ![title isEqualToString:@""]) {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = description;
    }
    else if(description && ![description isEqualToString:@""]) {
        cell.textLabel.text = description;
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = @"";
    }
    NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatSquare];
    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.imageView setImageWithURL:url
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //Returns the drawing area for a row identified by index path.
    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
    spinner.center = CGPointMake(rect.origin.x+rect.size.width-20, rect.origin.y+rect.size.height-24.5);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Recent Photos", NULL);
    dispatch_async(downloadQueue, ^{
        [spinner startAnimating];
        [self performSegueWithIdentifier:@"Recents" sender:self];
        [spinner stopAnimating];
    });
    dispatch_release(downloadQueue);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Recents"]) {
        self.photo = [self.recentPhotos objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
        [segue.destinationViewController setPhoto:self.photo];
        [segue.destinationViewController setUrl:url];
    }
    // have to implement prepareforSegue for MapView showing the pins!!!!!!
    else if([segue.identifier isEqualToString:@"RecentsMapView"]) {
        [segue.destinationViewController setAnnotations:[self photoAnnotations]];
        // set the delegate for the PhotoMapViewController
        [segue.destinationViewController setDelegate:self];
    }
}

// PhotoMapViewControllerDelegate method
- (UIImage *)photoMapViewController:(PhotoMapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation
{   
    SinglePlacePhotosAnnotations *sppa = (SinglePlacePhotosAnnotations *)annotation;
    // check out the folder if the photo already exists
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[filemanager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *photosURL = [libraryURL URLByAppendingPathComponent:@"Viewd Photos"];
    NSString *photoID = [sppa.photo objectForKey:FLICKR_PHOTO_ID];
    NSURL *singlePhotoURL = [photosURL URLByAppendingPathComponent:photoID];
    dispatch_queue_t getImage = dispatch_queue_create("getImage", NULL);
    // local variables in a block is read-only!!!!!!!!!!!
    __block UIImage *image = nil;
    // use a variable to check if the block is done
    __block BOOL blockIsDone = NO;
    dispatch_async(getImage, ^ { 
        image = [UIImage imageWithContentsOfFile:singlePhotoURL.path];
        blockIsDone = YES;
        // can not return image;
    });
    // block makes it asynchronous like the completion handler, this function returns image before the block
    // is done, so have to wait until the block got executed!!!!!!
    while (!blockIsDone) {
        usleep(USEC_PER_SEC/10);
    }
    return image;
}


@end
