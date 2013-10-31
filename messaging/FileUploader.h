//
//  FileUploader.h
//  Gleepost
//
//  Created by Σιλουανός on 30/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "MKNetworkEngine.h"

@interface FileUploader : MKNetworkEngine

-(MKNetworkOperation *)postDataToServer: (NSMutableDictionary*)params path:(NSString*)path;

@end
