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

@property (retain, nonatomic) IBOutlet UIButton *userImage;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UILabel *postTime;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;
@property (retain, nonatomic) IBOutlet UIView *socialPanel;
@property (strong, nonatomic) IBOutlet UILabel *informationLabel;
@property (retain, nonatomic) IBOutlet UIButton *thumpsUpBtn;
@property (retain, nonatomic) IBOutlet UIButton *commentBtn;
@property (retain, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UILabel *contentLbl;

@property BOOL imageAvailable;


+(CGFloat)getContentLabelHeightForContent:(NSString *)content;

+ (CGFloat)getCellHeightWithContent:(NSString *)content andImage:(BOOL)containsImage;

+(NSString*) findTheNeededText: (NSString*)str;

//-(void) updateWithPostData:(GLPPost *)postData andUserData:(GLPUser*)user;

-(void) updateWithPostData:(GLPPost *)postData;



@end
