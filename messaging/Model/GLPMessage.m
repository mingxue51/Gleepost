#import "GLPMessage.h"
#import "User.h"

@interface GLPMessage ()

// Private interface goes here.

@end


@implementation GLPMessage

- (BOOL)followsPreviousMessage:(GLPMessage *)message
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
