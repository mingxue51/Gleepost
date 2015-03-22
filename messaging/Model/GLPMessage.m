#import "GLPMessage.h"
#import "GLPUser.h"

@implementation GLPMessage

@synthesize seen = _seen;
@synthesize sendStatus = _sendStatus;
@synthesize content = _content;
@synthesize date = _date;
@synthesize author = _author;
@synthesize conversation = _conversation;
@synthesize isOld = _isOld;

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }

    // default values
    _isOld = NO;
    _sendStatus = kSendStatusLocal;
    _belongsToGroup = NO;
    return self;
}


- (BOOL)followsPreviousMessage:(GLPMessage *)message
{    
    NSTimeInterval interval = [_date timeIntervalSinceDate:message.date];
    
    //If the interval is more than fifteen minutes then return NO, otherwise YES.
    if(interval > 900)
    {
        return NO;
    }
    
    return YES;
}


# pragma mark - Copy

-(id)copyWithZone:(NSZone *)zone
{
    GLPMessage *message = [super copyWithZone:zone];
    message.seen = _seen;
    message.isOld = _isOld;
    message.displayOrder = _displayOrder;
    message.sendStatus = _sendStatus;
    message.content = [_content copyWithZone:zone];
    message.date = [_date copyWithZone:zone];
    message.author = _author;
    message.conversation = _conversation;
    message.belongsToGroup = _belongsToGroup;
    
    return message;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Message key %ld, Content %@, Seen %d", (long)self.remoteKey, _content, _seen];
}

@end
