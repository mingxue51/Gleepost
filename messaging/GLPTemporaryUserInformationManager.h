//
//  GLPTemporaryUserInformationManager.h
//  Gleepost
//
//  Created by Silouanos on 26/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPTemporaryUserInformationManager : NSObject

+(GLPTemporaryUserInformationManager*)sharedInstance;

-(void)setEmail:(NSString *)email andImage:(UIImage *)image;

-(NSString *)email;
-(UIImage *)image;
-(BOOL)informationExistWithEmail:(NSString *)otherEmail;

@end
