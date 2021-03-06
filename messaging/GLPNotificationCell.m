//
//  GLPNotificationCell.m
//  Gleepost
//
//  Created by Σιλουανός on 9/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPNotificationCell.h"
#import "ShapeFormatterHelper.h"
#import "GLPNotification.h"
#import "NSDate+TimeAgo.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"
#import "GLPImageHelper.h"

@interface GLPNotificationCell ()

@property (weak, nonatomic) IBOutlet GLPImageView *notificationImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *invitationButtonsView;

@property (strong, nonatomic) GLPNotification *notification;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstrain;

@end

@implementation GLPNotificationCell

const float MAX_NOTIFICATION_CONTENT_HEIGHT = 40.0;
const float MAX_NOTIFICATION_CONTENT_WIDHT = 240.0;
const float NOTIFICATION_CELL_HEIGHT = 43.0; //60.0

- (void)awakeFromNib
{
    [self configureNotificationImageView];
    
    [self initialiseElements];
}

- (void)initialiseElements
{
    [_invitationButtonsView setHidden:YES];
}

- (void)configureNotificationImageView
{
    [ShapeFormatterHelper setRoundedView:_notificationImageView toDiameter:_notificationImageView.frame.size.height];
}

#pragma mark - Modifiers

- (void)setNotification:(GLPNotification *)notification
{
    _notification = notification;
    
    [self configureContent];
    
    [self configureImage];
    
    [self configureTime];
}

- (void)configureTime
{
    [_timeLabel setText:[_notification.date timeAgo]];
}

- (void)configureImage
{
    //Takes the user's image and add it to image.
    GLPUser *user = _notification.user;
    
    _notificationImageView.delegate = _delegate;
    
    [_notificationImageView setImageUrl:user.profileImageUrl withPlaceholderImage:[GLPImageHelper placeholderUserImagePath]];
    
    [_notificationImageView setGesture:YES];
    
    _notificationImageView.tag = user.remoteKey;
}

- (void)configureContent
{
    NSString *content = _notification.notificationTypeDescription;
    
    [_contentLabel setText:content];
    
    [_contentHeightConstrain setConstant:[GLPNotificationCell getContentLabelSizeForContent:content].height];
}

#pragma mark - Heights

+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    
    UIFont *font = [UIFont fontWithName:GLP_HELV_NEUE_LIGHT size:14.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){[GLPNotificationCell getMaxTitleLabelHeight], MAX_NOTIFICATION_CONTENT_HEIGHT}
                                               options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                               context:nil];
    
    
    CGSize size = rect.size;
    return size;
}

+ (CGFloat)getCellHeightForNotification:(GLPNotification *)notification
{
    //TODO: Depending on the kind of the notification change the height of the cell and reorder
    //the elements if needed.
    
    float finalHeight =  NOTIFICATION_CELL_HEIGHT;
    
    
    switch (notification.notificationType) {
            
        case kGLPNotificationTypeInvitedYouToGroup:
            finalHeight += 10.0;
            break;
            
        case kGLPNotificationTypeLiked:
        case kGLPNotificationTypeCommented:
        case kGLPNotificationTypeCreatedPostGroup:
            
        default:
            break;
    }
    
    finalHeight += [GLPNotificationCell getContentLabelSizeForContent:[notification notificationTypeDescription]].height;
    
    
    
    return finalHeight;
}

+ (CGFloat)getMaxTitleLabelHeight
{
    return [[UIScreen mainScreen] bounds].size.width - 80;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
