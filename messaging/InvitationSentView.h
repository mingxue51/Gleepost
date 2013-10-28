//
//  InvitationSentView.h
//  Gleepost
//
//  Created by Σιλουανός on 27/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrivateProfileViewController.h"

@interface InvitationSentView : UIView


@property (strong, nonatomic) PrivateProfileViewController* delegate;

+ (id)loadingViewInView:(UIView *)aSuperview;
- (void)removeView;
-(void) cancelPushed: (id)sender;
@end
