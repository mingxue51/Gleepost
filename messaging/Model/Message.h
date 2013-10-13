#import "_Message.h"
#import "SendStatus.h"
#import "NSNumber+Enums.h"

@interface Message : _Message {}

- (BOOL)followsPreviousMessage:(Message *)message;

@end
