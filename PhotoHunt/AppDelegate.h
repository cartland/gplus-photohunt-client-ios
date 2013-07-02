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
//  AppDelegate.h
//  PhotoHunt

#import "HomeViewController.h"
#import "ImageCache.h"
#import "UserManager.h"
#import <UIKit/UIKit.h>

// Main entry point for the PhotoHunt application.
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, copy) NSString *photohuntWebUrl;

@property (nonatomic, strong) ImageCache *imageCache;
@property (nonatomic, strong) UserManager *userManager;
@property (nonatomic, strong) HomeViewController *homeView;
@property (nonatomic, assign) NSInteger version;

@end
