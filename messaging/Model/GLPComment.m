//
//  GLPComment.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPComment.h"

@implementation GLPComment

-(NSString *)description
{
    return [NSString stringWithFormat:@"Remote key: %d, Content: %@, Date: %@", self.remoteKey, self.content, self.date];
}

@end
