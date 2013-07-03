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
//  FSHPhotos.m
//  PhotoHunt

#import "FSHPhoto.h"
#import "FSHPhotos.h"

@implementation FSHPhotos

@synthesize items = _items;

// Init array with JSON returned from AFNetworking
- (FSHPhotos *)initWithArray:(NSArray *)array {
  self = [super init];
  if (!self) {
    return nil;
  }

  NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[array count]];
  for (NSDictionary *attributes in array) {
    FSHPhoto *item = [[FSHPhoto alloc] initWithAttributes:attributes];
    [mutableArray addObject:item];
  }
  _items = [NSArray arrayWithArray:mutableArray];
  
  return self;
}

@end
