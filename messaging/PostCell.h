//
//  PostCell.h
//  Gleepost
//
//  Created by Σιλουανός on 11/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *userImage;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UILabel *postTime;
@property (retain, nonatomic) IBOutlet UITextView *content;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;
@property (retain, nonatomic) IBOutlet UIImageView *socialPanel;
@property (strong, nonatomic) IBOutlet UILabel *informationLabel;
@property (retain, nonatomic) IBOutlet UIButton *thumpsUpBtn;
@property (retain, nonatomic) IBOutlet UIButton *commentBtn;
@property (retain, nonatomic) IBOutlet UIButton *shareBtn;

-(void) updateWithPostData:(Post *)postData withImage:(BOOL)image;

+(CGFloat)getContentLabelHeightForContent:(NSString *)content;

+ (CGFloat)getCellHeightWithContent:(NSString *)content andImage:(BOOL)containsImage;

+(NSString*) findTheNeededText: (NSString*)str;


@end
