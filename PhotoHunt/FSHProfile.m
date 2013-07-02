/*
 *
 * Copyright 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//  FSHProfile.m
//  PhotoHunt

#import "FSHProfile.h"

@implementation FSHProfile
@synthesize identifier = _identifier;
@synthesize googleDisplayName = _googleDisplayName;
@synthesize googlePublicProfilePhotoUrl = _googlePublicProfilePhotoUrl;
@synthesize googleUserId = _googleUserId;
@synthesize googlePlusProfileUrl = _googlePlusProfileUrl;

- (id)initWithJson:(NSDictionary *)attributes {
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
