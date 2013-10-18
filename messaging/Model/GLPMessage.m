#import "GLPMessage.h"
#import "GLPUser.h"

@interface GLPMessage ()



@end


@implementation GLPMessage

@synthesize seen;
@synthesize sendStatus;
@synthesize content = _content;
@synthesize date = _date;
@synthesize author = _author;
@synthesize conversation = _conversation;

- (BOOL)followsPreviousMessage:(GLPMessage *)message
{
    if(message.author.remoteKey != self.author.remoteKey) {
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
