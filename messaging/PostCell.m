//
//  PostCell.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

@synthesize userImage;
@synthesize userName;
@synthesize postTime;
@synthesize content;
@synthesize mainImage;
@synthesize socialPanel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        NSLog(@"PostCell : init");
    }
    return self;
}

-(void) createElements
{
    //TODO: Set selectable was added in iOS 7 and later.
    
    //User Image.
    self.userImage = [[UIImageView alloc] init];
    [self.userImage sizeToFit];
    [self.contentView addSubview:self.userImage];
    
    //User Name.
    self.userName = [[UITextView alloc] init];
    [self.userName setBackgroundColor:[UIColor clearColor]];
    [self.userName setEditable:NO];
    [self.userName setScrollEnabled:NO];
    [self.userName setSelectable:NO];
    //[self.userName sizeToFit];
    [self.userName setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [self.userName setFrame:CGRectMake(65.0f, 0.0f, 100.0f, 30.0f)];
    [self.contentView addSubview:self.userName];
    
    //Post Time.
    self.postTime = [[UITextView alloc] init];
    [self.postTime setBackgroundColor:[UIColor clearColor]];
    [self.postTime setTextColor:[UIColor grayColor]];
    [self.postTime setEditable:NO];
    [self.postTime setScrollEnabled:NO];
    [self.postTime setSelectable:NO];
    //[self.postTime sizeToFit];
    [self.postTime setFont:[UIFont fontWithName:@"Helvetica Neue" size:10]];
    [self.postTime setFrame:CGRectMake(65.0f, 15.0f, 100.0f, 30.0f)];
    [self.contentView addSubview:self.postTime];
    
    //Content.
    self.content = [[UITextView alloc] init];
    [self.content setBackgroundColor:[UIColor clearColor]];
    [self.content setEditable:NO];
    [self.content setScrollEnabled:NO];
    
    [self.content setSelectable:NO];
    [self.content sizeToFit];
    [self.content setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
    [self.content setFrame:CGRectMake(65.0f, 30.0f, 250.0f, 50.0f)];
    [self.contentView addSubview:self.content];
    
    
//
//    
    //Main Image.
    mainImage = [[UIImageView alloc] init];
    [self.mainImage setBackgroundColor:[UIColor clearColor]];
//    [self.mainImage setFrame:CGRectMake(10.0f, 80.0f, 300.0, 400.0)];
   // [self.mainImage sizeToFit];
    [self.contentView addSubview:self.mainImage];

    //Social Panel.
    self.socialPanel = [[UIImageView alloc] init];
    self.socialPanel.userInteractionEnabled = YES;
    UIColor *backColour = [UIColor colorWithWhite:1.0f alpha:0.5f];
    [self.socialPanel setBackgroundColor:backColour];
    
    //Add a post's information text view.
    UITextView *information = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 20.0f)];
    information.userInteractionEnabled = NO;
    [information setBackgroundColor:[UIColor clearColor]];
    [information setText:@"27 likes 3 commends 127 views"];
    
    [self.socialPanel addSubview:information];
    
    //Add thumbs-up button.
    UIButton *thumpsUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 2.0f, 100.0f, 50.0f)];
    [thumpsUpBtn setTitle:@"Like" forState:UIControlStateNormal];
    [thumpsUpBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    
    
    CGSize btnSize = [[thumpsUpBtn titleForState:UIControlStateNormal] sizeWithFont:thumpsUpBtn.titleLabel.font];
    [thumpsUpBtn setImage:[UIImage imageNamed:@"thumbs-up"] forState:UIControlStateNormal];
    
    thumpsUpBtn.userInteractionEnabled = YES;

    [thumpsUpBtn setImageEdgeInsets:UIEdgeInsetsMake(10.f, 0, 0, btnSize.width+20)];
    [thumpsUpBtn setTitleEdgeInsets: UIEdgeInsetsMake(10.f, 0, 0, thumpsUpBtn.imageView.image.size.width + 10)];
    
    
    //Add comment button.
    UIButton *commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(110.0f, 5.0f, 110.0f, 50.0f)];
    [commentBtn setTitle:@"Comment" forState:UIControlStateNormal];
    [commentBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    btnSize = [[commentBtn titleForState:UIControlStateNormal] sizeWithFont:commentBtn.titleLabel.font];
    [commentBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    
    commentBtn.userInteractionEnabled = YES;
    
    [commentBtn setImageEdgeInsets:UIEdgeInsetsMake(10.f, 0, 0, btnSize.width+20)];
    [commentBtn setTitleEdgeInsets: UIEdgeInsetsMake(10.f, 0, 0, commentBtn.imageView.image.size.width)];
    
    
    //Add share button.
    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(200.0f, 0.0f, 100.0f, 50.0f)];
    [shareBtn setTitle:@"Share" forState:UIControlStateNormal];
    [shareBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    btnSize = [[shareBtn titleForState:UIControlStateNormal] sizeWithFont:shareBtn.titleLabel.font];
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    
    shareBtn.userInteractionEnabled = YES;
    
    [shareBtn setImageEdgeInsets:UIEdgeInsetsMake(14.f, 0, 0, btnSize.width-43)];
    [shareBtn setTitleEdgeInsets: UIEdgeInsetsMake(18.f, 0, 0, shareBtn.imageView.image.size.width-40)];
    
    
    [self.socialPanel insertSubview:shareBtn aboveSubview:self.socialPanel];
    
    [self.socialPanel insertSubview:commentBtn aboveSubview:self.socialPanel];

    [self.socialPanel insertSubview:thumpsUpBtn aboveSubview:self.socialPanel];
    
    [self.contentView addSubview:self.socialPanel];
    
}

-(void)likeButtonPushed
{
    NSLog(@"Like Pushed");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
