#import "_GLPMessage.h"
#import "SendStatus.h"
#import "NSNumber+Enums.h"

@interface GLPMessage : _GLPMessage {}

- (BOOL)followsPreviousMessage:(GLPMessage *)message;

@end
