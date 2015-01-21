//
//  GLPShowLocationViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 2/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPShowLocationViewController.h"
#import "GLPLocation.h"
#import "UINavigationBar+Format.h"
#import "GLPMapViewAnnotation.h"

@interface GLPShowLocationViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation GLPShowLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self locateMapToLocation:_location];
    [self configureAndAddAnnotation];
    DDLogDebug(@"LOCATION: %@", _location);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
}

- (void)configureNavigationBar
{
    self.navigationItem.title = @"SHOW LOCATION";
    
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
}

- (void)configureAndAddAnnotation
{
    NSNumber *latitude = @(_location.latitude);
    NSNumber *longitude = @(_location.longitude);
    NSString *title = _location.name;
    
    //Create coordinates from the latitude and longitude values
    CLLocationCoordinate2D coord;
    coord.latitude = latitude.doubleValue;
    coord.longitude = longitude.doubleValue;
    
    GLPMapViewAnnotation *annotation = [[GLPMapViewAnnotation alloc] initWithTitle:title AndCoordinate:coord];
    
    [_mapView addAnnotation:annotation];
    
    [_mapView selectAnnotation:annotation animated:YES];
}

- (void)locateMapToLocation:(GLPLocation *)location
{
    CLLocationCoordinate2D coordinates = [self convertToCoordinates:location];
    
    MKCoordinateRegion region;
    region.center = coordinates;
    
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.001; // Change these values to change the zoom
    span.longitudeDelta = 0.001;
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

- (CLLocationCoordinate2D)convertToCoordinates:(GLPLocation *)location
{
    CLLocationCoordinate2D coordinates;
    
    coordinates.latitude = location.latitude;
    coordinates.longitude = location.longitude;
    
    return coordinates;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
