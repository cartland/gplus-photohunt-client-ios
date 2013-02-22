//
//  AppDelegate.h
//  PhotoHunt

#import "GTLServiceFSH.h"
#import "HomeViewController.h"
#import "ImageCache.h"
#import "UserManager.h"
#import <UIKit/UIKit.h>

// Main entry point for the PhotoHunt application.
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;

// Service shared across many items, so that the cookie jar is maintained,
// removing the need to pass around the PhotoHunt session.
@property (nonatomic, retain) GTLServiceFSH *service;

@property (nonatomic, retain) ImageCache *imageCache;
@property (nonatomic, retain) UserManager *userManager;
@property (nonatomic, retain) HomeViewController *homeView;
@property (nonatomic, assign) NSInteger version;

@end
