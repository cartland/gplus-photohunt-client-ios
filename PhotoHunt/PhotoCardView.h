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
//  PhotoCardView.h
//  PhotoHunt

#import "FSHProfile.h"
#import "FSHPhoto.h"
#import "ImageCache.h"
#import <UIKit/UIKit.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

// Define a string to be used for the id of a placeholder photo displayed while
// the real photo is being uploaded.
GTL_EXTERN NSInteger const kPhotoPlaceholder;
// Profile URL template for the Google+ iOS app.
GTL_EXTERN NSString * const kProfileURL;

// A delegate for the PhotoCard view used to determine the state of the card
// and to bind selectors to for various user actions.
@protocol PhotoCardViewDelegate <NSObject>

// Retrieve the currently logged-in user.
- (FSHProfile *)currentUser;

// Flag to signal whether the currently viewed theme is the most recent.
- (BOOL)isLatestTheme;

// Callback for when the user taps the vote button. Sender will point to the
// UIButton which will be marked with a tag corresponding to the |row| passed
// in on creation.
- (void)didTapVote:(id)sender;

// Callback for when the user taps the delete button. Sender will point to the
// UIButton which will be marked with a tag corresponding to the |row| passed
// in on creation.
- (void)didTapDelete:(id)sender;

// Callback for when the user taps the promote button. Sender will point to the
// UIButton which will be marked with a tag corresponding to the |row| passed
// in on creation.
- (void)didTapPromote:(id)sender;

// Callback for when the user taps main photo. Sender will point to the
// UIButton which will be marked with a tag corresponding to the |row| passed
// in on creation.
- (void)didTapImage:(id)sender;

// Callback for when the user taps a user profile image. Sender will point to
// the UIButton which will be marked with a tag corresponding to the |row|
// passed in on creation.
- (void)didTapAuthor:(id)sender;

@end

// A view to represent a single PhotoHunt entry in a standard card format.
// Contains the user interface to allow interacting (voting etc.) with the
// photo for the end user.
@interface PhotoCardView : UIView

@property (nonatomic, weak) id<PhotoCardViewDelegate> delegate;
@property (nonatomic, strong) UIButton *vote;
@property (nonatomic, strong) ImageCache *cache;

// Update the vote button to appear disabled.
+ (void)disableVoteButton:(UIButton *)vote;

// Retrieve the standard height of the card.
+ (CGFloat)getHeight;

// Retrieve the standard width of the card.
+ (CGFloat)getWidth;

// Initialise the card with a given FSHPhoto, and tag the various buttons with
// the row provided (see PhotoCardViewDelegate).
- (id)initWithPhoto:(FSHPhoto *)photo
             forRow:(NSInteger)row
       withDelegate:(id<PhotoCardViewDelegate>)delegate
           useCache:(ImageCache *)cache;

// Update an existing card by setting the photo and row tag it is displaying.
- (void)setPhoto:(FSHPhoto *)photo forRow:(NSInteger)row;

// Utility method to clear the contents of a card.
- (void)clearSubviews;

@end
