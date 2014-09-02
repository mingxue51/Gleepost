//
//  GLPSelectLocationViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 1/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GLPSelectAddressViewController.h"

@protocol GLPSelectLocationViewControllerDelegate <NSObject>

@required
- (void)locationSelected:(GLPLocation *)location withMapImage:(UIImage *)mapImage;

@end

@interface GLPSelectLocationViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, GLPSelectAddressViewControllerDelegate>

@property (weak, nonatomic) UIViewController<GLPSelectLocationViewControllerDelegate> *delegate;

@end
