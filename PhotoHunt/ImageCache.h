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
//  ImageCache.h
//  PhotoHunt

#import <Foundation/Foundation.h>

// Provided a central place to manage the images that are retrieved in various
// parts of PhotoHunt - including the main photos, profile images, and the app
// activity images. Keeps a limited size of cache, and also provides the ability
// to generate URLs for resizing images on the server side.
@interface ImageCache : NSObject

// Update |imageView| with the image retrieved from |url|. If |spinner| is
// supplied set it to stop animating when done.
- (BOOL)setImageView:(UIImageView *)imageview
              forURL:(NSString *)url
         withSpinner:(UIActivityIndicatorView *)spinner;

// Return a |url| modified with server-side resize parameters for the provided
// |width| and |height|.
- (NSString *)getResizeUrl:(NSString *)url
                  forWidth:(NSInteger)width
                 andHeight:(NSInteger)height;

// We use |imageUrls| as a ring buffer to implement the LRU cache functionality.
@property (nonatomic, strong) NSMutableArray *imageUrls;
@property (nonatomic, strong) NSMutableSet *currentFetches;
@property (nonatomic, strong) NSMutableDictionary *images;
@property (nonatomic, assign) NSUInteger curImage;
@property (nonatomic, strong) NSObject *service;

@end
