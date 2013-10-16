// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.h instead.

#import <CoreData/CoreData.h>
#import "WebEntity.h"

extern const struct CommentAttributes {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *dislikes;
	__unsafe_unretained NSString *likes;
} CommentAttributes;

extern const struct CommentRelationships {
	__unsafe_unretained NSString *author;
	__unsafe_unretained NSString *post;
} CommentRelationships;

extern const struct CommentFetchedProperties {
} CommentFetchedProperties;

@class GLPUser;
@class Post;






@interface CommentID : NSManagedObjectID {}
@end

@interface _Comment : WebEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommentID*)objectID;





@property (nonatomic, strong) NSString* content;



//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* date;



//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* dislikes;



@property int32_t dislikesValue;
- (int32_t)dislikesValue;
- (void)setDislikesValue:(int32_t)value_;

//- (BOOL)validateDislikes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* likes;



@property int32_t likesValue;
- (int32_t)likesValue;
- (void)setLikesValue:(int32_t)value_;

//- (BOOL)validateLikes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) GLPUser *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Post *post;

//- (BOOL)validatePost:(id*)value_ error:(NSError**)error_;





@end

@interface _Comment (CoreDataGeneratedAccessors)

@end

@interface _Comment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveContent;
- (void)setPrimitiveContent:(NSString*)value;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSNumber*)primitiveDislikes;
- (void)setPrimitiveDislikes:(NSNumber*)value;

- (int32_t)primitiveDislikesValue;
- (void)setPrimitiveDislikesValue:(int32_t)value_;




- (NSNumber*)primitiveLikes;
- (void)setPrimitiveLikes:(NSNumber*)value;

- (int32_t)primitiveLikesValue;
- (void)setPrimitiveLikesValue:(int32_t)value_;





- (GLPUser*)primitiveAuthor;
- (void)setPrimitiveAuthor:(GLPUser*)value;



- (Post*)primitivePost;
- (void)setPrimitivePost:(Post*)value;


@end
