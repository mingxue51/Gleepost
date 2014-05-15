//
//  PostCell.h
//  Gleepost
//
//  Created by Σιλουανός on 11/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"
#import "GLPPost.h"
#import "NewCommentDelegate.h"
#import "ViewImageDelegate.h"



@protocol RemovePostCellDelegate <NSObject>

-(void)removePostWithPost:(GLPPost *)post;

@end



@interface PostCell : UITableViewCell <UIActionSheetDelegate>

extern const float IMAGE_CELL_HEIGHT;
extern const float TEXT_CELL_HEIGHT;

//@property (retain, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *postTime;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIView *socialPanel;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIButton *thumpsUpBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *wideCommentBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCommentsLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLikesLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *eventTime;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (weak, nonatomic) IBOutlet UIView *likeCommentView;
@property (weak, nonatomic) IBOutlet UIImageView *likeCommentBackImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *eventView;
@property (weak, nonatomic) IBOutlet UIView *mainView;


@property (weak, nonatomic) IBOutlet UIImageView *uploadedIndicator;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;

@property (assign, nonatomic) UIViewController <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate> *delegate;

@property BOOL isViewPost;
@property BOOL imageAvailable;


//+(CGFloat)getContentLabelHeightForContent:(NSString *)content;
//
//+ (CGFloat)getCellHeightWithContent:(NSString *)content andImage:(BOOL)containsImage;

//+(NSString*) findTheNeededText: (NSString*)str;

//-(void) updateWithPostData:(GLPPost *)postData andUserData:(GLPUser*)user;

-(void) updateWithPostData:(GLPPost *)postData withPostIndex:(int)postIndex;

+ (CGFloat)getCellHeightWithContent:(GLPPost *)post image:(BOOL)isImage isViewPost:(BOOL)isViewPost;

-(void)reloadImage:(BOOL)loadImage;

-(void)setPostOnline:(BOOL)online;



@end
