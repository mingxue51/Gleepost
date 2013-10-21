#import "GLPEntity.h"

@interface GLPUser : GLPEntity

extern NSString * const GLPUserNameColumn;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *profileImageUrl;
//TODO: In the future add all the elements.

@end
