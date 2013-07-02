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
//  TakePhotoView.h
//  PhotoHunt

#import "FSHProfile.h"
#import <UIKit/UIKit.h>

// Delegate for the take photo view, used to trigger the photo taking routine
// and check the state of the user.
@protocol TakePhotoViewDelegate <NSObject>

// Retrieve the currently signed in user, or nil if not logged in.
- (FSHProfile *)currentUser;

// Callback called to trigger photo selection routine.
- (void)didTapPhoto;

@end

// A view to display the take photo or sign in graphic, and to handle responses
// automatically.
@interface TakePhotoView : UIView

// Get the height of the view.
+ (CGFloat) getHeight;

// Get the width of the view.
+ (CGFloat) getWidth;

@property (nonatomic, weak) id<TakePhotoViewDelegate> delegate;

// Initise the object with the given delegate.
- (id)initWithDelegate:(id<TakePhotoViewDelegate>)delegate;

@end
