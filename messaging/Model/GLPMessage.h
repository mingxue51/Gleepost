#import "GLPEntity.h"
#import "GLPUser.h"
#import "SendStatus.h"
#import "NSNumber+Enums.h"
#import "GLPConversation.h"
#import "GLPLiveConversation.h"

//@class GLPConversation;
@class GLPUser;

@interface GLPMessage : GLPEntity <NSCopying>

@property (assign, nonatomic) BOOL seen;
@property (assign, nonatomic) BOOL isOld;
@property (assign, nonatomic) NSInteger displayOrder;
@property (assign, nonatomic) SendStatus sendStatus;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) GLPUser *author;
@property (strong, nonatomic) GLPConversation *conversation;
@property (assign, nonatomic) BOOL belongsToGroup;

- (BOOL)followsPreviousMessage:(GLPMessage *)message;

@end
