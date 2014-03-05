//
//  GroupCell.m
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GroupCell.h"
#import "ShapeFormatterHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebClient.h"

@interface GroupCell ()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;

@property (weak, nonatomic) IBOutlet UILabel *groupName;

@property (weak, nonatomic) UIViewController <GroupDeletedDelegate> *delegate;

@end


@implementation GroupCell

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //[self createElements];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setName:(NSString *)name withImageUrl:(NSString *)imageUrl andRemoteKey:(int)groupRemoteKey
{
    NSLog(@"Create Elements");
    
    //Add user's profile image.
    [_groupName setText:name];
    
    _groupName.tag = groupRemoteKey;
    
    //Add user's name.
    [ShapeFormatterHelper setRoundedView:_groupImage toDiameter:_groupImage.frame.size.height];
    
    if([imageUrl isEqualToString:@""])
    {
        [_groupImage setImage:[UIImage imageNamed:@"default_user_image2"]];
    }
    else
    {
        [_groupImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"default_user_image2"]];
    }
}

-(void)setDelegate:(UIViewController <GroupDeletedDelegate> *)delegate
{
    _delegate = delegate;
}

#pragma mark - Selectors

- (IBAction)quitGroup:(id)sender
{
    [[WebClient sharedInstance] quitFromAGroupWithRemoteKey:_groupName.tag callback:^(BOOL success) {
       
        if(success)
        {
            DDLogInfo(@"User not in group: %@ anymore", _groupName.text);
            [_delegate groupDeletedWithData:[[GLPGroup alloc] init]];
        }
        else
        {
            DDLogInfo(@"Failed to quit user from group: %@", _groupName.text);
        }
        
    }];
}


@end
