//
//  AccessTokenObj.h
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessTokenObj : NSObject

@property (assign) NSInteger identifier;
// The OAuth 2.0 access token.
@property (copy) NSString* access_token;
@property (copy) NSString *googleUserId;
@property (copy) NSString *googleDisplayName;
@property (copy) NSString *googlePublicProfileUrl;
@property (copy) NSString *googlePublicProfilePhotoUrl;

@end
