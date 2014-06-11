//
//  InfiniteScrollPicker.h
//  InfiniteScrollPickerExample
//
//  Created by Philip Yu on 6/6/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfiniteScrollViewPicker;

typedef NS_ENUM(NSInteger, ISVAnimationSpeed) {
    kSlow = 20,
    kMedium = 1,
    kFast = 100
};


@interface InfiniteScrollViewPicker : UIScrollView <UIScrollViewDelegate>
{
    NSMutableArray *imageStore;
    bool snapping;
    float lastSnappingX;
}

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) float alphaOfobjs;

@property (nonatomic) float heightOffset;
@property (nonatomic) float positionRatio;


- (void)setAutomaticScrollEnabled:(BOOL)automaticAnimationEnabled;

- (void)setAnimationSpeed:(ISVAnimationSpeed)animationSpeed;

- (void)setSelectedItem:(int)index;

- (void)setDistanceBetweenElements:(NSInteger)distance;

@end
