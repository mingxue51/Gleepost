//
//  GLPServerPathManager.m
//  Gleepost
//
//  Created by Σιλουανός on 21/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPServerPathManager.h"
#import "UICKeyChainStore.h"

@interface GLPServerPathManager ()

@property (strong, nonatomic) NSString *serverPath;
@property (strong, nonatomic) NSString *dataPlistServerPath;


@end

@implementation GLPServerPathManager

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _serverPath = GLP_BASE_SERVER_URL;
        
        [self loadServerPathData];
    }
    
    return self;
}

- (void)loadServerPathData
{
    NSString *path = [UICKeyChainStore stringForKey:@"serverpathkeychain" service:@"com.server.gleepost"];
    
    if(!path)
    {
        return;
    }
    
    _serverPath = path;
}

- (void)saveServerPathData
{
    UICKeyChainStore *store = [[UICKeyChainStore alloc] initWithService:@"com.server.gleepost"];
    [store setString:_serverPath forKey:@"serverpathkeychain"];
    [store synchronize];
}

- (void)switchServerMode
{
    if([_serverPath isEqualToString:GLP_BASE_SERVER_URL])
    {
        _serverPath = GLP_TEST_SERVER_URL;
    }
    else
    {
        _serverPath = GLP_BASE_SERVER_URL;
    }
    
    DDLogInfo(@"Server switched: %@", _serverPath);
    
    [self saveServerPathData];
}

- (NSString *)serverPath
{
    if(!DEV)
    {
        return GLP_BASE_SERVER_URL;
    }
    
    return _serverPath;
}

- (NSString *)serverMode
{
    if([_serverPath isEqualToString:GLP_BASE_SERVER_URL])
    {
        return @"Live Server";
    }
    else
    {
        return @"Dev Server";
    }
}

@end
