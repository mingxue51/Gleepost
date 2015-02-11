


#import "GLPEntity.h"

@interface GLPUser : GLPEntity

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) NSString *course;
@property (strong, nonatomic) NSString *networkName;
@property (assign, nonatomic) NSInteger networkId;
@property (strong, nonatomic) NSString *personalMessage;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *rsvpCount;
@property (strong, nonatomic) NSNumber *groupCount;
@property (strong, nonatomic) NSNumber *postsCount;
@property (strong, nonatomic) NSString *facebookTemporaryToken;


-(id)initWithName:(NSString *)name withId:(NSInteger)key andImageUrl:(NSString *)imgUrl;
- (id)initWithUser:(GLPUser *)user;
- (id)initWithRemoteKey:(NSInteger)remoteKey;
- (BOOL)hasProfilePicture;
- (BOOL)isUpdatedUserData:(GLPUser *)userData;
- (BOOL)isLoggedInUser;
@end
