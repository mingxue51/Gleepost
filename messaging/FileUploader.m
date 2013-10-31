//
//  FileUploader.m
//  Gleepost
//
//  Created by Σιλουανός on 30/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "FileUploader.h"

@implementation FileUploader

-(MKNetworkOperation *)postDataToServer: (NSMutableDictionary*)params path:(NSString*)path
{
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:NO];
    
    return op;
}

@end
