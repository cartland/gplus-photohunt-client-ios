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
//  TakePhotoView.m
//  PhotoHunt

#import <GooglePlus/GooglePlus.h>
#import "TakePhotoView.h"

@implementation TakePhotoView

static const CGFloat kHeight = 80.0;
static const CGFloat kWidth = 320.0;

+ (CGFloat)getHeight {
  return kHeight;
}

+ (CGFloat)getWidth {
  return kWidth;
}

- (id)init {
  return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<TakePhotoViewDelegate>)delegate {
  CGRect frame = CGRectMake(0.0, 0.0, kWidth, kHeight);
  self = [super initWithFrame:frame];
  if (self) {
    self.delegate = delegate;
    if (![self.delegate currentUser]) {
      GPPSignInButton *signInButton = [[GPPSignInButton alloc]
                                       init];
      [signInButton setStyle:kGPPSignInButtonStyleWide];
      [signInButton setColorScheme:kGPPSignInButtonColorSchemeLight];
      CGFloat x = roundf((320.0 - signInButton.frame.size.width) / 2.0);
      CGFloat y = roundf((80.0 - signInButton.frame.size.height) / 2.0);
      [signInButton setFrame:CGRectMake(x,
                                        y,
                                        signInButton.frame.size.width,
                                        signInButton.frame.size.height)];
      [self addSubview:signInButton];
      [self setBackgroundColor:[UIColor colorWithRed:0.2
                                               green:0.2
                                                blue:0.2
                                               alpha:1.0]];
    } else {
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100.0,
                                                                 20.0,
                                                                 190.0,
                                                                 40.0)];
      [label setText:@"Snap Today's Theme"];
      [label setFont:[UIFont fontWithName:@"Arial" size:17.0]];
      [label setBackgroundColor:[UIColor clearColor]];
      
      UIImage *image = [UIImage imageNamed:@"upload.png"];
      
      UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
      [button setFrame:frame];
      [button setImage:image forState:UIControlStateNormal];
      [button addTarget:self.delegate
                 action:@selector(didTapPhoto)
       forControlEvents:UIControlEventTouchUpInside];
      
      [self addSubview:button];
      [self addSubview:label];
    }
  }
  return self;
}

@end
