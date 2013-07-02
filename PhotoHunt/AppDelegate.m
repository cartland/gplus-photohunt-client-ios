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
//  AppDelegate.m
//  PhotoHunt

#import "AppDelegate.h"
#import "GAI.h"
#import "GAITracker.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "HomeViewController.h"

@implementation AppDelegate

static const NSInteger kPhotoHuntVersion = 21;


- (void)applicationWillEnterForeground:(UIApplication *)application {
  if (self.homeView) {
    [self.homeView comeToForeground];
  }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  // Version number for about screen.
  self.version = kPhotoHuntVersion;

  // Setup Google+ Sign In.
  GPPSignIn *signIn = [GPPSignIn sharedInstance];

  // Configure these variables to set up PhotoHunt.
  // This is the URL for the API and the web front end of PhotoHunt.
  // e.g. @"https://myapp.appspot.com/".
  self.photohuntWebUrl = @"http://YOUR_APP_HERE/";

  // Client ID from http://developers.google.com/console
  // e.g. @"123456789.apps.googleusercontent.com".
  signIn.clientID = @"XXXXXXXX.apps.googleusercontent.com";

  // Create the default Google Analytics tracker.
  [[GAI sharedInstance] trackerWithTrackingId:@"UA-XXXXXXXX-Y"];

  // Setup the scopes and actions we want the user to approve.
  signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, nil];
  signIn.actions = [NSArray arrayWithObjects:
                       @"http://schemas.google.com/AddActivity",
                       @"http://schemas.google.com/ReviewActivity",
                       nil];

  self.imageCache = [[ImageCache alloc] init];

  // Setup Google Analytics tracker config.
  [GAI sharedInstance].trackUncaughtExceptions = NO;
  [GAI sharedInstance].dispatchInterval = 60;
  // Set debug to YES for extra debugging information.
  [GAI sharedInstance].debug = NO;

  // Build the home view and display.
  HomeViewController *homeView = [[HomeViewController alloc] init];

  self.userManager = [[UserManager alloc] initWithDelegate:homeView];
  signIn.delegate = self.userManager;
  UINavigationController *homeNav = [[UINavigationController alloc]
                                      initWithRootViewController:homeView];
  self.window.rootViewController = homeNav;

  [GPPDeepLink setDelegate:homeView];
  [GPPDeepLink readDeepLinkAfterInstall];

  [self.window makeKeyAndVisible];
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  // Handle Google+ callbacks.
  return [GPPURLHandler handleURL:url
                sourceApplication:sourceApplication
                       annotation:annotation];
}

@end
