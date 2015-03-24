//
//  GLPSelectLocationViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 1/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSelectLocationViewController.h"
#import "UINavigationBar+Format.h"
#import "UINavigationBar+Utils.h"
#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"
#import "WebClient.h"
#import "AddressCell.h"
#import "GLPLocation.h"
#import <CoreLocation/CoreLocation.h>
#import "GLPiOSSupportHelper.h"
#import "WebClientHelper.h"

@interface GLPSelectLocationViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger numberOfDetectionUsersLocation;

@property (assign, nonatomic)  CLLocationCoordinate2D coordinates;

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UIView *searchUserView;

@property (strong, nonatomic) NSArray *nearbyLocations;

@property (assign, nonatomic, getter = didSelectFromNearbyLocations) BOOL selectFromNearbyLocations;

@property (strong, nonatomic) GLPLocation *selectedLocation;

@end

@implementation GLPSelectLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureLocationPermissions];
    
    [self configureNavigationBar];
    
    [self configureMapView];
    
    [self configureViews];
    
    [self configureGestures];
    
    [self initialiseObjects];
    
    [self configureTableView];
    
    [self loadNearbyPlaces];
    
    
    
//    [self loadCurrentLocation];
}

- (void)initialiseObjects
{
    _numberOfDetectionUsersLocation = 0;
    _nearbyLocations = [[NSArray alloc] init];
    _selectFromNearbyLocations = NO;
}

- (void)configureNavigationBar
{
//    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"DONE" withButtonSize:CGSizeMake(60.0, 30.0) withSelector:@selector(donePickingLocation:) andTarget:self];
    
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"DONE" withButtonSize:CGSizeMake(60.0, 30.0) withColour:[AppearanceHelper greenGleepostColour] withSelector:@selector(donePickingLocation:) andTarget:self];
    
    self.title = @"PICK A LOCATION";
}

- (void)configureMapView
{
    [_mapView setUserTrackingMode:MKUserTrackingModeNone];
}

- (void)configureViews
{
    [ShapeFormatterHelper setBorderToView:_backImageView withColour:[AppearanceHelper lightGrayGleepostColour] andWidth:1.0];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_backImageView andValue:2];
}

- (void)configureGestures
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSelectManuallyAddressView)];
    
    [_searchUserView addGestureRecognizer:gesture];
}

- (void)configureTableView
{
    [_tableView registerNib:[UINib nibWithNibName:@"AddressCell" bundle:nil] forCellReuseIdentifier:@"AddressCell"];

    _tableView.tableFooterView = [UIView new];
}

/**
 This method is madantory for iOS 8 due to the new API that Apple introduced.
 */
- (void)configureLocationPermissions
{
    if([GLPiOSSupportHelper isIOS7] || [GLPiOSSupportHelper isIOS6])
    {
        return;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    
    [_locationManager requestWhenInUseAuthorization];
}

#pragma mark - MKMapViewDelegate

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
//{
//    MKOverlayRenderer *polylineView = [[MKOverlayRenderer alloc] initWithOverlay:overlay];
//
//    return polylineView;
//}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
//    CLLocationCoordinate2D tapPoint = [_mapView convertPoint:mapView.center toCoordinateFromView:self.view];
    
    
//    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
//    
//    point1.coordinate = tapPoint;
//    
//    [_mapView addAnnotation:point1];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if([self didSelectFromNearbyLocations])
    {
        _selectFromNearbyLocations = NO;
        
        return;
    }
    
    CLLocationCoordinate2D tapPoint = [_mapView convertPoint:mapView.center toCoordinateFromView:self.view];
    
    DDLogDebug(@"regionDidChangeAnimated: %f : %f", tapPoint.latitude, tapPoint.longitude);
    
    _coordinates = tapPoint;
    
    [self loadNearbyPlaces];
    
    [self findAddressTestMethod];
    
//    [self loadCurrentLocation];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(_numberOfDetectionUsersLocation < 2)
    {
        _numberOfDetectionUsersLocation ++;
        
        DDLogDebug(@"didUpdateUserLocation");
        
        [self zoomAndLocateToUsersLocation];
    }
    else
    {
        //TODO: Detect if there is a need to reset numberOfDetectionUsersLocation.
        DDLogDebug(@"didUpdateUserLocation abort");

    }
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"MY ACCOUNT";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _nearbyLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"AddressCell" forIndexPath:indexPath];
    
    GLPLocation *location = _nearbyLocations[indexPath.row];
    
    [cell setVenueName:location.name];
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPLocation *location = _nearbyLocations[indexPath.row];
    
    _coordinates = [self convertToCoordinates:location];

    //Move the map to specific coordinates.
    [self locateMapToLocation:location];
    
    //Change the name of the selected address field.
//    [_locationLabel setText:location.name];
    
    [self setDataForTheAddressFieldWithLocation:location];

    _selectFromNearbyLocations = YES;
    
    [self loadNearbyPlaces];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ADDRESS_CELL_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self generateHeaderViewWithTitle:@"POPULAR NEARBY LOCATIONS"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

#pragma mark - Selectors

- (void)donePickingLocation:(id)sender
{
    DDLogDebug(@"Done picking location");
    
    [self snapShotMapAndReturnDataToPreviousVC];
}

- (void)snapShotMapAndReturnDataToPreviousVC
{
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = self.mapView.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        UIImage *image = snapshot.image;
        
        //Check if the location data is valid if not then add empty strings
        //in fields that are nil.
        
        [self formatLocationDataIfNeeded];
        
        [_delegate locationSelected:_selectedLocation withMapImage:image];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)goToUsersLocation:(id)sender
{
    [self zoomAndLocateToUsersLocation];
}

- (void)goToSelectManuallyAddressView
{
    [self performSegueWithIdentifier:@"search address" sender:self];
}

#pragma mark - UI methods

- (void)zoomAndLocateToUsersLocation
{
    if(![self isTheAppAuthorisedToAccessLocation])
    {
        [self showLocationErrorMessage];
        return;
    }
    
    MKCoordinateRegion region;
    _coordinates = region.center = _mapView.userLocation.coordinate;
    
    DDLogDebug(@"User location coordinates: %f : %f", _mapView.userLocation.coordinate.latitude, _mapView.userLocation.coordinate.longitude);
    
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.005; // Change these values to change the zoom
    span.longitudeDelta = 0.005;
    region.span = span;
    
    [self loadNearbyPlaces];
    
    [self.mapView setRegion:region animated:YES];
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

- (BOOL)isTheAppAuthorisedToAccessLocation
{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return NO;
            break;
        default:
            return YES;
            break;
    }
}

- (void)showLocationErrorMessage
{
    if([GLPiOSSupportHelper isIOS7])
    {
        [WebClientHelper showLocationRestrictionError];
    }
    else
    {
        UIAlertController *alert = [WebClientHelper generateAlertViewForLocationError];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (UIView *)generateHeaderViewWithTitle:(NSString *)title
{
    UIView *titleViewSection = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    
    [titleViewSection setBackgroundColor:[AppearanceHelper lightGrayGleepostColour]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 30.0)];
    
    [titleLabel setText:title];
    
    [titleLabel setFont:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:12.0]];
    
    [titleLabel setTextColor:[AppearanceHelper blueGleepostColour]];
    
    [titleViewSection addSubview:titleLabel];
    
    return titleViewSection;
}

/**
 Take the nearest location if the distance is less than the threshold.
 
 @param location
 
 */
- (void)setDataForTheAddressFieldWithLocation:(GLPLocation *)location
{
    if(location.distance < 50)
    {
        [_locationLabel setText:location.name];
        
        _selectedLocation = location;
    }
    else
    {
        DDLogInfo(@"Distance exceeded, search address from apple's api.");
        
        [self findAddressAndSetItToField];
    }
    
}

#pragma mark - GLPSelectAddressViewControllerDelegate

- (void)locationSelected:(GLPLocation *)location
{
    DDLogDebug(@"locationSelected: %@", location);
    
    _coordinates = [self convertToCoordinates:location];
    
    DDLogDebug(@"Coordinates: %f : %f", _coordinates.latitude, _coordinates.longitude);

    
    //Move the map to specific coordinates.
    [self locateMapToLocation:location];
    
    //Change the name of the selected address field.
//    [_locationLabel setText:location.name];
    
    [self setDataForTheAddressFieldWithLocation:location];
    
    _selectFromNearbyLocations = YES;
    
    [self loadNearbyPlaces];
}

#pragma mark - Client

- (void)loadNearbyPlaces
{
    [[WebClient sharedInstance] findNearbyLocationsWithLatitude:_coordinates.latitude andLongitude:_coordinates.longitude withCallbackBlock:^(BOOL success, NSArray *locations) {
        
        if(success)
        {
            if(locations.count == 0)
            {
                return;
            }
            
            _nearbyLocations = locations;
            
            [self setDataForTheAddressFieldWithLocation:_nearbyLocations[0]];
            
            if(locations.count < 2)
            {
                _nearbyLocations = [[NSArray alloc] init];
                
                return;
            }
            
            _nearbyLocations = locations;
            
            DDLogInfo(@"Nearby locations: %@", _nearbyLocations);
            
            [_tableView reloadData];
        }
        
    }];
}

- (void)findAddressAndSetItToField
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_coordinates.latitude longitude:_coordinates.longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(placemarks.count < 1)
        {
            return;
        }
        
        CLPlacemark *placemark = placemarks[0];
        
        _selectedLocation = [self convertPlacemarkToLocation:placemark];
        
//        [_locationLabel setText: _selectedLocation.address];
        [self setDataForTheAddressFieldWithLocation:_selectedLocation];
        
    }];
}

- (void)findAddressTestMethod
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_coordinates.latitude longitude:_coordinates.longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(placemarks.count < 1)
        {
            return;
        }
        
        CLPlacemark *placemark = placemarks[0];
        
        DDLogDebug(@"Apple results: %@ %@ %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.subLocality, placemark.areasOfInterest);
        
//        [_locationLabel setText:[NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare]];
        
    }];
}

- (void)loadCurrentLocation
{
    [[WebClient sharedInstance] findCurrentLocationWithLatitude:_coordinates.latitude andLongitude:_coordinates.longitude withCallbackBlock:^(BOOL success, NSArray *locations) {
       
        if(success)
        {
            GLPLocation *location = locations[0];
            
//            [_locationLabel setText:location.name];
            
            [self setDataForTheAddressFieldWithLocation:location];
        }
        
    }];
}

#pragma mark - Helpers

- (GLPLocation *)convertPlacemarkToLocation:(CLPlacemark *)placemark
{
    GLPLocation *location = [[GLPLocation alloc] initWithName:placemark.name address:[NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare ? placemark.subThoroughfare : @"", placemark.thoroughfare ? placemark.thoroughfare : @""] latitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude andDistance:0];
    
    return location;
}

- (CLLocationCoordinate2D)convertToCoordinates:(GLPLocation *)location
{
    CLLocationCoordinate2D coordinates;
    
    coordinates.latitude = location.latitude;
    coordinates.longitude = location.longitude;
    
    return coordinates;
}

/**
 If address is not exist then add empty string to address.
 */
- (void)formatLocationDataIfNeeded
{
    if(!_selectedLocation.address)
    {
        _selectedLocation.address = @"";
    }
}

- (void)dealloc
{
    [_mapView removeFromSuperview];
    self.mapView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"search address"])
    {
        GLPSelectAddressViewController *selectAddressVC = segue.destinationViewController;
        
        [selectAddressVC setDelegate:self];
        [selectAddressVC setUsersLocation:_coordinates];
    }
}


@end
