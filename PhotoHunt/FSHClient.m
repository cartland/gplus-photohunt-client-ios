//
//  FSHClient.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/20/13.
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
    
    // By default, the example ships with SSL pinning enabled for the app.net API pinned against the public key of adn.cer file included with the example. In order to make it easier for developers who are new to AFNetworking, SSL pinning is automatically disabled if the base URL has been changed. This will allow developers to hack around with the example, without getting tripped up by SSL pinning.
//    TODO(cartland@google.com): Understand what to do here.
//    if ([[url scheme] isEqualToString:@"https"] && [[url host] isEqualToString:@"alpha-api.app.net"]) {
//        [self setDefaultSSLPinningMode:AFSSLPinningModePublicKey];
//    }
//    
//    self.defaultSSLPinningMode = AFSSLPinningModeNone;
    
    return self;
}

@end