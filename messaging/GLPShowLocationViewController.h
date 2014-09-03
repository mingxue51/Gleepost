//
//  GLPShowLocationViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 2/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class GLPLocation;

@interface GLPShowLocationViewController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) GLPLocation *location;

@end
