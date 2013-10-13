#import "Message.h"
#import "User.h"

@interface Message ()

// Private interface goes here.

@end


@implementation Message

- (BOOL)followsPreviousMessage:(Message *)message
{
    if(![message.author.remoteKey isEqualToNumber:self.author.remoteKey]) {
        return NO;
    }
    
    //    NSTimeInterval interval = [self.date timeIntervalSinceDate:message.date];
    //    NSLog(@"time interval %f", interval);
    //    if(interval / 60 > 15) {
    //        return NO;
    //    }
    
    return YES;
}

@end
