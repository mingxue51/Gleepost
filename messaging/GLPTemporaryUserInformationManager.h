//
//  GLPTemporaryUserInformationManager.h
//  Gleepost
//
//  Created by Silouanos on 26/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPTemporaryUserInformationManager : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) UIImage *image;

//Facebook attributes.
@property (assign, nonatomic) BOOL facebookMode;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *fbToken;

+ (GLPTemporaryUserInformationManager*)sharedInstance;
- (void)setEmail:(NSString *)email password:(NSString *)password andImage:(UIImage *)image;
- (NSString *)university;
- (BOOL)informationExistWithEmail:(NSString *)otherEmail;

@end
