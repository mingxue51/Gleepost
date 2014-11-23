//
//  GLPTheme.h
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kGLPDefaultTheme,
    kGLPStanfordTheme
    
} GLPThemeType;


@interface GLPTheme : NSObject

@property (assign, nonatomic) GLPThemeType identifier;
@property (strong, readonly) NSString *chatBackground;
@property (strong, readonly) NSString *navbar;
@property (strong, readonly) UIColor *tabbarColour;
@property (strong, readonly) NSString *pullDownImage;

-(id)initWithIdentifier:(GLPThemeType)identifier chatBackground:(NSString*)chatBackground navbarImageName:(NSString*)navBar tabbarTintColour:(UIColor*)tabbarColour pullDownImage:(NSString*)pullDownImage;

//- (id)initWithIdentifier:(GLPThemeType)identifier navbarImageName:()

@end
