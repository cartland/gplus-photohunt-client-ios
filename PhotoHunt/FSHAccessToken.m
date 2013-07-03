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
//  FSHAccessToken.m
//  PhotoHunt

#import "FSHAccessToken.h"

@implementation FSHAccessToken

@synthesize identifier = _identifier;
@synthesize access_token = _access_token;
@synthesize googleUserId = _googleUserId;
@synthesize googleDisplayName = _googleDisplayName;
@synthesize googlePublicProfileUrl = _googlePublicProfileUrl;
@synthesize googlePublicProfilePhotoUrl = _googlePublicProfilePhotoUrl;

- (FSHAccessToken *)initWithAttributes:(NSDictionary *)attributes {
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
