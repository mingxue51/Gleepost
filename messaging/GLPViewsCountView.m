//
//  GLPViewsCountView.m
//  Gleepost
//
//  Created by Silouanos on 12/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPViewsCountView.h"

@interface GLPViewsCountView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewCountLabelWidth;
@property (weak, nonatomic) IBOutlet UILabel *viewsCountLabel;

@end

@implementation GLPViewsCountView

- (void)setViewsCount:(NSInteger)viewsCount
{
    NSString *labelText = nil;
    
    if(viewsCount == 0)
    {
        labelText = @"1";
    }
    else
    {
        labelText = [NSString stringWithFormat:@"%@", @(viewsCount)];
        
        [self setHidden:NO];

    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.viewsCountLabel setText:labelText];
        [_viewCountLabelWidth setConstant:[GLPViewsCountView getContentLabelSizeForContent:labelText] + 1];
    });
}

#pragma mark - Label size

+ (CGFloat)getContentLabelSizeForContent:(NSString *)content
{
    if(!content)
    {
        return 0.0;
    }
    
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){[GLPViewsCountView mainLabelMaxWidth], [GLPViewsCountView mainLabelMaxHeight]}
                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                               context:nil];
    CGSize size = rect.size;
    return size.width;
}

+ (CGFloat)mainLabelMaxHeight
{
    return 15.0;
}

+ (CGFloat)mainLabelMaxWidth
{
    return 280.0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
