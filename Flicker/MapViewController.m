//
//  MapViewController.m
//  Flicker
//
//  Created by Pan Ma on 7/22/12.
//  Copyright (c) 2012 Purdue. All rights reserved.
//

#import "MapViewController.h"
#import "MapKit/MapKit.h"
#import "FlickrFetcher.h"
#import "TopPlacesAnnotations.h"
#import "SinglePlacePhotosViewController.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,strong) NSDictionary *place;

// outlet and action for segmentControl
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
- (IBAction)selectMapViewType:(id)sender;

@end

@implementation MapViewController
@synthesize annotations = _annotations;
@synthesize mapView = _mapView;
@synthesize place = _place;
@synthesize segment = _segment;

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
    [self zoomToFitMapAnnotations:self.mapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

// MKMap delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation  
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
    }
    aView.annotation = annotation;
    // add a button to the callout
    UIButton *disclosureButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure]; 
    aView.rightCalloutAccessoryView = disclosureButton;
    return aView;
}

// Tells the delegate that the user tapped one of the annotation view’s accessory buttons.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //TopPlacesViewController *topVC = [[TopPlacesViewController alloc] init];
    // different segues, so no sense.
    
    // The annotation object currently associated with the view.
    TopPlacesAnnotations *annotation = (TopPlacesAnnotations *)view.annotation; 
    self.place = annotation.place;
    [self performSegueWithIdentifier:@"Flickr Photos" sender:self];
}

// Positioning MKMapView to show multiple annotations at once
- (void)zoomToFitMapAnnotations:(MKMapView *)mapView { 
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
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5; 
    
    // Add a little extra space on the sides 
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; 
    
    region = [mapView regionThatFits:region]; 
    [mapView setRegion:region animated:YES]; 
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Flickr Photos"]) {
        NSArray *singlePlacePhotos = [FlickrFetcher photosInPlace:self.place maxResults:50];
        [segue.destinationViewController setPhotos:singlePlacePhotos];
        //get the single place name
        NSString *placeName = [self.place objectForKey:FLICKR_PLACE_NAME];
        NSRange firstComma = [placeName rangeOfString:@","];
        NSUInteger endIndex = firstComma.location;
        [segue.destinationViewController setTopTitle:[placeName substringToIndex:endIndex]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the MapView delegate
    [self.mapView setDelegate:self];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setSegment:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)selectMapViewType:(id)sender {
    if (self.segment.selectedSegmentIndex == 0) {
        self.mapView.mapType = MKMapTypeStandard;
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        self.mapView.mapType = MKMapTypeHybrid;
    }
    else if (self.segment.selectedSegmentIndex == 2) {
        self.mapView.mapType = MKMapTypeSatellite;
    }
}
@end
