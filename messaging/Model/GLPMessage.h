/**
 Documentation for specific objects and variables.
 
 BOOL system
 If the system variable is true the message is system which means
 it's system's message to describe an action happned
 during the conversation.
 
 */


#import "GLPEntity.h"
#import "GLPUser.h"
#import "SendStatus.h"
#import "NSNumber+Enums.h"
#import "GLPConversation.h"
#import "GLPLiveConversation.h"

@class GLPUser;

typedef NS_ENUM(NSUInteger, KindOfMediaMessage) {
    kImageMessage,
    kPdfMessage,
    kTextMessage
};

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
@property (assign, nonatomic) KindOfMediaMessage kindOfMediaMessage;

- (BOOL)followsPreviousMessage:(GLPMessage *)message;
- (BOOL)isImageMessage;
- (NSString *)getContentFromMediaContent;
- (NSString *)getReadableContent;
- (BOOL)doesStringContainTimestamp:(NSString *)string;
+ (NSString *)formatMessageWithKindOfMedia:(KindOfMediaMessage)kindOfMedia withContent:(NSString *)content;

@end
