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
//  ThemeManager.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "FSHPhotos.h"
#import "FSHTheme.h"
#import "FSHThemes.h"

// Delegate to allow the theme manager to call back to its creator.
@protocol ThemeManagerDelegate <NSObject>

// Send an updated list of photos from non-friend users.
- (void)updateAllUserPhotos:(FSHPhotos *)photos;

// Send an updated list of photos from the current users' friends.
- (void)updateFriendsPhotos:(FSHPhotos *)photos;

// Signal that there is a new theme available.
- (void)newThemeAvailable;

// Signal that we have had connection difficulities. |major| signifies whether
// this is a serious connectivity (e.g. device offline) issue, or whether there
// was a problem with a call (such as a timeout or likely-to-resolve-itself
// error).
- (void)connectionOffline:(BOOL)major;

// Let the delegate know we are starting some network activity.
- (void)startedAction;

// Let the delegate know that network activity has completed.
-(void)completedAction;

// Request that the delegate retrieve an upated authentication token for the
// FSHService passed in at init.
-(void)refreshAuth;

@end

// Manage the list of themes and theme images returned from the PhotoHunt
// API.
@interface ThemeManager : NSObject

// Initialise the object with a delegate for callbacks.
// This class does not manage authorisation,
// but can signal in cases where the auth is insufficient.
- (id)initWithDelegate:(id<ThemeManagerDelegate>)delegate;

// Retrieve the latest theme available.
- (FSHTheme *)getLatestTheme;

// Retrieve updated list of themes and theme images. |background| indicates
// whether the request is user initiated (NO) or system initiated (YES).
- (void)updateThemeDataTriggeredAutomatically:(BOOL)background;

// Set the id of the theme currently being used for image retrieval.
- (BOOL)setThemeId:(NSInteger)themeId;

// Set the user ID of the currently logged in user. This is used for determining
// whether to make friend images calls.
- (BOOL)setUserId:(NSInteger)userId;

// Signal that the authentication method has been updated.
- (void)authRefreshed;

// Retrieve the current ordering of the last returned themed.
- (NSString *)getCurrentOrder;

// Swap between ordering by votes and recent (best & latest in API terms).
- (NSString *)flipOrder;

@property (nonatomic, strong) FSHThemes *themes;
@property (nonatomic, strong) FSHPhotos *allPhotos;
@property (nonatomic, strong) FSHPhotos *friendPhotos;

@property (nonatomic, assign) NSInteger currentThemeId;
@property (nonatomic, assign) NSInteger currentUserId;

@end
