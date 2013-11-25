#import "GLPUser.h"


@interface GLPUser ()

// Private interface goes here.

@end


@implementation GLPUser

NSString * const GLPUserNameColumn = @"name";
NSString * const GLPUserProfileImageColumn = @"image_url";
NSString * const GLPUserCourseColumn = @"course";
NSString * const GLPUserNetworkIdColumn = @"network_id";
NSString * const GLPUserNetworkNameColumn = @"network_name";
NSString * const GLPUserPersonalMessageColumn = @"tagline";


@synthesize name = _name;


-(NSString*)description
{
    return [NSString stringWithFormat:@"Remote Key: %d, Username: %@, Course: %@, Network: %@ - %d, Image: %@, Message: %@",self.remoteKey, self.name, self.course, self.networkName, self.networkId, self.profileImageUrl, self.personalMessage];
}

@end
