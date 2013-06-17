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

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, copy) NSString *photohuntWebUrl;

// Service shared across many items, so that the cookie jar is maintained,
// removing the need to pass around the PhotoHunt session.
@property (nonatomic, strong) GTLServiceFSH *service;

@property (nonatomic, strong) ImageCache *imageCache;
@property (nonatomic, strong) UserManager *userManager;
@property (nonatomic, strong) HomeViewController *homeView;
@property (nonatomic, assign) NSInteger version;

@end
