//
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

- (void)dealloc {
  [_window release];
  [_photohuntWebUrl release];
  [_service release];
  [_imageCache release];
  [_userManager release];
  [_homeView release];
  [super dealloc];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  if (self.homeView) {
    [self.homeView comeToForeground];
  }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]
                    autorelease];

  // Version number for about screen.
  self.version = kPhotoHuntVersion;

  // Setup Google+ Sign In.
  GPPSignIn *signIn = [GPPSignIn sharedInstance];

  // Configure these variables to set up PhotoHunt.
  // This is the URL for the API and the web front end of PhotoHunt.
  // e.g. @"https://myapp.appspot.com/".
  self.photohuntWebUrl = @"http://silvano-ph.appspot.com";//@"http://YOUR_APP_HERE/";

  // Client ID from http://developers.google.com/console
  // e.g. @"123456789.apps.googleusercontent.com".
  signIn.clientID = @"111964934152-i777e0jsvhjrgq420d3kgm0mi1h6qf0j.apps.googleusercontent.com";//@"XXXXXXXX.apps.googleusercontent.com";

  // Create the default Google Analytics tracker.
  [[GAI sharedInstance] trackerWithTrackingId:@"UA-XXXXXXXX-Y"];

  // Setup the scopes and actions we want the user to approve.
  signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, nil];
  signIn.actions = [NSArray arrayWithObjects:
                       @"http://schemas.google.com/AddActivity",
                       @"http://schemas.google.com/ReviewActivity",
                       nil];

  // Create a service object we can use from everywhere else
  // this means we share the fetch object, and hence get a cookiejar. nom!
  self.service = [[[GTLServiceFSH alloc] initWithURL:self.photohuntWebUrl]
                     autorelease];

  self.imageCache = [[[ImageCache alloc] initWithService:self.service]
                        autorelease];

  // Setup Google Analytics tracker config.
  [GAI sharedInstance].trackUncaughtExceptions = NO;
  [GAI sharedInstance].dispatchInterval = 60;
  // Set debug to YES for extra debugging information.
  [GAI sharedInstance].debug = NO;

  // Build the home view and display.
  HomeViewController *homeView = [[[HomeViewController alloc] init]
                                     autorelease];

  self.userManager = [[[UserManager alloc] initWithDelegate:homeView
                                                 andService:self.service]
                         autorelease];
  signIn.delegate = self.userManager;
  UINavigationController *homeNav = [[[UINavigationController alloc]
                                      initWithRootViewController:homeView]
                                     autorelease];
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
