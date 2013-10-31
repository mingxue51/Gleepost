#import "GLPEntity.h"

@interface GLPUser : GLPEntity

extern NSString * const GLPUserNameColumn;
extern NSString * const GLPUserProfileImageColumn;
extern NSString * const GLPUserCourseColumn;
extern NSString * const GLPUserNetworkIdColumn;
extern NSString * const GLPUserNetworkNameColumn;
extern NSString * const GLPUserPersonalMessageColumn;



@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) NSString *course;
@property (strong, nonatomic) NSString *networkName;
@property int networkId;
@property (strong, nonatomic) NSString *personalMessage;


//TODO: In the future add all the elements.

@end
