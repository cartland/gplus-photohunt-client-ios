//
//  FSHClient.m
//  PhotoHunt
//
//  Created by Chris Cartland on 6/20/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "FSHClient.h"
#import "AppDelegate.h"
#import "AFJSONRequestOperation.h"

@implementation FSHClient

+ (FSHClient *)sharedClient {
    static FSHClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                               delegate];
    NSString *baseUrlString = appDelegate.photohuntWebUrl;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[FSHClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrlString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

@end