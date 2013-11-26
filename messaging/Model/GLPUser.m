#import "GLPUser.h"


@interface GLPUser ()

// Private interface goes here.

@end


@implementation GLPUser


@synthesize name = _name;
@synthesize profileImageUrl=_profileImageUrl;

- (BOOL)hasProfilePicture
{
    return _profileImageUrl && ![_profileImageUrl isEqualToString:@""];
}


-(NSString*)description
{
    return [NSString stringWithFormat:@"Remote Key: %d, Username: %@, Course: %@, Network: %@ - %d, Image: %@, Message: %@",self.remoteKey, self.name, self.course, self.networkName, self.networkId, self.profileImageUrl, self.personalMessage];
}

@end
