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
//  FSHPhoto.m
//  PhotoHunt

#import "FSHPhoto.h"

@implementation FSHPhoto
@synthesize identifier = _identifier;
@synthesize photoId = _photoId;
@synthesize ownerUserId = _ownerUserId;
@synthesize themeId = _themeId;
@synthesize numVotes = _numVotes;
@synthesize voted = _voted;
@synthesize created = _created;

@synthesize ownerDisplayName = _ownerDisplayName;
@synthesize ownerGooglePlusId = _ownerGooglePlusId;
@synthesize ownerProfileUrl = _ownerProfileUrl;
@synthesize ownerProfilePhoto = _ownerProfilePhoto;
@synthesize themeDisplayName = _themeDisplayName;
@synthesize fullsizeUrl = _fullsizeUrl;
@synthesize thumbnailUrl = _thumbnailUrl;
@synthesize voteCtaUrl = _voteCtaUrl;
@synthesize photoContentUrl = _photoContentUrl;

- (FSHPhoto *)initWithAttributes:(NSDictionary *)attributes {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  _identifier = [[attributes valueForKeyPath:@"id"] integerValue];
  _photoId = [[attributes valueForKeyPath:@"id"] integerValue];
  _ownerUserId = [[attributes valueForKeyPath:@"ownerUserId"] integerValue];
  _themeId = [[attributes valueForKeyPath:@"themeId"] integerValue];
  _numVotes = [[attributes valueForKeyPath:@"numVotes"] integerValue];
  _voted = [[attributes valueForKeyPath:@"voted"] boolValue];
  _created = [[attributes valueForKeyPath:@"created"] integerValue];
  _ownerDisplayName = [attributes valueForKeyPath:@"ownerDisplayName"];
  _themeDisplayName = [attributes valueForKeyPath:@"themedisplayName"];
  _fullsizeUrl = [attributes valueForKeyPath:@"fullsizeUrl"];
  _thumbnailUrl = [attributes valueForKeyPath:@"thumbnailUrl"];
  _voteCtaUrl = [attributes valueForKeyPath:@"voteCtaUrl"];
  _photoContentUrl = [attributes valueForKeyPath:@"photoContentUrl"];
  
  return self;
}

- (void)setPhoto:(UIImage *)in_photo {
  self->_photo = in_photo;
}

- (UIImage *)photo {
  if (self->_photo) {
    return self->_photo;
  } else if (self.fullsizeUrl) {
    NSURL *url = [NSURL URLWithString:self.fullsizeUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self->_photo = [[UIImage alloc] initWithData:data];
    return self->_photo;
  }
  
  return nil;
}

@end
