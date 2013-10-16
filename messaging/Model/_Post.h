// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.h instead.

#import <CoreData/CoreData.h>
#import "WebEntity.h"

extern const struct PostAttributes {
	__unsafe_unretained NSString *commentsCount;
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *dislikes;
	__unsafe_unretained NSString *imagesUrls;
	__unsafe_unretained NSString *likes;
} PostAttributes;

extern const struct PostRelationships {
	__unsafe_unretained NSString *author;
	__unsafe_unretained NSString *comments;
} PostRelationships;

extern const struct PostFetchedProperties {
} PostFetchedProperties;

@class User;
@class Comment;








@interface PostID : NSManagedObjectID {}
@end

@interface _Post : WebEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PostID*)objectID;





@property (nonatomic, strong) NSNumber* commentsCount;



@property int32_t commentsCountValue;
- (int32_t)commentsCountValue;
- (void)setCommentsCountValue:(int32_t)value_;

//- (BOOL)validateCommentsCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* content;



//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* date;



//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* dislikes;



@property int32_t dislikesValue;
- (int32_t)dislikesValue;
- (void)setDislikesValue:(int32_t)value_;

//- (BOOL)validateDislikes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* imagesUrls;



//- (BOOL)validateImagesUrls:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* likes;



@property int32_t likesValue;
- (int32_t)likesValue;
- (void)setLikesValue:(int32_t)value_;

//- (BOOL)validateLikes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;





@end

@interface _Post (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(Comment*)value_;
- (void)removeCommentsObject:(Comment*)value_;

@end

@interface _Post (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCommentsCount;
- (void)setPrimitiveCommentsCount:(NSNumber*)value;

- (int32_t)primitiveCommentsCountValue;
- (void)setPrimitiveCommentsCountValue:(int32_t)value_;




- (NSString*)primitiveContent;
- (void)setPrimitiveContent:(NSString*)value;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSNumber*)primitiveDislikes;
- (void)setPrimitiveDislikes:(NSNumber*)value;

- (int32_t)primitiveDislikesValue;
- (void)setPrimitiveDislikesValue:(int32_t)value_;




- (NSString*)primitiveImagesUrls;
- (void)setPrimitiveImagesUrls:(NSString*)value;




- (NSNumber*)primitiveLikes;
- (void)setPrimitiveLikes:(NSNumber*)value;

- (int32_t)primitiveLikesValue;
- (void)setPrimitiveLikesValue:(int32_t)value_;





- (User*)primitiveAuthor;
- (void)setPrimitiveAuthor:(User*)value;



- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;


@end
