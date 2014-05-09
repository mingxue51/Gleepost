


#import "GLPEntity.h"

@interface GLPUser : GLPEntity

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) NSString *course;
@property (strong, nonatomic) NSString *networkName;
@property int networkId;
@property (strong, nonatomic) NSString *personalMessage;
@property (strong, nonatomic) NSString *email;


-(id)initWithName:(NSString *)name withId:(NSInteger)key andImageUrl:(NSString *)imgUrl;
- (BOOL)hasProfilePicture;


@end
