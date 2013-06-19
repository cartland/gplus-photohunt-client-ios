//
//  AccessTokenObj.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "AccessTokenObj.h"

@implementation AccessTokenObj

@synthesize identifier = _identifier;
@synthesize access_token = _access_token;
@synthesize googleUserId = _googleUserId;
@synthesize googleDisplayName = _googleDisplayName;
@synthesize googlePublicProfileUrl = _googlePublicProfileUrl;
@synthesize googlePublicProfilePhotoUrl = _googlePublicProfilePhotoUrl;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _identifier = [[attributes valueForKeyPath:@"id"] integerValue];
    _access_token = [attributes valueForKeyPath:@"access_token"];
    _googleUserId = [attributes valueForKeyPath:@"googleUserId"];
    _googleDisplayName = [attributes valueForKeyPath:@"googleDisplayName"];
    _googlePublicProfileUrl = [attributes valueForKeyPath:@"googlePublicProfileUrl"];
    _googlePublicProfilePhotoUrl = [attributes valueForKeyPath:@"googlePublicProfileUrl"];
    
    return self;
}

@end
