//
//  GLPCategoriesAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 02/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryManager.h"

@interface GLPCategoriesAnimationHelper : NSObject

- (void)animateElementWithTopConstraint:(NSLayoutConstraint *)topConstraint withKindOfView:(CategoryOrder)kindOfView;
- (CGFloat)getInitialElementsPosition;

@end
