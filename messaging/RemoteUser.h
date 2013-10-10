//
//  RemoteUser.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RemoteUser : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteKey;
@property (nonatomic, retain) NSString * name;

@end
