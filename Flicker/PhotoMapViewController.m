//
//  PhotoMapViewController.m
//  Flicker
//
//  Created by Pan Ma on 7/23/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "PhotoMapViewController.h"
#import "MapKit/MapKit.h"
#import "FlickrFetcher.h"
#import "SinglePlacePhotosAnnotations.h"
#import "PhotoViewController.h"

@interface PhotoMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *photoMapView;
@property (nonatomic,strong) NSDictionary *photo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
- (IBAction)selectMapViewType:(id)sender;

@end

@implementation PhotoMapViewController
@synthesize photoMapView = _photoMapView;
@synthesize photo = _photo;
@synthesize segment = _segment;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;


- (void)updateMapView
{
    if (self.photoMapView.annotations) [self.photoMapView removeAnnotations:self.photoMapView.annotations];
    if (self.annotations) [self.photoMapView addAnnotations:self.annotations];
}

- (void)setPhotoMapView:(MKMapView *)photoMapView
{
    _photoMapView = photoMapView;
    [self updateMapView];
    [self zoomToFitMapAnnotations:self.photoMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

    // SET the delegate!!!!!!!
- (void)viewDidLoad
{
    [super viewDidLoad];
    // have to set the delegate for calling the delegate methods!!!!!!!!!!!!
    [self.photoMapView setDelegate:self];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation  
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"PhotoMapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PhotoMapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    aView.annotation = annotation;
    // just want to show the image when click one pin
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    // add a button to the callout
    UIButton *disclosureButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure]; 
    aView.rightCalloutAccessoryView = disclosureButton;
    return aView;
}

// Tells the delegate that one of its annotation views was selected.
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{   
    // get the image for annotation callout thumbnail using delegate
    // generic class without Flickr class 
    UIImage *image = [self.delegate photoMapViewController:self imageForAnnotation:aView.annotation];
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
}

// Tells the delegate that the user tapped one of the annotation view’s accessory buttons.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // The annotation object currently associated with the view.
    SinglePlacePhotosAnnotations *annotation = (SinglePlacePhotosAnnotations *)view.annotation;
    self.photo = annotation.photo;
    
    // it will execute prepareForSegue() then perform the segue.
    [self performSegueWithIdentifier:@"PhotoView" sender:self];
    
}

// Positioning MKMapView to show multiple annotations at once
- (void)zoomToFitMapAnnotations:(MKMapView *)mapView
{ 
    if ([mapView.annotations count] == 0) return; 
    
    CLLocationCoordinate2D topLeftCoord; 
    topLeftCoord.latitude = -90; 
    topLeftCoord.longitude = 180; 
    
    CLLocationCoordinate2D bottomRightCoord; 
    bottomRightCoord.latitude = 90; 
    bottomRightCoord.longitude = -180; 
    
    for(id<MKAnnotation> annotation in mapView.annotations) { 
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude); 
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude); 
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude); 
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude); 
    } 
    
    MKCoordinateRegion region; 
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5; 
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;      
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; 
    
    // Add a little extra space on the sides 
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; 
    
    region = [mapView regionThatFits:region]; 
    [mapView setRegion:region animated:YES]; 
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // segue to the PhotoViewController to show the image
    if([segue.identifier isEqualToString:@"PhotoView"]) {
        NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
        [segue.destinationViewController setPhoto:self.photo];
        [segue.destinationViewController setUrl:url];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // get the place name for the navigation bar top title if it's nil
    if (!self.navigationItem.title) {
        self.title = [[[self.annotations objectAtIndex:0] photo] objectForKey:FLICKR_PHOTO_PLACE_NAME];
    }
}

- (void)viewDidUnload
{
    [self setPhotoMapView:nil];
    [self setSegment:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// change the map view type
- (IBAction)selectMapViewType:(id)sender {
    if (self.segment.selectedSegmentIndex == 0) {
        self.photoMapView.mapType = MKMapTypeStandard;
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        self.photoMapView.mapType = MKMapTypeHybrid;
    }
    else if (self.segment.selectedSegmentIndex == 2) {
        self.photoMapView.mapType = MKMapTypeSatellite;
    }
}
@end
