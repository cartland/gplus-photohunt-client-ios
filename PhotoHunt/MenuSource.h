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
//  MenuSource.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "FSHProfile.h"
#import "FSHTheme.h"

// A delegate to handle the callbacks from the menu actions.
@protocol MenuSourceDelegate <NSObject>

// Hide the menu.
- (void)hideMenu;

// Log the user out.
- (void)logout;

// Display the about page.
- (void)didTapAbout;

// Handle inviting other users.
- (void)didTapInvite;

// Refresh the stream.
- (void)didTapRefresh;

// Display the users profile or activities.
- (void)didTapProfile;

// Sign in, using the web.
- (void)didTapSignInWeb;

// Display the theme picker.
- (void)didTapChangeTheme;

// Display a place for the user to enter their feedback.
- (void)didTapSendFeedback;

// Disconnect the user from the PhotoHunt application.
- (void)didTapDisconnect;

// Return the current user.
- (FSHProfile *)currentUser;

// Return the current theme.
- (FSHTheme *)currentTheme;

@end

// Manage the table used as the sliding menu.
@interface MenuSource : NSObject <
    UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic, weak) id<MenuSourceDelegate> delegate;

// Initialise the object with the suppled delegate.
- (id)initWithDelegate:(id<MenuSourceDelegate>)delegate;

// Refresh the menu, to check for state changes.
- (void)reloadMenu;

@end
