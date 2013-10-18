#import "GLPEntity.h"
#import "GLPUser.h"
#import "SendStatus.h"
#import "NSNumber+Enums.h"
#import "GLPConversation.h"

//@class GLPConversation;
@class GLPUser;

@interface GLPMessage : GLPEntity

@property (assign, nonatomic) BOOL seen;
@property (assign, nonatomic) SendStatus sendStatus;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) GLPUser *author;
@property (strong, nonatomic) GLPConversation *conversation;

- (BOOL)followsPreviousMessage:(GLPMessage *)message;

@end
