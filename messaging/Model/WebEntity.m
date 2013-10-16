#import "WebEntity.h"


@interface WebEntity ()

// Private interface goes here.

@end


@implementation WebEntity

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
