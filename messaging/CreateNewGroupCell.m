//
//  CreateNewGroupCell.m
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CreateNewGroupCell.h"
#import "WebClient.h"
#import "WebClientHelper.h"
@interface CreateNewGroupCell ()

@property (weak, nonatomic) UIViewController<GroupCreatedDelegate> *delegate;

@end

@implementation CreateNewGroupCell

const float NEW_GROUP_CELL_HEIGHT = 55;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDelegate:(UIViewController<GroupCreatedDelegate> *)delegate
{
    
    _delegate = delegate;
}

- (IBAction)createNewGroup:(id)sender
{
    
    [_delegate popUpCreateView];
    
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Group name" message:@"Please enter the name of your new group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create",nil];
//    
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    
//    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
        return;
    }
    
    NSString *groupName = [alertView textFieldAtIndex:0].text;
    
    if([groupName isEqualToString:@""])
    {
        [WebClientHelper showEmptyTextError];
        
        return;
    }
    
    [self executeGroupCreationWithName:[[alertView textFieldAtIndex:0] text]];
}


#pragma mark - Client

-(void)executeGroupCreationWithName:(NSString *)groupName
{

}

@end
