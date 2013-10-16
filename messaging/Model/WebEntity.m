#import "WebEntity.h"


@interface WebEntity ()

// Private interface goes here.

@end


@implementation WebEntity

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToWebEntity:other];
}

- (BOOL) isEqualToWebEntity:(WebEntity *)webEntity
{
    if(self == webEntity) {
        return YES;
    }
    
    if([self.remoteKey isEqual:webEntity.remoteKey]) {
        return YES;
    }
    
    return NO;
}

@end
