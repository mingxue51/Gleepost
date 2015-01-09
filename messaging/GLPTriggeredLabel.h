//
//  GLPTriggeredLabel.h
//  Gleepost
//
//  Created by Silouanos on 08/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPLabel.h"

@interface GLPTriggeredLabel : GLPLabel

@property (assign, nonatomic) NSInteger postRemoteKey;

- (void)removeAsSuperviewObserver;

@end
