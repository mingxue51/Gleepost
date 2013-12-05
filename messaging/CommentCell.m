//
//  CommentCell.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "CommentCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"
#import <QuartzCore/QuartzCore.h>
#import "SessionManager.h"
#import "ContactsManager.h"
#import "ShapeFormatterHelper.h"

@interface CommentCell()

@end


static const float FixedSizeOfTextCell = 50;
static const float FollowingCellPadding = 7;
static const float CommentContentViewPadding = 10;  //15 before.
static const float CommentContentLabelMaxWidth = 250;



@implementation CommentCell


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
        
        lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.contentView addSubview:lineView];
        
        

    }
    
    return self;

}

#pragma mark - Delegate methods

-(void)navigateToProfile:(id)sender
{
    UITapGestureRecognizer *incomingUser = (UITapGestureRecognizer*) sender;
    
    UIImageView *incomingView = (UIImageView*)incomingUser.view;
    
    //Decide where to navigate. Private or open.
    
    
    self.delegate.selectedUserId = incomingView.tag;
    
    if((self.delegate.selectedUserId == [[SessionManager sharedInstance]user].remoteKey))
    {
        self.delegate.selectedUserId = -1;
        //Navigate to profile view controller.
        
        [self.delegate performSegueWithIdentifier:@"view profile" sender:self];
    }
    else if([[ContactsManager sharedInstance] navigateToUnlockedProfileWithSelectedUserId:self.delegate.selectedUserId])
    {
        //Navigate to profile view controller.
        
        [self.delegate performSegueWithIdentifier:@"view profile" sender:self];
    }
    else
    {
        //Navigate to private view controller.
        
        [self.delegate performSegueWithIdentifier:@"view private profile" sender:self];
    }
    
    
}

-(void)setCellHeight:(NSString*)content
{
    CGRect cellFrame = self.contentLabel.frame;
    
    float heightSize = [CommentCell getContentLabelSizeForContent:content].height;
    
    [self.contentLabel setFrame:CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, heightSize)];
}

-(void)setComment:(GLPComment*)comment
{
    //Add user's remote key as an image tag.
    self.userImageView.tag = comment.author.remoteKey;
    
    
    [self setCellHeight:comment.content];
    
    
    //Set comment's content.
    self.contentLabel.text = comment.content;
    
    
    
    if([comment.author.profileImageUrl isEqualToString:@""])
    {
        //Set user's image.
        UIImage *img = [UIImage imageNamed:@"default_user_image"];
        self.userImageView.image = img;
        self.userImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.userImageView setFrame:CGRectMake(5.0f, 10.0f, 40.0f, 40.0f)];
    }
    else
    {
        NSLog(@"UserImageView: %@",comment.author.profileImageUrl);
        [self.userImageView setImageWithURL:[NSURL URLWithString:comment.author.profileImageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image"]];
        
    }

    
    
    //Set user's name.
    [self.userNameLabel setText:comment.author.name];
    
    NSDate *currentDate = comment.date;
    
    //Set post's time.
    [self.postDateLabel setText:[currentDate timeAgo]];
    
    
    //Add touch gesture to profile image.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToProfile:)];
    [tap setNumberOfTapsRequired:1];
    [self.userImageView addGestureRecognizer:tap];
    
    //Set circle the user's image.
    [ShapeFormatterHelper setRoundedView:self.userImageView toDiameter:self.userImageView.frame.size.height];
}


-(void)layoutSubviews
{
    CGSize contentSize = [CommentCell getContentLabelSizeForContent:self.contentLabel.text];
    
    
    CGRect frameSize = self.contentLabel.frame;
    
    self.contentLabel.frame = CGRectMake(self.contentLabel.frame.origin.x, self.contentLabel.frame.origin.y, self.contentLabel.frame.size.width, contentSize.height);
    
    frameSize = self.contentLabel.frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    CGSize maximumLabelSize = CGSizeMake(CommentContentLabelMaxWidth, FLT_MAX);
    
    return [content sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByCharWrapping];
}

+ (CGFloat)getCellHeightWithContent:(NSString *)content image:(BOOL)isImage
{
    // initial height
    float height = (isImage) ? 0 : FixedSizeOfTextCell;
    
    // add content label height + message content view padding
    height += [CommentCell getContentLabelSizeForContent:content].height + CommentContentViewPadding;
    
    return height + FollowingCellPadding;
}

@end