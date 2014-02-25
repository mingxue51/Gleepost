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

@property (assign, nonatomic) float heightOfCell;
//@property (strong, nonatomic) UIView *lineView;

@end


static const float FixedSizeOfTextCell = 45; //Before was 90.
static const float FollowingCellPadding = 0;
static const float CommentContentViewPadding = 0;  //15 before.
static const float CommentContentLabelMaxWidth = 250;


@implementation CommentCell


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
//        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-1, self.contentView.frame.size.width, 1)];
//        
//        self.lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
//        [self.contentView addSubview:self.lineView];
        

    }
    
    return self;

}


- (void)awakeFromNib
{
    self.heightOfCell = self.contentView.frame.size.height;
}

-(void)setComment:(GLPComment*)comment
{
    
    //Set the height of the label.
    //    CGSize contentSize = [CommentCell getContentLabelSizeForContent:comment.content];
    //
    //
    //    CGRect frameSize = self.contentLabel.frame;
    //
    //    self.contentLabel.frame = CGRectMake(self.contentLabel.frame.origin.x, self.contentLabel.frame.origin.y, self.contentLabel.frame.size.width, contentSize.height);
    //
    //    frameSize = self.contentLabel.frame;
    //
    //    float contentHeight = contentSize.height;
    //
    //    self.contentLabel.frame = CGRectMake(self.contentLabel.frame.origin.x, self.contentLabel.frame.origin.y, self.contentLabel.frame.size.width, contentHeight);
    
    
    
    //Add user's remote key as an image tag.
    self.userImageView.tag = comment.author.remoteKey;
    
    
    //Set comment's content.
    self.contentLabel.text = comment.content;
    
    
//    [self setCellHeight:comment.content];

    
    
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
    
    
//    self.contentView.layer.borderColor = [UIColor redColor].CGColor;
//    self.contentView.layer.borderWidth = 1.0f;
//    
//    self.contentLabel.layer.borderColor = [UIColor blackColor].CGColor;
//    self.contentLabel.layer.borderWidth = 1.0f;
    
    
}

-(void)setCellHeight:(NSString*)content
{
    CGRect cellFrame = self.contentLabel.frame;
    
    float heightSize = [CommentCell getContentLabelSizeForContent:content].height;
    
    //[self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.heightOfCell+heightSize)];
    
    self.contentLabel.numberOfLines = 0;
    
    
    [self.contentLabel setFrame:CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, heightSize)];
    

}

-(void)layoutSubviews
{
    CGRect cellFrame = self.contentLabel.frame;
    
    float heightSize = [CommentCell getContentLabelSizeForContent:self.contentLabel.text].height;
    
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.heightOfCell+heightSize)];
    
    self.contentLabel.numberOfLines = 0;
//    self.lineView.frame = CGRectMake(0, self.contentView.frame.size.height-1, self.contentView.frame.size.width, 1);

    
    [self.contentLabel setFrame:CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, heightSize)];
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


//-(void)layoutSubviews
//{
//
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    //CGSize maximumLabelSize = CGSizeMake(CommentContentLabelMaxWidth, FLT_MAX);
    
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CommentContentLabelMaxWidth, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    CGSize size = rect.size;
    
    return size;
    
   // return [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];

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