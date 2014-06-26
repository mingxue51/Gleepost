//
//  TopTableViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 25/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TopTableViewCell : UITableViewCell

- (void)setImageWithUrl:(NSString *)url;
- (void)setDownloadedImage:(UIImage *)image;
- (void)setTitleWithString:(NSString *)title;
- (void)setSubtitleWithString:(NSString *)subtitle;
- (void)setSmallSubtitleWithString:(NSString *)smallSubtitle;

@end
