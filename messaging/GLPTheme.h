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

-(id)initWithIdentifier:(GLPThemeType)identifier chatBackground:(NSString*)chatBackground andNavbarImageName:(NSString*)navBar andTabbarTintColour:(UIColor*)tabbarColour;

@end
