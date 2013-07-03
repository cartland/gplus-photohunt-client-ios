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
//  FSHPhoto.h
//  PhotoHunt

#import <Foundation/Foundation.h>

@interface FSHPhoto : NSObject {
    // Local cached UIImage to represent the photo.
    UIImage *_photo;
}
@property (assign) NSInteger identifier;
@property (assign) NSInteger photoId;
@property (assign) NSInteger ownerUserId;
@property (assign) NSInteger themeId;
@property (assign) NSInteger numVotes;
@property (assign) BOOL voted;
@property (assign) NSInteger created;

@property (copy) NSString *ownerDisplayName;
@property (copy) NSString *ownerGooglePlusId;
@property (copy) NSString *ownerProfileUrl;
@property (copy) NSString *ownerProfilePhoto;
@property (copy) NSString *themeDisplayName;
@property (copy) NSString *fullsizeUrl;
@property (copy) NSString *thumbnailUrl;
@property (copy) NSString *voteCtaUrl;
@property (copy) NSString *photoContentUrl;

- (FSHPhoto *)initWithAttributes:(NSDictionary *)attributes;
- (void)setPhoto:(UIImage *)in_photo;
- (UIImage *)photo;

@end
