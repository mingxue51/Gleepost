//
//  NewCommentDelegate.h
//  Gleepost
//
//  Created by Σιλουανός on 18/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewCommentDelegate <NSObject>

@optional
-(void)setPreviousViewToNavigationBar;
-(void)setPreviousNavigationBarName;
-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle;
-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex;


@end
