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
//  StreamSource.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "FSHPhotos.h"
#import "ImageCache.h"
#import "PhotoCardView.h"
#import "TakePhotoView.h"
#import "FSHTheme.h"

// Protocol for calling back to the owner for the theme data and status.
@protocol StreamSourceDelegate <NSObject>

// Return YES if the app is in a state that the user can take a photo.
- (BOOL)canTakePhoto;

// Return the photos list for all users.
- (FSHPhotos *)allUserPhotos;

// Return the photos list for photos by friends of the user.
- (FSHPhotos *)friendPhotos;

// Return the current user.
- (FSHProfile *)currentUser;

// Return the current theme.
- (FSHTheme *)currentTheme;

// Return a monotonically increasing counter which is used for cache clearing.
- (NSInteger)counter;

// Return a delegate suitable for use by the photocards.
- (id<PhotoCardViewDelegate,TakePhotoViewDelegate>)cardDelegate;

@end

// Manage the table view that displays the stream.
@interface StreamSource : NSObject <
    UITableViewDataSource,
    UITableViewDelegate> {
}

@property (nonatomic, weak) id<StreamSourceDelegate> delegate;
@property (nonatomic, strong) ImageCache *cache;

// Initialise a new stream manager with the delegate for callbacks and
// an |ImageCache| for use with the individual photocards.
- (id)initWithDelegate:(id<StreamSourceDelegate>)delegate
              useCache:(ImageCache *)cache;

@end
