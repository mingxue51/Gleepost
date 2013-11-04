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

@interface PostCell : UITableViewCell


//@property (retain, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *postTime;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIView *socialPanel;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIButton *thumpsUpBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@property (weak, nonatomic) IBOutlet UIImageView* buttonsBack;



@property BOOL isViewPost;
@property BOOL imageAvailable;


//+(CGFloat)getContentLabelHeightForContent:(NSString *)content;
//
//+ (CGFloat)getCellHeightWithContent:(NSString *)content andImage:(BOOL)containsImage;

+(NSString*) findTheNeededText: (NSString*)str;

//-(void) updateWithPostData:(GLPPost *)postData andUserData:(GLPUser*)user;

-(void) updateWithPostData:(GLPPost *)postData;

+ (CGFloat)getCellHeightWithContent:(NSString *)content image:(BOOL)isImage;


@end
