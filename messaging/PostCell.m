//
//  PostCell.m
//  Gleepost
//
//  Created by Σιλουανός on 11/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "PostCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>


@implementation PostCell

static const float FirstCellOtherElementsTotalHeight = 22;
static const float FollowingCellPadding = 7;
static const float MessageContentViewPadding = 15;
static const float StandardTextCellHeight = 140;
static const float StandardImageCellHeight = 400;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //Change the user's button shape to circle.
        /**
         button.clipsToBounds = YES;
         
         button.layer.cornerRadius = 20;//half of the width
         button.layer.borderColor=[UIColor redColor].CGColor;
         button.layer.borderWidth=2.0f;
         */
        

        
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
        
        lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.contentView addSubview:lineView];
        
        
        NSLog(@"initWithCoder : like button");
        
        
        [self.contentView bringSubviewToFront:self.socialPanel];
        [self.contentView sendSubviewToBack:self.postImage];
        
        //Send to back the social panel.
        [self.socialPanel bringSubviewToFront:self.thumpsUpBtn];
        
    }
    
    return self;
}




-(void) updateWithPostData:(GLPPost *)postData
{
    //Set image to the image view.
    //[self.postImage setImage:[UIImage imageNamed:@"post_image"]];
    
    //NSLog(@"Height of Text View: %f",self.content.frame.size.height);
    
    
    NSURL *url;

    for(NSString* str in postData.imagesUrls)
    {
        url = [NSURL URLWithString:str];
        break;
    }
    
    

    //[self fetchImagePostFromServer:url];
    
    UIImage *userImage;
    
    //Add the default image.
    userImage = [UIImage imageNamed:@"default_user"];
    
    // Here we use the new provided setImageWithURL: method to load the web image
    [self.postImage setImageWithURL:url placeholderImage:[UIImage imageNamed:nil]];
    
    
    NSURL *userImageUrl;
    
//    NSLog(@"Image in post cell: %@", user.profileImageUrl);
//    
//    if(user.profileImageUrl!=NULL)
//    {
//        //Add the image comes from server.
//        //userImageUrl = postData.author.imageUrl;
//        userImageUrl = [NSURL URLWithString:user.profileImageUrl];
//        
//        UIImageView *userImageImageView = [[UIImageView alloc] init];
//        
//        [userImageImageView setImageWithURL:userImageUrl placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
//         {
//             NSLog(@"Downloading...");
//         }
//          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
//         {
//             [self.userImage setBackgroundImage:image forState: UIControlStateNormal];
//
//         }];
//        
////        [self.userImage setBackgroundImage:userImageImageView.image forState: UIControlStateNormal];
//    }
//    else
//    {

        
        //Add the user's image.
        [self.userImage setBackgroundImage:userImage forState: UIControlStateNormal];
//    }
    
    self.userImage.clipsToBounds = YES;
    
    self.userImage.layer.cornerRadius = 20;
    
    
    //Add the user's name.
    [self.userName setText:postData.author.name];
    
    //Add the post's time.
    [self.postTime setText:postData.date.description];
    
    
    //Add text to information label.
    [self.informationLabel setText:@"27 likes 3 comments 127 views"];
    
   // NSString* newText = [PostCell findTheNeededText:postData.content];
    
    //NSLog(@"New Text: %@",newText);

//    if(newText == nil)
//    {
        //Add the post's text content.
        //[self.content setText: postData.content];
    [self.contentLbl setText:postData.content];
//    }
//    else
//    {
//        [self.content setText: [newText stringByAppendingString:@" . . ."]];
//    }
    
//    NSLog(@"Needed text for content: %@ -> %@",postData.content,[PostCell findTheNeededText:postData.content]);
    
    

}

-(void) fetchImagePostFromServer:(NSURL*)url
{
    //Fetch post image from the server.
    [self.postImage setImageWithURL:url placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         //NSLog(@"Downloading...");
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         self.postImage.image = image;
     }];
}

static const float firstContentTextViewHeight = 60;
static const float firstImagePosition = 110;

static const float firstSocialPanelPosition = 363;
static const float firstImageButtonsPosition = firstSocialPanelPosition+20;
static const float firstImageInformationPosition = firstSocialPanelPosition+5;

static const float firstTextButtonsPosition = 99;
static const float firstTextInformationPosition = 300;

static const float contentTextViewLimit = 100;

//-(void) updateWithPostData:(Post *)postData withImage:(BOOL)image
//{
//
//    NSLog(@"TableViewCell : updateWithPostData");
//    
//
//    
//    /**
//     Retain first location values.
//     */
//    
//    if(image)
//    {
//        CGRect postImageFrame = self.postImage.frame;
//        CGRect btnFrame = self.commentBtn.frame;
//
//        //Set image to the image view.
//        [self.postImage setImage:[UIImage imageNamed:@"post_image"]];
//        
//        self.postImage.frame = CGRectMake(postImageFrame.origin.x, firstImagePosition, postImageFrame.size.width, postImageFrame.size.height);
//        
//        self.commentBtn.frame = CGRectMake(btnFrame.origin.x, firstImageButtonsPosition, btnFrame.size.width, btnFrame.size.height);
//        
//        self.thumpsUpBtn.frame = CGRectMake(self.thumpsUpBtn.frame.origin.x, firstImageButtonsPosition, self.thumpsUpBtn.frame.size.width, self.thumpsUpBtn.frame.size.height);
//
//        self.shareBtn.frame = CGRectMake(self.shareBtn.frame.origin.x, firstImageButtonsPosition, self.shareBtn.frame.size.width, self.shareBtn.frame.size.height);
//        
//        
//        [self setNewYViewLocationWithView:self.socialPanel andNewYLocation:firstSocialPanelPosition withImage:2];
//        NSLog(@"Social Panel Position: %f",self.socialPanel.frame.origin.y);
//
//        
//        [self setNewYViewLocationWithView:self.informationLabel andNewYLocation:firstImageInformationPosition withImage:2];
//        
//
//        
//        NSLog(@"Image\nSocial Panel: %f, Buttons Position: %f, Information Position %f", self.socialPanel.frame.origin.y, self.commentBtn.frame.origin.y, self.informationLabel.frame.origin.y);
//        
//    }
//    else
//    {
//        
//        NSLog(@"Text\nSocial Panel: %f, Buttons Position: %f, Information Position %f", self.socialPanel.frame.origin.y, self.commentBtn.frame.origin.y, self.informationLabel.frame.origin.y);
//
//        [self setNewYViewLocationWithView:self.thumpsUpBtn andNewYLocation:firstTextButtonsPosition withImage:2];
//        
//        [self setNewYViewLocationWithView:self.commentBtn andNewYLocation:firstTextButtonsPosition withImage:2];
//
//        [self setNewYViewLocationWithView:self.shareBtn andNewYLocation:firstTextButtonsPosition withImage:2];
//        
//        
//
//        
//        
//        //TODO: Add the information panel.
//
//        
//    }
//    
//    //Set the default size of content's text view.
//    self.content.frame = CGRectMake(self.content.frame.origin.x, self.content.frame.origin.y, self.content.frame.size.width, firstContentTextViewHeight);
//    
//    
//    /**
//     Add data to the elements of the cells.
//     */
//    
//    
//    //Add the user's image.
//    [self.userImage setImage:[UIImage imageNamed:@"avatar_big"]];
//    
//    //Add the user's name.
//    [self.userName setText:postData.user.name];
//    
//    //Add the post's time.
//    [self.postTime setText:postData.date.description];
//    
//    
//    //Add text to information label.
//    [self.informationLabel setText:@"27 likes 3 comments 127 views"];
//    
//    //NSLog(@"Content: %@\nHeight before: %f",postData.content, self.content.frame.size.height);
//    
//    float oldHeight = self.content.frame.size.height;
//    /**
//     Resize the elements depending on the content's text view final height.
//     */
//    
//    float contentHeight = [PostCell getContentLabelHeightForContent:postData.content];
//    
//    //Find the difference between current height and new height.
////    float contentDifference = contentHeight - self.content.frame.size.height;
////    float socialDifference = contentHeight - self.socialPanel.frame.size.height+35;
////    float buttonsDifference = contentHeight - self.thumpsUpBtn.frame.size.height;
//    
//    float difference = contentHeight - oldHeight;
//    
//
//   // NSLog(@"DIFFERENCE: %f", difference);
//    
//   // NSLog(@"Height After: %f", contentHeight);
//   // NSLog(@"Old and New Heights: %f : %f",oldHeight, contentHeight);
//    
//    if(difference > 0)
//    {
//        
//        //self.content.frame = CGRectMake(self.content.frame.origin.x, self.content.frame.origin.y, self.content.frame.size.width, contentHeight + MessageContentViewPadding);
//        
//        
//        
//        //self.content.frame = CGRectMake(self.content.frame.origin.x, self.content.frame.origin.y, self.content.frame.size.width, contentHeight);
//        
//        //Relocate the other elements.
//        CGRect postImageFrame = self.postImage.frame;
//        CGRect socialPanelFrame = self.socialPanel.frame;
//        
//        
//        float i = [PostCell getCellHeightWithContent:[PostCell findTheNeededText:postData.content] andImage:image];
//
//        NSLog(@"I: %f Content: %@",i, postData.content);
//
//        
//        //Remove text that is after three lines.
//        
//        //Add the post's text content.
//        [self.content setText: [[PostCell findTheNeededText:postData.content] stringByAppendingString:@"  . . ."]];
//        
//        
//        //[self setNewYViewLocationWithView:self.postImage andNewYLocation:postImageFrame.origin.y+difference+10 withImage:2];
//        
//        //[self setNewYViewLocationWithView:self.socialPanel andNewYLocation:socialPanelFrame.origin.y+difference+45 withImage:2];
//        
//
//        
////
//        [self setNewYViewLocationWithView:self.thumpsUpBtn andNewYLocation:i+10 withImage:image];
////        
////        
//        [self setNewYViewLocationWithView:self.commentBtn andNewYLocation:i+10 withImage:image];
////        
////        
//        [self setNewYViewLocationWithView:self.shareBtn andNewYLocation:i+10 withImage:image];
////
//        [self setNewYViewLocationWithView:self.informationLabel andNewYLocation:i-7 withImage:image];
//
//        if(!image)
//        {
//            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, self.informationLabel.frame.origin.y, self.contentView.frame.size.width-10, 1)];
//            
//            lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.04];
//            [self.contentView addSubview:lineView];
//        }
//        
//        
//        return;
//    }
//    
//    self.content.frame = CGRectMake(self.content.frame.origin.x, self.content.frame.origin.y, self.content.frame.size.width, contentHeight + MessageContentViewPadding);
//
//    
//    
//    //self.content.frame = CGRectMake(self.content.frame.origin.x, self.content.frame.origin.y, self.content.frame.size.width, contentHeight);
//    
//    //Relocate the other elements.
//    CGRect postImageFrame = self.postImage.frame;
//    CGRect socialPanelFrame = self.socialPanel.frame;
//    
//    //Add the post's text content.
//    [self.content setText: postData.content];
//    
//
//    //self.postImage.frame = CGRectMake(postImageFrame.origin.x, postImageFrame.origin.y+difference, postImageFrame.size.width, postImageFrame.size.height);
//    
//    [self setNewYViewLocationWithView:self.postImage andNewYLocation:postImageFrame.origin.y+difference+10 withImage:2];
//
//    
//    
//    NSLog(@"Buttons Height: %f : %f :%f",self.thumpsUpBtn.frame.origin.y, self.commentBtn.frame.origin.y, self.shareBtn.frame.origin.y);
//    //[self setNewYViewLocationWithView:self.commentBtn andNewYLocation:self.commentBtn.frame.origin.y+difference+45 withImage:image];
//
//    
//    //[PostCell getCellHeightWithContent:[PostCell findTheNeededText:currentPost.content] andImage:NO]
//    //[self setNewYViewLocationWithView:self.thumpsUpBtn andNewYLocation:self.thumpsUpBtn.frame.origin.y+difference+45];
//    
//    float i = [PostCell getCellHeightWithContent:[PostCell findTheNeededText:postData.content] andImage:image];
//    
//    [self setNewYViewLocationWithView:self.socialPanel andNewYLocation:i-65 withImage:2];
//
//    
//    
//    [self setNewYViewLocationWithView:self.thumpsUpBtn andNewYLocation:i+10 withImage:image];
//
//    
//    [self setNewYViewLocationWithView:self.commentBtn andNewYLocation:i+10 withImage:image];
//
//    
//    [self setNewYViewLocationWithView:self.shareBtn andNewYLocation:i+10 withImage:image];
//    
//    [self setNewYViewLocationWithView:self.informationLabel andNewYLocation:i-10 withImage:image];
//    
//    
//    if(!image)
//    {
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, self.informationLabel.frame.origin.y, self.contentView.frame.size.width-10, 1)];
//        
//        lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.04];
//        [self.contentView addSubview:lineView];
//    }
//
//}



- (void)layoutSubviews
{
    NSLog(@"TableViewCell : layoutSubviews");
    
}

//static float heightOfALine = 14.31;
static float heightOfALine = 14.31;
static int noOfLetters = 41;


+(NSString*) findTheNeededText: (NSString*)str
{
    NSString* finalStr = [[NSString alloc] init];
    
    int numberOfLines = 0;
    for(int i=0; i<str.length; ++i)
    {
        //NSLog(@"No of Lines: %f For string: %@\nFinal String: %@", [PostCell numberOfLinesUsingString: [str substringToIndex:i]], str, finalStr);
        
        if(i%41==0)
        {
            ++numberOfLines;
        }
        
        if(numberOfLines == 3)
        {
            return [str substringToIndex:i];
        }
        
//        if([PostCell numberOfLinesUsingString: [str substringToIndex:i]] > 2.5)
//        {
//            
//            //The text reach the limit.
//            //Return the string.
//            
//            //return [finalStr substringToIndex:finalStr.length-20];
//             return finalStr;
//        }
//        else
//        {
//            //Append the final string.
//            finalStr = [str substringToIndex:i];
//        }
    }
    
    return nil;
}

+(float) numberOfLinesUsingString: (NSString*)str
{
    float height = [PostCell getContentLabelHeightForContent:str];
    
    float numberOfLines = height/heightOfALine;
    
    return numberOfLines;
}


/**
 
 @param option 1 for image, 0 without image and 2 none.
 
 */
-(void) setNewYViewLocationWithView: (UIView*)view andNewYLocation: (float)y withImage: (int)option
{
    //viewFrame = CGRectMake(viewFrame.origin.x, y, viewFrame.size.width, viewFrame.size.height);
    
    //return viewFrame;
    
    if(option == 0)
    {
        view.frame = CGRectMake(view.frame.origin.x, y-40, view.frame.size.width, view.frame.size.height);
    }
    else if(option == 1)
    {
        view.frame = CGRectMake(view.frame.origin.x, y-55, view.frame.size.width, view.frame.size.height);
    }
    else if(option == 2)
    {
        view.frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
    }
    
}


-(void) updateLocationElements
{
    
}

//-(void) createElements
//{
//    //TODO: Set selectable was added in iOS 7 and later.
//    
//    //User Image.
//    self.userImage = [[UIImageView alloc] init];
//    [self.userImage sizeToFit];
//    [self.contentView addSubview:self.userImage];
//    
//    //User Name.
//    self.userName = [[UITextView alloc] init];
//    [self.userName setBackgroundColor:[UIColor clearColor]];
//    [self.userName setEditable:NO];
//    [self.userName setScrollEnabled:NO];
//    //[self.userName setSelectable:NO];
//    //[self.userName sizeToFit];
//    [self.userName setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//    [self.userName setFrame:CGRectMake(54.0f, 2.0f, 100.0f, 30.0f)];
//    [self.contentView addSubview:self.userName];
//    
//    //Post Time.
//    self.postTime = [[UITextView alloc] init];
//    [self.postTime setBackgroundColor:[UIColor clearColor]];
//    [self.postTime setTextColor:[UIColor grayColor]];
//    [self.postTime setEditable:NO];
//    [self.postTime setScrollEnabled:NO];
//    // [self.postTime setSelectable:NO];
//    //[self.postTime sizeToFit];
//    [self.postTime setFont:[UIFont fontWithName:@"Helvetica Neue" size:10]];
//    [self.postTime setFrame:CGRectMake(54.0f, 18.0f, 100.0f, 30.0f)];
//    [self.contentView addSubview:self.postTime];
//    
//    //Content.
//    self.content = [[UITextView alloc] init];
//    [self.content setBackgroundColor:[UIColor clearColor]];
//    [self.content setEditable:NO];
//    [self.content setScrollEnabled:NO];
//    
//    //   [self.content setSelectable:NO];
//    [self.content sizeToFit];
//    [self.content setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
//    [self.content setFrame:CGRectMake(54.0f, 31.0f, 250.0f, 50.0f)];
//    [self.contentView addSubview:self.content];
//    
//    
//
//    
//    //Social Panel.
//    self.socialPanel = [[UIImageView alloc] init];
//    self.socialPanel.userInteractionEnabled = YES;
//    UIColor *backColour = [UIColor colorWithWhite:1.0f alpha:0.5f];
//    [self.socialPanel setBackgroundColor:backColour];
//    
//    //Add a post's information text view.
//    UITextView *information = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 20.0f)];
//    information.userInteractionEnabled = NO;
//    [information setBackgroundColor:[UIColor clearColor]];
//    [information setText:@"27 likes 3 commends 127 views"];
//    
//    [self.socialPanel addSubview:information];
//    
//    //Add thumbs-up button.
//    self.thumpsUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 2.0f, 100.0f, 50.0f)];
//    [self.thumpsUpBtn setTitle:@"Like" forState:UIControlStateNormal];
//    [self.thumpsUpBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
////    [self.thumpsUpBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//
//    
//    CGSize btnSize = [[self.thumpsUpBtn titleForState:UIControlStateNormal] sizeWithFont:self.thumpsUpBtn.titleLabel.font];
//    [self.thumpsUpBtn setImage:[UIImage imageNamed:@"thumbs-up_image"] forState:UIControlStateNormal];
//    
//    self.thumpsUpBtn.userInteractionEnabled = YES;
//    
//    [self.thumpsUpBtn setImageEdgeInsets:UIEdgeInsetsMake(10.f, 0, 0, btnSize.width+20)];
//    [self.thumpsUpBtn setTitleEdgeInsets: UIEdgeInsetsMake(10.f, 0, 0, self.thumpsUpBtn.imageView.image.size.width + 10)];
//    
//    
//    //Add comment button.
//    self.commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(110.0f, 5.0f, 110.0f, 50.0f)];
//    [self.commentBtn setTitle:@"Comment" forState:UIControlStateNormal];
//    [self.commentBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//    btnSize = [[self.commentBtn titleForState:UIControlStateNormal] sizeWithFont:self.commentBtn.titleLabel.font];
//    [self.commentBtn setImage:[UIImage imageNamed:@"comment_image"] forState:UIControlStateNormal];
////    [self.commentBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//
//    
//    self.commentBtn.userInteractionEnabled = YES;
//    
//    [self.commentBtn setImageEdgeInsets:UIEdgeInsetsMake(10.f, 0, 0, btnSize.width+20)];
//    [self.commentBtn setTitleEdgeInsets: UIEdgeInsetsMake(10.f, 0, 0, self.commentBtn.imageView.image.size.width)];
//    
//    
//    //Add share button.
//    self.shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(200.0f, 0.0f, 100.0f, 50.0f)];
//    [self.shareBtn setTitle:@"Share" forState:UIControlStateNormal];
//    [self.shareBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
//    btnSize = [[self.shareBtn titleForState:UIControlStateNormal] sizeWithFont:self.shareBtn.titleLabel.font];
//    [self.shareBtn setImage:[UIImage imageNamed:@"share_image"] forState:UIControlStateNormal];
////    [self.shareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//
//    self.shareBtn.userInteractionEnabled = YES;
//    
//    [self.shareBtn setImageEdgeInsets:UIEdgeInsetsMake(14.f, 0, 0, btnSize.width-43)];
//    [self.shareBtn setTitleEdgeInsets: UIEdgeInsetsMake(18.f, 0, 0, self.shareBtn.imageView.image.size.width-40)];
//    
//    
//    [self.socialPanel insertSubview:self.shareBtn aboveSubview:self.socialPanel];
//    
//    [self.socialPanel insertSubview:self.commentBtn aboveSubview:self.socialPanel];
//    
//    [self.socialPanel insertSubview:self.thumpsUpBtn aboveSubview:self.socialPanel];
//    
//    [self.contentView addSubview:self.socialPanel];
//    
//    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
//    
//    lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
//    [self.contentView addSubview:lineView];
//
//}

+ (CGFloat)getContentLabelHeightForContent:(NSString *)content
{
    CGSize maximumLabelSize = CGSizeMake(236, 60);
    
    CGFloat contentHeight = [content sizeWithFont: [UIFont systemFontOfSize:12.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByCharWrapping].height;
    
   //  NSLog(@"ONE LINE!\n%@",content);
  //  NSLog(@"Content Height:%f",contentHeight);
    
    return contentHeight;
}

+ (CGFloat)getCellHeightWithContent:(NSString *)content andImage:(BOOL)containsImage
{
    // initial height
    //float height = (isFirst) ? FirstCellOtherElementsTotalHeight : 0;
    
    float height = containsImage?StandardImageCellHeight:StandardTextCellHeight;

    
    // add content label height + message content view padding
    height += [PostCell getContentLabelHeightForContent:content] + MessageContentViewPadding;
    
    return height + FollowingCellPadding;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
