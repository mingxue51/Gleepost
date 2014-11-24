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
    kGLPStanfordTheme,
    kGLPUICTheme
    
} GLPThemeType;


@interface GLPTheme : NSObject

@property (assign, nonatomic) GLPThemeType identifier;
@property (strong, readonly) NSString *chatBackground;
@property (strong, readonly) NSString *navbar;
@property (strong, readonly) UIColor *tabbarColour;
@property (strong, readonly) NSString *pullDownImage;

@property (strong, readonly, nonatomic) UIColor *firstColour;
@property (strong, readonly, nonatomic) UIColor *secondColour;
@property (strong, readonly, nonatomic) UIColor *thirdColour;
@property (strong, readonly, nonatomic) UIColor *fourthColour;
@property (strong, readonly, nonatomic) UIColor *fifthColour;
@property (strong, readonly, nonatomic) UIColor *sixthColour;


//-(id)initWithIdentifier:(GLPThemeType)identifier chatBackground:(NSString*)chatBackground navbarImageName:(NSString*)navBar tabbarTintColour:(UIColor*)tabbarColour pullDownImage:(NSString*)pullDownImage;

- (id)initWithIdentifier:(GLPThemeType)identifier firstColour:(UIColor *)firstColour secondColour:(UIColor *)secondColour thirdColour:(UIColor *)thirdColour fourthColour:(UIColor *)fourthColour fifthColour:(UIColor *)fifthColour;

- (UIImage *)navigationBarImage;
- (UIImage *)leftItemColouredImage:(UIImage *)leftImage;
- (UIImage *)rightItemColouredImage:(UIImage *)rightImage;

@end
