//
//  SinglePlacePhotosViewController.m
//  Flicker
//
//  Created by Pan Ma on 6/30/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "SinglePlacePhotosViewController.h"
#import "FlickrFetcher.h"
#import "TopPlacesViewController.h"
#import "PhotoViewController.h"
#import "SinglePlacePhotosAnnotations.h"
#import "PhotoMapViewController.h"
#import "AppRecord.h"
#import "IconDownloader.h"
#import "DownloadImage.h"

@interface SinglePlacePhotosViewController () <TopPlacesViewControllerDelegate, PhotoMapViewControllerDelegate,IconDownloaderDelegate,DownloadImageDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic,strong) NSArray *entries;
@property (nonatomic,strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic,strong) NSOperationQueue *queue;


@end

@implementation SinglePlacePhotosViewController
@synthesize toolbar = _toolbar;
@synthesize photos = _photos;
@synthesize photo = _photo;
@synthesize topTitle = _topTitle;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize entries = _entries;
@synthesize imageDownloadsInProgress = _imageDownloadsInProgress;
@synthesize queue = _queue;

-(void)setPhotos:(NSArray *)photos
{
    if(_photos != photos) {
        _photos = photos;
        //[self.tableView reloadData];
    }
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [items removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [items insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = items;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

// ############################## MapView Annotations ##############################
- (NSArray *)photoAnnotations
{
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSDictionary *photo in self.photos) { 
        [annotations addObject:[SinglePlacePhotosAnnotations annotationForSingPlacePhotos:photo]];
    }
    return annotations;
}
// ############################## MapView Annotations ##############################


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setTopTitle:(NSString *)topTitle
{
    _topTitle = topTitle;
    
    // update UI in main thread
    //dispatch_async(dispatch_get_main_queue(), ^ {
        self.title = topTitle;
    //});
    
    //[self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photos";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    self.photo = [self.photos objectAtIndex:indexPath.row];
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
    // the tableview cells are reused when scrolling on and off the screen
    // add thumbnail images for specific cells asynchronously
        dispatch_queue_t getImage = dispatch_queue_create("image", NULL);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            if ([tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatSquare];
                //NSData *data = [NSData dataWithContentsOfURL:url];
                //NSURLConnection *connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:nil];
                NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:nil];
                cell.imageView.image = [UIImage imageWithData:data]; 
            }
        });
    NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatSquare];
    // Here we use the new provided setImageWithURL: method to load the web image
    dispatch_queue_t getImage = dispatch_queue_create("image", NULL);
    //dispatch_async(getImage, ^ {
    [cell.imageView setImageWithURL:url
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    //});
    dispatch_release(getImage);
    return cell;
}*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //Returns the drawing area for a row identified by index path.
    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
    spinner.center = CGPointMake(rect.origin.x+rect.size.width-32.3, rect.origin.y+rect.size.height-24.5);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Photos", NULL);
    dispatch_async(downloadQueue, ^{
        [spinner startAnimating];
        [self performSegueWithIdentifier:@"Photo" sender:self];
        [spinner stopAnimating];
    });
    dispatch_release(downloadQueue);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Photo"]) {
        self.photo = [self.photos objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
        [segue.destinationViewController setPhoto:self.photo];
        [segue.destinationViewController setUrl:url];
    }
    // have to implement prepareforSegue for MapView showing the pins!!!!!!
    else if([segue.identifier isEqualToString:@"PhotoMapView"]) {
        [segue.destinationViewController setAnnotations:[self photoAnnotations]];
        // set the delegate for the PhotoMapViewController
        [segue.destinationViewController setDelegate:self];
    }
}

// topPlacesViewControllerDelegate method
- (void)topPlacesViewControllerDelegate:(TopPlacesViewController *)sender showPhotos:(NSArray *)photo
{
    self.photos = photo;
}  

// PhotoMapViewControllerDelegate method to get the clicked thumbnail image
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
    // use a variable to check if the block is done cause it returns immediately!!!
    __block BOOL blockIsDone = NO;
    dispatch_async(getImage, ^ { 
        if ([filemanager fileExistsAtPath:singlePhotoURL.path]) { 
            image = [UIImage imageWithContentsOfFile:singlePhotoURL.path];
            blockIsDone = YES;
             // can not return image;
        }
        else {
            NSURL *url = [FlickrFetcher urlForPhoto:sppa.photo format:FlickrPhotoFormatSquare];
            NSData *data = [NSData dataWithContentsOfURL:url];
            image = [UIImage imageWithData:data]; 
            blockIsDone = YES;
        }
    });
    // block makes it asynchronous like the completion handler, this function returns image before the block
    // is done, so have to wait until the block got executed!!!!!!
    while (!blockIsDone) {
        usleep(USEC_PER_SEC/10);
    }
    return image;
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [super viewDidUnload];
}

//############################################################################
- (void)handleLoadedAppRecords:(NSArray *)loadedApps
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObjectsFromArray:loadedApps];
    self.entries = array;
    
    // tell our table view to reload its data, now that parsing has completed
    [self.tableView reloadData];
}

- (void)didFinishDownloading:(NSArray *)appList
{
    [self performSelectorOnMainThread:@selector(handleLoadedAppRecords:) withObject:appList waitUntilDone:NO];
    self.queue = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    //[super viewDidLoad];
    [super viewDidAppear:animated];
    self.entries = [NSArray array];
    // Must alloc and init the proerty before use it!!!!!!!!!!!
    self.imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    self.queue = [[NSOperationQueue alloc] init];
    dispatch_queue_t download = dispatch_queue_create("Download", NULL);
    dispatch_async(download, ^ {
        DownloadImage *download = [[DownloadImage alloc] initWithPhotosArray:self.photos delegate:self];
        [self.queue addOperation:download];
    });
    dispatch_release(download);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	//
	static NSString *CellIdentifier = @"LazyTableCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.entries count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:PlaceholderCellIdentifier];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			//cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
		cell.detailTextLabel.text = @"Loading…";
		
		return cell;
    }
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        
        // #######################!!!!!!!!!!!!!!!!!!!!#######################
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // #######################!!!!!!!!!!!!!!!!!!!!#######################
    }
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
        AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
                
		cell.textLabel.text = appRecord.appName;
        cell.detailTextLabel.text = appRecord.appDescription;
		
        // Only load cached images; defer new downloads until scrolling ends
        if (!appRecord.appIcon)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
        }
        else
        {
            cell.imageView.image = appRecord.appIcon;
        }
        
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
            
            if (!appRecord.appIcon) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.appRecord.appIcon;
    }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end

