//
//  RemoteMessage.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RemoteMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * remoteKey;

@end
