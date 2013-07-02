//
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
