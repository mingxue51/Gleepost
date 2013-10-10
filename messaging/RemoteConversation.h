//
//  RemoteConversation.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RemoteConversation : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteKey;
@property (nonatomic, retain) NSManagedObject *messages;

@end
