//
//  CommentCell.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "CommentCell.h"

@interface CommentCell()

@end

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blackColor]];

    }
    return self;
}

-(void) createElements
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *back = [[UIImageView alloc] init];
    //[back setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    [back setBackgroundColor: [UIColor whiteColor]];
    self.backgroundView = back;
    
    //self.backgroundColor = [UIColor colorWithRed:199 green:199 blue:199 alpha:1.0];
    
    //Create and add user's image.
    self.userImageView = [[UIImageView alloc] init];
    [self.userImageView sizeToFit];
    
    [self.contentView addSubview:self.userImageView];
    
    //Create and add user's comment.
    self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(56.0f, 30.0f, 240.f, 80.f)];
    [self.contentTextView setBackgroundColor:[UIColor clearColor]];
    [self.contentTextView setEditable:NO];
    [self.contentTextView setSelectable:YES];
    [self.contentTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
    
    [self.contentView addSubview:self.contentTextView];
    
    
    //Create and add user's name.
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 10.0f, 200.f, 20.f)];
    [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.userNameLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:13]];
    
    [self.contentView addSubview:self.userNameLabel];
    
    
    //Create and add time comment was posted.
    self.postDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 20.0f, 200.f, 20.f)];
    [self.postDateLabel setBackgroundColor:[UIColor clearColor]];
    [self.postDateLabel setTextColor:[UIColor grayColor]];
    [self.postDateLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:9]];
    
    [self.contentView addSubview:self.postDateLabel];
    
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
    
    lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self.contentView addSubview:lineView];
    
    
//    [self.contentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height+400)];
    
    //Create and add social panel.
//    self.socialPanelView = [[UIView alloc] initWithFrame:CGRectMake(5, 80.0f, 310.f, 20.f)];
//    [self.socialPanelView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
//    
//    [self.contentView addSubview:self.socialPanelView];
    
    //Add the like button on the bottom.
//    self.likeButtonButton = [[UIButton alloc] initWithFrame:CGRectMake(70.f, 60.0f, 100.f, 50.f)];
//    [self.likeButtonButton setTitle:@"Like" forState:UIControlStateNormal];
//    [self.likeButtonButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//    
//    
//    CGSize btnSize = [[self.likeButtonButton titleForState:UIControlStateNormal] sizeWithFont:self.likeButtonButton.titleLabel.font];
//    [self.likeButtonButton setImage:[UIImage imageNamed:@"thumbs-up"] forState:UIControlStateNormal];
//    
//    self.likeButtonButton.userInteractionEnabled = YES;
//    
//    [self.likeButtonButton setImageEdgeInsets:UIEdgeInsetsMake(10.f, 0, 0, btnSize.width+20)];
//    [self.likeButtonButton setTitleEdgeInsets: UIEdgeInsetsMake(10.f, 0, 0, self.likeButtonButton.imageView.image.size.width + 10)];
    
    
    [self.contentView addSubview:self.likeButtonButton];
    
    
  
    
    
    
    
    
    
    //Set custom image when the cell is pressed.
    //self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"cell_pressed.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
