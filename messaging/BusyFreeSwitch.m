//
//  BusyFreeSwitch.m
//  Gleepost
//
//  Created by Σιλουανός on 9/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "BusyFreeSwitch.h"
#import "WebClient.h"
#import "UICKeyChainStore.h"

@implementation BusyFreeSwitch

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self initialiseSwitch];
    }
    
    return self;
}

-(void)initialiseSwitch
{
    [self getBusyStatus];
    
    [self addTarget:self action:@selector(statusChanged:) forControlEvents:UIControlEventValueChanged];
}


-(void)statusChanged:(id)sender
{
    [[WebClient sharedInstance] setBusyStatus:!self.isOn callbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Do something.
            [self saveState];
        }
    }];
}

#pragma mark - Client

-(void)getBusyStatus
{
    [self loadAndSetState];

    [[WebClient sharedInstance] getBusyStatus:^(BOOL success, BOOL status) {
        
        if(success)
        {
            [self setOn:!status];
        }
    }];
}

#pragma mark - Save locally

-(void)saveState
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    
    [store setString:(self.on) ? @"1" : @"0" forKey:@"busyfreeswitch"];

    [store synchronize];
}

-(void)loadAndSetState
{
    NSString *strState = [UICKeyChainStore stringForKey:@"busyfreeswitch"];
    
    [self setOn:([strState isEqualToString:@"1"]) ? YES : NO];
    
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
