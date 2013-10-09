//
//  ChatMessageTableViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 20/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageTableViewCell : UITableViewCell


/** User's image or opponent's */
@property (strong, nonatomic) UIButton *userImageButton;

/** The content of the message */
@property (nonatomic, retain) UITextView *messageTextView;

/** Date the message has been sent. (Not user at the moment). */
@property (nonatomic, retain) UILabel *date;

/** The bubble of message. */
@property (nonatomic, retain) UIImageView *backgroundImageView;

/** The time the message was sent or received. */
@property (nonatomic, retain) UILabel *timeLabel;



-(void) createElements;

@end
