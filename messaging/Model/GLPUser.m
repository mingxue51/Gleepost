#import "GLPUser.h"


@interface GLPUser ()

// Private interface goes here.

@end


@implementation GLPUser

NSString * const GLPUserNameColumn = @"name";

@synthesize name = _name;


-(NSString*)description
{
    return [NSString stringWithFormat:@"Username: %@, Course: %@, Network: %@ - %d, Image: %@, Message: %@",self.name, self.course, self.networkName, self.networkId, self.profileImageUrl, self.personalMessage];
}

@end
