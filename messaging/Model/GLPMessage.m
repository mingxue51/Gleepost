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
    _kindOfMediaMessage = kTextMessage;
    return self;
}

- (void)setContent:(NSString *)content
{
    _content = content;
    
    if([self isImageMessage])
    {
        _kindOfMediaMessage = kImageMessage;
    }
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

/**
    This method should be called ONLY from GLPMessageCell and ONLY in case
    the message is media message.
 
    @return Returns the content of the content when the message is media message.
    e.g. In case of image url content.
 */
- (NSString *)getContentFromMediaContent
{
    return [self parseMediaContent][0];
}

/**
    @return returns the readable content for message. This method 
    is used because in case of media content, the content is not
    readable but it's a specific pattern of string.
 */
- (NSString *)getReadableContent
{
    switch (self.kindOfMediaMessage) {
        case kImageMessage:
            return [NSString stringWithFormat:@"%@ sent an image", self.author.name];
            break;
            
        default:
            return _content;
            break;
    }
}

- (BOOL)isImageMessage
{
    if(![self.content componentsSeparatedByString:@" "])
    {
        return NO;
    }
    
    // A list of extensions to check against
    NSArray *imageExtensions = @[@"png", @"jpg", @"gif"];
    
    NSString *urlString = [self parsePossibleImageMessage];
    
    if([self doesStringContainTimestamp:urlString])
    {
        return YES;
    }
    
    if(!urlString)
    {
        return NO;
    }
    
    // Iterate & match the URL objects from your checking results
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *extension = [url pathExtension];
    
    if ([imageExtensions containsObject:extension])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)doesStringContainTimestamp:(NSString *)string
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    return [nf numberFromString:string] != nil;
}

/**
    Try to parse the message's content. If the content does not satisfies the 
    media format returns nil. Otherwise it returns the image url.
 */
- (NSString *)parsePossibleImageMessage
{
    NSArray *parsedMediaContent = [self parseMediaContent];
    
    NSString *metadataImagePattern = [GLPMessage getImagePatternWithKindOfMediaMessage:kImageMessage];
    
    if(!parsedMediaContent || ![parsedMediaContent[1] isEqualToString:metadataImagePattern])
    {
        return nil;
    }
    
    return parsedMediaContent[0];
}

- (NSArray *)parseMediaContent
{
    if(![self.content containsString:@"|"] || ![self.content containsString:@"<"] || ![self.content containsString:@">"])
    {
        return nil;
    }
    
    NSArray *parsedContent = [self.content componentsSeparatedByString:@"|"];
    
    if(parsedContent.count < 2)
    {
        return nil;
    }
    
    NSMutableString *firstComponent = [NSMutableString stringWithString:parsedContent[0]];
    [firstComponent deleteCharactersInRange:NSMakeRange(0, 1)];
    
    NSMutableString *secondComponent = [NSMutableString stringWithString:parsedContent[1]];
    [secondComponent deleteCharactersInRange:NSMakeRange(secondComponent.length - 1, 1)];
    
    return @[firstComponent, secondComponent];
}

#pragma mark - Static

/**
    Formats the message to the specific media format.
 */
+ (NSString *)formatMessageWithKindOfMedia:(KindOfMediaMessage)kindOfMedia withContent:(NSString *)content
{
    NSString *metaDataMediaFormat = [GLPMessage getImagePatternWithKindOfMediaMessage:kindOfMedia];
    return [NSString stringWithFormat:@"<%@|%@>", content, metaDataMediaFormat];
}

+ (NSString *)getImagePatternWithKindOfMediaMessage:(KindOfMediaMessage)kindOfMedia
{
    NSString *metaDataMediaFormat = @"";
    
    switch (kindOfMedia) {
        case kImageMessage:
            metaDataMediaFormat = @"image";
            break;
            
        case kPdfMessage:
            metaDataMediaFormat = @"pdf";
            break;
            
        default:
            break;
    }
    
    return metaDataMediaFormat;
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
