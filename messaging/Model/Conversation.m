#import "Conversation.h"
#import "GLPUser.h"
#import "SessionManager.h"


@interface Conversation ()

// Private interface goes here.

@end


@implementation Conversation

// Excludes the current user name
- (NSString *)getParticipantsNames
{
    NSMutableString *names = [NSMutableString string];
    
    if(self.participants.count < 2) {
        return @"Invalid conversation";
    }
    
    NSMutableArray *filteredParticipants = [NSMutableArray arrayWithCapacity:self.participants.count - 1];
    
    for(GLPUser *user in self.participants) {
        if(![user isEqualToEntity:[SessionManager sharedInstance].user]) {
            [filteredParticipants addObject:user];
        }
    }
    
    [filteredParticipants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GLPUser *user = obj;
        [names appendString:user.name];
        
        if(filteredParticipants.count > 1 && idx != filteredParticipants.count - 1) {
            if(idx == filteredParticipants.count - 2) {
                [names appendString:@" and "];
            } else {
                [names appendString:@", "];
            }
        }
    }];
    
    return names;
}

@end
