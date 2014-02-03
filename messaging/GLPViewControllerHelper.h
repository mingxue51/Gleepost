//
//  GLPViewControllerHelper.h
//  Gleepost
//
//  Created by Lukas on 2/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPViewControllerHelper : NSObject

+ (GLPViewControllerHelper *)sharedInstance;

- (void)showErrorNetworkMessage;
- (void)hideErrorNetworkMessage;

@end
