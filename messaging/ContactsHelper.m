//
//  ContactsHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 11/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ContactsHelper.h"
#import "ContactsManager.h"

@implementation ContactsHelper

/**
 If YES navigate to real profile, if no to private profile.
 */
+(BOOL)navigateToUnlockedProfileWithSelectedUserId:(int)selectedId
{
    //Check if the user is already in contacts.
    //If yes show the regular profie view (unlocked).
    if([[ContactsManager sharedInstance] isUserContactWithId:selectedId])
    {
        NSLog(@"PrivateProfileViewController : Unlock Profile.");
        
        return YES;
    }
    else
    {
        //If no, check in database if the user is already requested.
        
        //If yes change the button of add user to user already requested.
        
        if([[ContactsManager sharedInstance] isContactWithIdRequested:selectedId])
        {
            NSLog(@"PrivateProfileViewController : User already requested by you.");
            //            UIImage *img = [UIImage imageNamed:@"invitesent"];
            //            [self.addUserButton setImage:img forState:UIControlStateNormal];
            //            [self.addUserButton setEnabled:NO];
            //
            //For now just navigate to the unlocked profile.
            
            return YES;
            
        }
        else
        {
            //If not show the private profile view as is.
            NSLog(@"PrivateProfileViewController : Private profile as is.");
            
            return NO;
        }
    }
}

@end
