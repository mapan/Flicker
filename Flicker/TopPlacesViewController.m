//
//  FlickerViewController.m
//  Flicker
//
//  Created by Pan Ma on 6/29/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "SinglePlacePhotosViewController.h"
#import "PhotoViewController.h"
#import "MapViewController.h"
#import "TopPlacesAnnotations.h"


@interface TopPlacesViewController ()

@end

@implementation TopPlacesViewController
@synthesize places = _places;
@synthesize singlePlacePhotos = _singlePlacePhotos;

@synthesize delegate = _delegate;

- (IBAction)refresh:(id)sender 
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *places = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.places = places;
        });
    });
    dispatch_release(downloadQueue);
}

// ############################## MapView Annotations ##############################
- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSDictionary *place in self.places) { 
        [annotations addObject:[TopPlacesAnnotations annotationForTopPlaces:place]];
    }
    return annotations;
}

- (void)updateMapView
{
    MapViewController *mapVC = [[MapViewController alloc] init];
    mapVC.annotations = [self mapAnnotations];
}
// ############################## MapView Annotations ##############################


-(void)setPlaces:(NSArray *)places
{
    if(_places != places) {
        _places = places;
        //set the badge value
        [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",self.places.count]];
        self.tabBarItem = [[UITabBarItem alloc] init];
        self.tabBarItem.badgeValue = @"AB";
        if ([[[[[self tabBarController] tabBar] items] objectAtIndex:0] isEqual:self.tabBarItem]) {
            NSLog(@"Hello");
        }
        // update the mapview annotations
        //[self updateMapView];
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (UINavigationController *)splitViewSinglePlacePhotosViewController
{  
    id sppc = [self.splitViewController.viewControllers lastObject];
    if(![[sppc visibleViewController] isKindOfClass:[SinglePlacePhotosViewController class]] && ![[sppc visibleViewController] isKindOfClass:[PhotoViewController class]])
        sppc = nil;
    return sppc;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Places";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell... get the title and subtitle using the , as the seperation
    NSDictionary *place = [self.places objectAtIndex:indexPath.row];
    NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
    NSRange firstComma = [placeName rangeOfString:@","];
    NSUInteger endIndex = firstComma.location;
    cell.textLabel.text = [placeName substringToIndex:endIndex];
    cell.detailTextLabel.text = [placeName substringFromIndex:endIndex+2];
    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //Returns the drawing area for a row identified by index path.
    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
    
    spinner.center = CGPointMake(rect.origin.x+rect.size.width-36, rect.origin.y+rect.size.height-24.5);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Places", NULL);
    dispatch_async(downloadQueue, ^{
        [spinner startAnimating];
        if ([self splitViewSinglePlacePhotosViewController]) {
            NSDictionary *place = [self.places objectAtIndex:self.tableView.indexPathForSelectedRow.row];
            self.singlePlacePhotos = [FlickrFetcher photosInPlace:place maxResults:50];
            //get the single place name
            NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
            NSRange firstComma = [placeName rangeOfString:@","];
            NSUInteger endIndex = firstComma.location;
            [[[self splitViewSinglePlacePhotosViewController].viewControllers objectAtIndex:0] setPhotos:self.singlePlacePhotos];
            [[[self splitViewSinglePlacePhotosViewController].viewControllers objectAtIndex:0] setTopTitle:[placeName substringToIndex:endIndex]];
            
            // call viewDidAppear again to start downloading images for iPad
            [[[self splitViewSinglePlacePhotosViewController].viewControllers objectAtIndex:0] viewDidAppear:YES];
        }
        else {
            [self performSegueWithIdentifier:@"Flickr Photos" sender:self];
        }
        [spinner stopAnimating];
    });
    dispatch_release(downloadQueue);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Flickr Photos"] && ![self splitViewSinglePlacePhotosViewController]) {
        NSDictionary *place = [self.places objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        self.singlePlacePhotos = [FlickrFetcher photosInPlace:place maxResults:50];
        //[segue.destinationViewController setPhotos:self.singlePlacePhotos];
        
        // use the delegate
        [self setDelegate:segue.destinationViewController];
        [self.delegate topPlacesViewControllerDelegate:self showPhotos:self.singlePlacePhotos];
        
        //get the single place name
        NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
        NSRange firstComma = [placeName rangeOfString:@","];
        NSUInteger endIndex = firstComma.location;
        [segue.destinationViewController setTopTitle:[placeName substringToIndex:endIndex]];
    }
    // have to implement prepareforSegue for MapView showing the pins!!!!!!
    else if ([segue.identifier isEqualToString:@"Map View"]) {
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}

@end












