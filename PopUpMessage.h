//
//  PopUpMessage.h
//  Gleepost
//
//  Created by Σιλουανός on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopUpMessage : UIView

+(PopUpMessage*) showMessageWithSuperView: (UIView*) superView;

@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* title;

@end
