//
//  GLPOperationManager.m
//  Gleepost
//
//  Created by Σιλουανός on 6/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPOperationManager.h"

@implementation GLPOperationManager

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _imageUploader = [[GLPImageUploaderManager alloc] init];

    }
    
    return self;
}

-(void)uploadImage:(UIImage *)image withTimestamp:(NSDate *)timestamp
{
    //Upload image with timestasmp.
    [_imageUploader uploadImage:image withTimestamp:timestamp];
    [_checkForUploadingTimer fire];
}

-(void)stopTimer
{
    [self.checkForUploadingTimer invalidate];
}

@end
