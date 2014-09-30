//
//  EmptyMessage.h
//  Gleepost
//
//  Created by Silouanos on 06/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmptyMessage : NSObject

typedef enum {
    
    EmptyMessagePositionCenter,
    EmptyMessagePositionBottom,
    EmptyMessagePositionFurtherBottom,
    EmptyMessagePositionTop,
    
} EmptyMessagePosition;

@property (strong, nonatomic) UIView *emptyMessageView;

-(id)initWithText:(NSString *)text withPosition:(EmptyMessagePosition)position andTableView:(UITableView *)tableView;
- (void)setTitle:(NSString *)title;
-(void)hideEmptyMessageView;
-(void)showEmptyMessageView;

@end
