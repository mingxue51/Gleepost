#import "GLPUser.h"

@implementation GLPUser

@synthesize name=_name;
@synthesize profileImageUrl=_profileImageUrl;

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    return self;
}

- (BOOL)hasProfilePicture
{
    return _profileImageUrl && ![_profileImageUrl isEqualToString:@""];
}


-(NSString*)description
{
    return [NSString stringWithFormat:@"Remote Key: %d, Username: %@, Course: %@, Network: %@ - %d, Image: %@, Message: %@",self.remoteKey, self.name, self.course, self.networkName, self.networkId, self.profileImageUrl, self.personalMessage];
}

@end
