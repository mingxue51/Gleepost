//
//  GLPNewElementsIndicatorView.m
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPNewElementsIndicatorView.h"

@interface GLPNewElementsIndicatorView()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

- (IBAction)pushed:(id)sender;

@end


@implementation GLPNewElementsIndicatorView

@synthesize delegate=_delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    [self configure];
    
    return self;
}

- (id)initWithDelegate:(id<GLPNewElementsIndicatorViewDelegate>) delegate
{
    self = [super initWithFrame:CGRectMake(0, 0, 160, 69)];
    if(!self) {
        return nil;
    }
    
    [self configure];
    _delegate = delegate;
    
    return self;
}

- (void)configure
{
    [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"GLPNewElementsIndicatorView" owner:self options:nil] objectAtIndex:0]];
}

- (IBAction)pushed:(id)sender
{
    if(_delegate) {
        [_delegate newElementsIndicatorViewPushed];
    }
}

@end
