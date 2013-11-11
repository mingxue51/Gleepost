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
#import "NSDate+TimeAgo.h"
#import "ShapeFormatterHelper.h"

@implementation PostCell

static const float FirstCellOtherElementsTotalHeight = 22;
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
        
        self.isViewPost = NO;
        
        
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


static const float FixedSizeOfTextCell = 130;
static const float FixedSizeOfImageCell = 400;
static const float FollowingCellPadding = 7;
static const float PostContentViewPadding = 10;  //15 before.
static const float PostContentLabelMaxWidth = 250;

-(void) updateWithPostData:(GLPPost *)postData
{
    self.imageAvailable = NO;

    //Change the mode of the post imageview.
    //self.postImage.contentMode = UIViewContentModeScaleAspectFill;
   // self.postImage.autoresizingMask = (UIViewAutoresizingNone);
    
    
    //Set image to the image view.
    //[self.postImage setImage:[UIImage imageNamed:@"post_image"]];
    
    //NSLog(@"Height of Text View: %f",self.content.frame.size.height);
    
    NSURL *url = nil;

    for(NSString* str in postData.imagesUrls)
    {
        url = [NSURL URLWithString:str];
        self.imageAvailable = YES;
        break;
    }
    
    

    //[self fetchImagePostFromServer:url];
    
    UIImage *userImage;
    
    //Add the default image.
    userImage = [UIImage imageNamed:@"default_user_image"];
    
    UIImageView *inImageView = [[UIImageView alloc]init];
    [inImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:nil]];

    
    if(url!=nil && postData.tempImage==nil)
    {
        // Here we use the new provided setImageWithURL: method to load the web image
        [self.postImage setImageWithURL:url placeholderImage:[UIImage imageNamed:nil]];
        
        //[self.postImage setImage:[self rectImage:self.postImage.image withRect:CGRectMake(0, 0, 300, 300)]];
    }

    
    if(postData.tempImage != nil)
    {
        //Set live image.
        [self.postImage setImage:postData.tempImage];
    }
    

    
    NSURL *userImageUrl = [NSURL URLWithString:postData.author.profileImageUrl];
   // UIImageView *userImageImageView = [[UIImageView alloc] init];

    
   // NSLog(@"Image in post cell: %@ : %@", postData.author.profileImageUrl, postData.author.name);

    
    if([postData.author.profileImageUrl isEqualToString:@""])
    {
        NSLog(@"Not Image in post cell: %@", postData.author.profileImageUrl);
//        [self.userImage setBackgroundImage:userImage forState: UIControlStateNormal];
        [self.userImageView setImage:userImage];
    }
    else
    {
        
        [self.userImageView setImageWithURL:userImageUrl placeholderImage:nil];
        
        
//        [self.userImage setBackgroundImage:self.userImageImageView.image forState: UIControlStateNormal];
        
    }

    
    [ShapeFormatterHelper setRoundedView:self.userImageView toDiameter:self.userImageView.frame.size.height];

    
    //Add to the user's tag's image view the user id.
    self.userImageView.tag = postData.author.remoteKey;
    NSLog(@"User name: %@ with remote key: %d", postData.author.name, postData.author.remoteKey);
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
        //[self.userImage setBackgroundImage:userImage forState: UIControlStateNormal];
//    }
    
    
    //Add the user's name.
    [self.userName setText:postData.author.name];
    
    NSDate *currentDate = postData.date;
    
    //Add the post's time.
    [self.postTime setText:[currentDate timeAgo]];
    
    
    //Add text to information label.
    [self.informationLabel setText:[NSString stringWithFormat:@"%d likes %d comments %d views",postData.likes, postData.commentsCount, postData.remoteKey]];
    

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
    
    
    //Set like button status.
    if(postData.liked)
    {
        [self.thumpsUpBtn setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar"]] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [self.thumpsUpBtn setImage:[UIImage imageNamed:@"thumbs-up_pushed"] forState:UIControlStateNormal];
    }
    else
    {
        [self.thumpsUpBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        //Add the thumbs up selected version of image.
        [self.thumpsUpBtn setImage:[UIImage imageNamed:@"thumbs-up"] forState:UIControlStateNormal];
        
    }

}

-(UIImage*)rectImage:(UIImage*)largeImage withRect:(CGRect)cropRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([largeImage CGImage], cropRect);
    // or use the UIImage wherever you like
    //UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:largeImage.scale orientation:largeImage.imageOrientation];
    
    //[UIImageView setImage:[UIImage imageWithCGImage:imageRef]];
    CGImageRelease(imageRef);
    
    return finalImage;
}

+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    CGSize maximumLabelSize = CGSizeMake(PostContentLabelMaxWidth, FLT_MAX);
    
    return [content sizeWithFont: [UIFont systemFontOfSize:13.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByCharWrapping];
}

+ (CGFloat)getCellHeightWithContent:(NSString *)content image:(BOOL)isImage
{
    // initial height
    float height = (isImage) ? FixedSizeOfImageCell : FixedSizeOfTextCell;
    
    // add content label height + message content view padding
    height += [PostCell getContentLabelSizeForContent:content].height + PostContentViewPadding;
    
    return height + FollowingCellPadding;
}

static float bottomMargin = 50.0;

-(void)layoutSubviews
{
    if(self.isViewPost)
    {
        CGSize contentSize = [PostCell getContentLabelSizeForContent:self.contentLbl.text];
        
        
        CGRect frameSize = self.contentLbl.frame;
        
        CGRect buttonFrameSize = self.thumpsUpBtn.frame;

        

        
        NSLog(@"Frame Size before: %f : %f",frameSize.size.width, frameSize.size.height);
        
        float heightSize = contentSize.height;
        
        [self.contentLbl setNumberOfLines:0];

        if(self.imageAvailable)
        {
            
            self.contentLbl.frame = CGRectMake(self.contentLbl.frame.origin.x, self.contentLbl.frame.origin.y+5, self.contentLbl.frame.size.width, contentSize.height);
            
            frameSize = self.contentLbl.frame;
            
            NSLog(@"Frame Size after: %f : %f",frameSize.size.width, frameSize.size.height);
            
            //Move all views below content label.
            frameSize = self.postImage.frame;
            
            CGRect socialFrame = self.socialPanel.frame;
            
            //self.postImage.frame = CGRectMake(frameSize.origin.x, self.frame.size.height-(frameSize.size.height+50.0), frameSize.size.width, frameSize.size.height);
            
            self.socialPanel.frame = CGRectMake(socialFrame.origin.x, self.frame.size.height-(socialFrame.size.height+50.0), socialFrame.size.width, socialFrame.size.height);
            
            
//            
//            self.thumpsUpBtn.frame = CGRectMake(buttonFrameSize.origin.x, self.frame.size.height-(buttonFrameSize.size.height+50.0), buttonFrameSize.size.width, buttonFrameSize.size.height);
//            
//            self.commentBtn.frame = CGRectMake(self.commentBtn.frame.origin.x, self.frame.size.height-(buttonFrameSize.size.height+50.0), self.commentBtn.frame.size.width, self.commentBtn.frame.size.height);
//            
//            self.shareBtn.frame = CGRectMake(self.shareBtn.frame.origin.x, self.frame.size.height-(buttonFrameSize.size.height+50.0), self.shareBtn.frame.size.width, self.shareBtn.frame.size.height);
//            
//            
//            self.buttonsBack.frame = CGRectMake(self.buttonsBack.frame.origin.x, self.frame.size.height-(self.buttonsBack.frame.size.height+50.0) ,self.buttonsBack.frame.size.width , self.buttonsBack.frame.size.height);
//
//            
//            self.informationLabel.frame = CGRectMake(inforFrame.origin.x, self.frame.size.height-(inforFrame.size.height+73.0) , inforFrame.size.width, inforFrame.size.height);
        }
        else
        {
            self.contentLbl.frame = CGRectMake(self.contentLbl.frame.origin.x, self.contentLbl.frame.origin.y, self.contentLbl.frame.size.width, contentSize.height);

            NSLog(@"Frame Size after: %f : %f",self.contentLbl.frame.size.width, self.contentLbl.frame.size.height);
            
            


            
            if([self.contentLbl.text isEqualToString:@""])
            {
                return;
            }
            CGRect socialFrame = self.socialPanel.frame;
            
            //self.postImage.frame = CGRectMake(frameSize.origin.x, self.frame.size.height-(frameSize.size.height+50.0), frameSize.size.width, frameSize.size.height);
            
            self.socialPanel.frame = CGRectMake(socialFrame.origin.x, self.frame.size.height-(socialFrame.size.height+30.0), socialFrame.size.width, socialFrame.size.height);

            
        }
        

    }
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

//+(float) numberOfLinesUsingString: (NSString*)str
//{
//    float height = [PostCell getContentLabelHeightForContent:str];
//    
//    float numberOfLines = height/heightOfALine;
//    
//    return numberOfLines;
//}


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


//+ (CGFloat)getContentLabelHeightForContent:(NSString *)content
//{
//    CGSize maximumLabelSize = CGSizeMake(236, 60);
//    
//    CGFloat contentHeight = [content sizeWithFont: [UIFont systemFontOfSize:12.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByCharWrapping].height;
//    
//   //  NSLog(@"ONE LINE!\n%@",content);
//  //  NSLog(@"Content Height:%f",contentHeight);
//    
//    return contentHeight;
//}
//
//+ (CGFloat)getCellHeightWithContent:(NSString *)content andImage:(BOOL)containsImage
//{
//    // initial height
//    //float height = (isFirst) ? FirstCellOtherElementsTotalHeight : 0;
//    
//    float height = containsImage?StandardImageCellHeight:StandardTextCellHeight;
//
//    
//    // add content label height + message content view padding
//    height += [PostCell getContentLabelHeightForContent:content] + MessageContentViewPadding;
//    
//    return height + FollowingCellPadding;
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
