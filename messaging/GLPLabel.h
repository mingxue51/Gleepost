//
//  GLPLabel.h
//  Gleepost
//
//  Created by Σιλουανός on 13/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This custom class is created to add automatic gesture to label where is needed.
//  In the future we can add more features on our custom label.
//

#import <UIKit/UIKit.h>

/**
 The labelTouchedWithTag: method is called once the label touched.
 The labelViewed: method is called once the label reaches a specific height of the screen. This method
 should be called only from the GLPTriggeredLabel subclass.
 */
@protocol GLPLabelDelegate <NSObject>

@required
- (void)labelTouchedWithTag:(NSInteger)tag;

@end

@interface GLPLabel : UILabel

@property (weak, nonatomic) id<GLPLabelDelegate> delegate;

@end
