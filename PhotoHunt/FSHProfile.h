//
//  FSHProfile.h
//  PhotoHunt
//
//  Created by Chris Cartland on 6/17/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSHProfile : NSObject

@property (assign) NSInteger identifier;
@property (copy) NSString *googleDisplayName;
@property (copy) NSString *googlePublicProfilePhotoUrl;
@property (copy) NSString *googleUserId;
@property (copy) NSString *googlePlusProfileUrl;

- (id)initWithJson:(NSDictionary *)attributes;

@end
