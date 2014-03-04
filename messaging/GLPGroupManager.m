//
//  GLPGroupManager.m
//  Gleepost
//
//  Created by Σιλουανός on 3/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupManager.h"
#import "GLPGroup.h"


@implementation GLPGroupManager


+(NSDictionary *)processGroups:(NSArray *)groups
{
    NSMutableArray *groupsStr = [[NSMutableArray alloc] init];
    
    NSArray *sections = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    
    for (GLPGroup *group in groups)
    {
        [groupsStr addObject:group.name];
    }
    
    NSArray *finalSections = [self clearUselessSectionsWithSections:sections andGroups:groups];
    
    NSDictionary *categorisedGroups = [self categoriseByLetterWithSections:finalSections andGroups:groups];
    
    
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:groupsStr, @"GroupNames", categorisedGroups, @"CategorisedGroups", finalSections, @"Sections" ,nil];
}

+(NSArray *)clearUselessSectionsWithSections:(NSArray *)sections andGroups:(NSArray *)groups
{
    BOOL sectionFound = NO;
    NSMutableArray *deletedSections = [[NSMutableArray alloc] init];
    NSMutableArray *finalSections = sections.mutableCopy;
    
    for(NSString* letter in sections)
    {
        for(GLPGroup* group in groups)
        {
            NSString* userName = group.name;
            //Get the first letter of the user.
            NSString* firstLetter = [userName substringWithRange: NSMakeRange(0, 1)];
            
            if([firstLetter caseInsensitiveCompare:letter] == NSOrderedSame)
            {
                sectionFound = YES;
            }
        }
        
        //Delete a section if it is not necessary.
        if(!sectionFound)
        {
            [deletedSections addObject:letter];
        }
        else
        {
            sectionFound = NO;
        }
    }
    
    //Remove sections.
    for(NSString* letter in deletedSections)
    {
        [finalSections removeObject:letter];
    }
    
    return finalSections;
}

+(NSDictionary *)categoriseByLetterWithSections:(NSArray *)sections andGroups:(NSArray *)groups
{
    int indexOfLetter = 0;
    BOOL sectionFound = NO;
    NSMutableArray *deletedSections = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *categorisedGroups = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *finalSections = sections.mutableCopy;
    
    //NSNumber* indexOfLetter = [[NSNumber alloc] initWithInt:0];
    
    for(NSString* letter in sections)
    {
        for(GLPGroup* group in groups)
        {
            NSString* name = group.name;
            //Get the first letter of the user.
            NSString* firstLetter = [name substringWithRange: NSMakeRange(0, 1)];
            
            if([firstLetter caseInsensitiveCompare:letter] == NSOrderedSame)
            {
                sectionFound = YES;
                
                //Check if the dictonary has previous elements in the current key.
                NSMutableArray *currentUsers = [categorisedGroups objectForKey:[NSNumber numberWithInt:indexOfLetter]];
                
                if(currentUsers == nil)
                {
                    currentUsers = [[NSMutableArray alloc] init];
                    [currentUsers addObject:group];
                }
                else
                {
                    //Add the user to the existing section.
                    [currentUsers addObject:group];
                }
                
                [categorisedGroups setObject:currentUsers forKey:[NSNumber numberWithInt:indexOfLetter]];
                
            }
        }
        
        //Delete a section if it is not necessary.
        if(!sectionFound)
        {
            [deletedSections addObject:letter];
        }
        else
        {
            sectionFound = NO;
        }
        
        ++indexOfLetter;
    }
    
    //Remove sections.
    for(NSString* letter in deletedSections)
    {
        [finalSections removeObject:letter];
    }
    
    return categorisedGroups;
}


@end
