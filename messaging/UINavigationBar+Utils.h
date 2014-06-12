//
//  UINavigationBar+Utils.h
//  Gleepost
//
//  Created by Σιλουανός on 12/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Utils)

- (void)setButtonOnLeft:(BOOL)left withImageName:(NSString *)image withSelector:(SEL)selector andTarget:(UIViewController *)navController;

@end
