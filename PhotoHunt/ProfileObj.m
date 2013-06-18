//
//  ProfileObj.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/17/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "ProfileObj.h"

@implementation ProfileObj
@synthesize identifier = _identifier;
@synthesize googleDisplayName = _googleDisplayName;
@synthesize googlePublicProfilePhotoUrl = _googlePublicProfilePhotoUrl;
@synthesize googleUserId = _googleUserId;
@synthesize googlePlusProfileUrl = _googlePlusProfileUrl;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _identifier = [[attributes valueForKeyPath:@"id"] integerValue];
    _googleDisplayName = [attributes valueForKeyPath:@"googleDisplayName"];
    _googlePublicProfilePhotoUrl = [attributes valueForKeyPath:@"googlePublicProfileUrl"];
    _googleUserId = [attributes valueForKeyPath:@"googleUserId"];
    _googlePlusProfileUrl = [attributes valueForKeyPath:@"googlePlusProfileUrl"];
    
    return self;
}

@end
