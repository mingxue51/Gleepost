//
//  GLPLike.m
//  Gleepost
//
//  Created by Σιλουανός on 22/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLike.h"

@implementation GLPLike

-(id)initWithUser:(GLPUser*)user withDate:(NSDate*)date andPost:(GLPPost*)post
{
    self = [super init];
    
    if(self)
    {
        self.author = user;
        self.date = date;
        self.post = post;
    }

    return self;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"Author name: %@, Date: %@, Post content: %@",self.author.name, self.date.description, self.post.content];
}

@end
