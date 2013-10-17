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
    
    int count = self.participants.count - 1;
    [[self.participants allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GLPUser *user = obj;
        
        // ignore current user
        if([user isEqualToWebEntity:[SessionManager sharedInstance].user]) {
            return;
        }
            
//            isEqualToNumber:[NSNumber numberWithInteger:[SessionManager sharedInstance].key]]) {
//            return;
//        }
        
        [names appendString:user.name];
        
        if(count > 1 && idx != count - 1) {
            if(idx == count - 2) {
                [names appendString:@" and "];
            } else {
                [names appendString:@", "];
            }
        }
    }];
    
    return names;
}

@end
