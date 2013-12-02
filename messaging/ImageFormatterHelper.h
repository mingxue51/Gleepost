//
//  ImageFormatterHelper.h
//  Gleepost
//
//  Created by Σιλουανός on 11/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ImageFormatterHelper : NSObject

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToHeight: (float) finalHeight;
+(UIImage*)generateOnePixelHeightImageWithColour:(UIColor*)colour;

@end
