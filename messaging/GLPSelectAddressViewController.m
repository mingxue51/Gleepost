//
//  GLPSelectAddressViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 2/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSelectAddressViewController.h"
#import "GLPLocation.h"
#import "AddressCell.h"
#import "WebClient.h"
#import <MapKit/MapKit.h>
#import "UINavigationBar+Format.h"

@interface GLPSelectAddressViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *results;

@end

@implementation GLPSelectAddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureNavigationBar];
    
    [self configureTextField];
    
    [self configureTableView];
    
    [self initialiseObjects];
    
    [self configureViewController];
}

- (void)initialiseObjects
{
    _results = [[NSMutableArray alloc] init];
}

- (void)configureTextField
{
    [_searchField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [_searchField becomeFirstResponder];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
}

- (void)configureViewController
{
    self.title = @"PICK A LOCATION";
}

- (void)configureTableView
{
    [_tableView registerNib:[UINib nibWithNibName:@"AddressCell" bundle:nil] forCellReuseIdentifier:@"AddressCell"];
    
    _tableView.tableFooterView = [UIView new];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if([textField.text length] && isnumber([textField.text characterAtIndex:0]))
    {
        [self searchAddressWithString:textField.text];
    }
    else
    {
        [self searchLocationWithString:textField.text];
    }
}


#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"MY ACCOUNT";
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"AddressCell" forIndexPath:indexPath];

    [cell setVenueName:((GLPLocation *)_results[indexPath.row]).name];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate locationSelected:_results[indexPath.row]];
    
    //Pop up to the previous navigation controller.
    [self.navigationController popViewControllerAnimated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ADDRESS_CELL_HEIGHT;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [self generateHeaderViewWithTitle:@"MY ACCOUNT"];
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30.0;
//}


#pragma mark - Client

- (void)searchAddressWithString:(NSString *)address
{
    NSMutableArray *lastResults = _results.copy;
    
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    
    searchRequest.naturalLanguageQuery = address;
    searchRequest.region = MKCoordinateRegionMakeWithDistance(_usersLocation, 2000, 2000);
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        @synchronized(_results)
        {
            _results = [[NSMutableArray alloc] init];
        }
        
        DDLogDebug(@"Removed all location objects: %ld", (unsigned long)response.mapItems.count);
        
        
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *item, NSUInteger idx, BOOL *stop) {
//            CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithPlacemark:item.placemark];
//            
//            annotation.title = item.name;
//            annotation.subtitle = item.placemark.addressDictionary[(NSString *)kABPersonAddressStreetKey];
//            annotation.phone = item.phoneNumber;
//            
//            [annotations addObject:annotation];
            
            DDLogDebug(@"result: %@ %@ %@ %@ %@ - %@", item.placemark.subThoroughfare, item.placemark.thoroughfare, item.placemark.locality, item.placemark.subLocality, item.placemark.areasOfInterest, item.placemark.addressDictionary);
            
            NSMutableString *showString = @"".mutableCopy;
            
            if(item.placemark.subThoroughfare)
            {
                [showString appendString:item.placemark.subThoroughfare];
            }
            
            if(item.placemark.thoroughfare)
            {
                [showString appendString:item.placemark.thoroughfare];
            }
            
            if(![showString isEqualToString:@""])
            {
                @synchronized(_results)
                {
                    [_results addObject:[self convertMapItemToLocation:item]];

                }
                
                
//                [_mapItemsResults addObject:item];
            }
            
            if(response.mapItems.count - 1 ==  idx && _results.count == 0)
            {
                @synchronized(_results)
                {
                    _results = lastResults.copy;
                }
            }
            
            DDLogDebug(@"Last location results: %@", _results);
            
        }];
        
        [_tableView reloadData];
        
//        [self.mapView addAnnotations:annotations];
    }];
}

- (void)searchLocationWithString:(NSString *)location
{
    [[WebClient sharedInstance] findCurrentLocationWithName:location withCallbackBlock:^(BOOL success, NSArray *locations) {
        
        if(success)
        {
            if(locations.count != 0)
            {
                [_results removeAllObjects];
//                [_mapItemsResults removeAllObjects];
                
                _results = locations.mutableCopy;
                [_tableView reloadData];
            }


        }
        
    }];
}

#pragma mark - Helpers

- (GLPLocation *)convertMapItemToLocation:(MKMapItem *)mapItem
{
    MKPlacemark *placemark = mapItem.placemark;
    
    GLPLocation *location = [[GLPLocation alloc] initWithName:mapItem.name address:[NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare ? placemark.subThoroughfare : @"", placemark.thoroughfare ? placemark.thoroughfare : @""] latitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude andDistance:0];
    
    DDLogDebug(@"Current location: %@", location);
    
    return location;
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
