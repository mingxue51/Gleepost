//
//  NewCommentView.h
//  Gleepost
//
//  Created by Σιλουανός on 4/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPTimelineViewController.h"
#import "GLPPost.h"

@interface NewCommentView : UIView <UITextViewDelegate>
{
    float keyboardHeight;
}

@property (weak, nonatomic) GLPTimelineViewController *timeLineDelegate;
@property (weak, nonatomic) UIViewController<NewCommentDelegate> *profileDelegate;
@property (strong, nonatomic) GLPPost *post;
@property (strong, nonatomic) UIImageView *keyboardBackground;
@property (strong, nonatomic) UITextView *commentTextView;
@property (assign, nonatomic) int postIndex;

+(id)loadingViewInView:(UIView *)aSuperview;
-(void)removeView;
-(void) cancelPushed:(id)sender;
-(void)keyboardWillShow:(NSNotification *)note;


@end
