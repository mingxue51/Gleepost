//
//  GLPThemeManager.h
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPTheme.h"

@interface GLPThemeManager : NSObject

+(GLPThemeManager*)sharedInstance;

-(void)setNetwork:(NSString*)network;
-(NSString*)imageForChatBackground;
-(NSString*)imageForNavBar;
-(UIColor*)colorForTabBar;
-(NSString*)pullDownButton;
-(GLPThemeType)themeIdentifier;
- (NSString *)appNameWithString:(NSString *)string;
- (NSString *)lowerCaseAppName;
@end
