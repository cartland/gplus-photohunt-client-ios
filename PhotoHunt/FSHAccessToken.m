//
//  FSHAccessToken.m
//  PhotoHunt
//
//  Created by Chris Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "FSHAccessToken.h"

@implementation FSHAccessToken

@synthesize identifier = _identifier;
@synthesize access_token = _access_token;
@synthesize googleUserId = _googleUserId;
@synthesize googleDisplayName = _googleDisplayName;
@synthesize googlePublicProfileUrl = _googlePublicProfileUrl;
@synthesize googlePublicProfilePhotoUrl = _googlePublicProfilePhotoUrl;

- (id)initWithJson:(NSDictionary *)attributes {
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

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%d", _identifier] forKey:@"id"];
    [dict setObject:_access_token forKey:@"access_token"];
    return dict;
}

@end
