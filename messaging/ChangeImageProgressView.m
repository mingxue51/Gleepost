//
//  ChangeImageProgressView.m
//  Gleepost
//
//  Created by Σιλουανός on 9/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ChangeImageProgressView.h"
#import "AppearanceHelper.h"


@implementation ChangeImageProgressView

const NSString *DATA_WRITTEN_PROF = @"data_written";
const NSString *DATA_EXPECTED_PROF = @"data_expected";

- (id)init
{
    self = [super init];
    
    if(self)
    {
        [self configureProgressView];
        [self configureNotifications];
    }
    
    return self;
}

- (void)dealloc
{
    [self deregisterNotifications];
}

- (void)configureProgressView
{
    [self setTintColor:[AppearanceHelper blueGleepostColour]];

    [self setProgressViewStyle:UIProgressViewStyleBar];

    [self setAlpha:0.0];
    
    [self setHidden:YES];
    
    [self setProgress:0.0];
    
    CGRectSetY(self, 62);
    
    CGRectSetW(self, 320);
}

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadingProgress:) name:GLPNOTIFICATION_CHANGE_IMAGE_PROGRESS object:nil];
}

- (void)deregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_CHANGE_IMAGE_PROGRESS object:nil];
}

#pragma mark - Notifications

- (void)uploadingProgress:(NSNotification *)notification
{
    if([self isHidden])
    {
        [self show];
    }
    
    NSDictionary *userInfo = notification.userInfo;
    
    if(userInfo[DATA_WRITTEN_PROF])
    {
        [self updateProgressWithData:userInfo];
    }
    else if(userInfo[@"image_ready"])
    {
        DDLogDebug(@"Image is ready");
        
        [self hideAndReset];
    }
    

}

#pragma mark - UI

- (void)updateProgressWithData:(NSDictionary *)progress
{
    DDLogDebug(@"Uploading progress: %@", progress);
    
    NSNumber *dataWritten = progress[DATA_WRITTEN_PROF];
    
    NSNumber *dataExpected = progress[DATA_EXPECTED_PROF];
    
    [self setProgress:[dataWritten floatValue]/[dataExpected floatValue]];
}

- (void)show
{
    [self setHidden:NO];

    [UIView animateWithDuration:0.5 animations:^{
       
        [self setAlpha:1.0];
        
    }];
}

- (void)hideAndReset
{
    [UIView animateWithDuration:0.5 animations:^{
       
        [self setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
        [self setHidden:YES];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
