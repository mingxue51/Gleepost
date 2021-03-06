//
//  TopTableViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 25/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopTableViewCellDelegate <NSObject>

@required
- (void)mainImageViewTouched;

@optional
- (void)badgeTouched;
- (void)numberOfPostTouched;
- (void)numberOfGroupsTouched;
- (void)numberOfRsvpsTouched;

@end

@interface TopTableViewCell : UITableViewCell

@property (weak, nonatomic) UITableViewCell<TopTableViewCellDelegate> *subClassdelegate;

- (void)setImageWithUrl:(NSString *)url;
- (void)setDownloadedImage:(UIImage *)image;
- (void)setSubtitleWithString:(NSString *)subtitle;
- (void)setSmallSubtitleWithString:(NSString *)smallSubtitle;
- (void)setNumberOfPosts:(NSInteger)number;
- (void)setNumberOfMemberships:(NSInteger)number;
- (void)setNumberOfRsvps:(NSInteger)number;
- (UIImage *)mainImageViewImage;
@end
