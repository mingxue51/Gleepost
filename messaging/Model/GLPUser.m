#import "GLPUser.h"

#import "SessionManager.h"

@implementation GLPUser

@synthesize name=_name;
@synthesize profileImageUrl=_profileImageUrl;

- (id)init
{
    self = [super init];
    if(self)
    {
        _rsvpCount = [[NSNumber alloc] init];
        _groupCount = [[NSNumber alloc] init];
        _postsCount = [[NSNumber alloc] init];
    }
    
    return self;
}

- (id)initWithRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    
    if(self)
    {
        self.remoteKey = remoteKey;
    }
    
    return self;
}

-(id)initWithName:(NSString *)name withId:(NSInteger)key andImageUrl:(NSString *)imgUrl
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.key = key;
        self.profileImageUrl = imgUrl;
    }
    
    return self;
}

- (id)initWithUser:(GLPUser *)user
{
    self = [super init];
    
    if(self)
    {
        self.name = user.name;
        self.profileImageUrl = user.profileImageUrl;
        self.course = user.course;
        self.networkName = user.networkName;
        self.personalMessage = user.personalMessage;
        self.email = user.email;
        self.remoteKey = user.remoteKey;
        self.key = user.key;
        self.networkId = user.networkId;
    }
    return self;
}

- (BOOL)hasProfilePicture
{
    return _profileImageUrl && ![_profileImageUrl isEqualToString:@""];
}

- (BOOL)isLoggedInUser
{
    return [[SessionManager sharedInstance] user].remoteKey == self.remoteKey;
}

/**
 Implement copyWithZone method in order to copy each object that is encapsulated
 to GLPUser object and not just the reference of the GLPUser object.
 */
- (id)copyWithZone:(NSZone *)zone
{
    GLPUser *copy = [[[self class] alloc] init];
        
    if (copy) {
        // Copy NSObject subclasses.
        copy.name = [self.name copyWithZone:zone];
        copy.profileImageUrl = [self.profileImageUrl copyWithZone:zone];
        copy.course = [self.course copyWithZone:zone];
        copy.networkName = [self.networkName copyWithZone:zone];
        copy.personalMessage = [self.personalMessage copyWithZone:zone];
        copy.email = [self.email copyWithZone:zone];
        
        // Set primitives
        copy.remoteKey = self.remoteKey;
        copy.key = self.key;
        copy.networkId = self.networkId;
    }
    
    return copy;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"Remote Key: %d, Username: %@, Image: %@, Message: %@, Rsvps: %@, Groups: %@, Posts: %@",self.remoteKey, self.name, self.profileImageUrl, self.personalMessage, _rsvpCount, _groupCount, _postsCount];
}

@end
