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
#import <MapKit/MapKit.h>

@interface GLPSelectAddressViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *results;

@property (strong, nonatomic) NSMutableArray *mapItemsResults;

@end

@implementation GLPSelectAddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureTextField];
    
    [self configureTableView];
    
    [self initialiseObjects];
    
    [self configureViewController];
}

- (void)initialiseObjects
{
    _results = [[NSMutableArray alloc] init];
    _mapItemsResults = [[NSMutableArray alloc] init];
}

- (void)configureTextField
{
    [_searchField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [_searchField becomeFirstResponder];
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
    [self searchAddressWithString:textField.text];
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
    
    [cell setVenueName:_results[indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    
    searchRequest.naturalLanguageQuery = address;
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        [_results removeAllObjects];
        
        
        [_mapItemsResults removeAllObjects];
        
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
                [_results addObject:[NSString stringWithFormat:@"%@ %@", item.placemark.subThoroughfare, item.placemark.thoroughfare]];
                
                [_mapItemsResults addObject:item];
            }
            
        }];
        
        [_tableView reloadData];
        
//        [self.mapView addAnnotations:annotations];
    }];
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
