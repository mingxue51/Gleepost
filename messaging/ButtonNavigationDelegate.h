//
//  ButtonNavigationDelegate.h
//  Gleepost
//
//  Created by Silouanos on 04/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject_ProfileEnums.h"

@protocol ButtonNavigationDelegate <NSObject>

@required

-(void)viewSectionWithId:(GLPSelectedTab)selectedTab;

@end
