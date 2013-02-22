//
//  HomeViewController.m
//  PhotoHunt

#import "AboutViewController.h"
#import "AppDelegate.h"
#import "FSHFriends.h"
#import "FSHPhoto.h"
#import "FSHSession.h"
#import "FSHTheme.h"
#import "FSHUploadUrl.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GPPShare.h"
#import "GTMLogger.h"
#import "GTMNSDictionary+URLArguments.h"
#import "GTLServiceFSH.h"
#import "GTLQueryFSH.h"
#import "HomeViewController.h"
#import "ImageViewController.h"
#import "MenuSource.h"
#import "ProfileViewController.h"

static const NSInteger kMaxThemes = 20;
static const NSInteger kNewThemeTag = 454;
static const CGFloat kNotifyOffset = -50.0;

@interface HomeViewController () {
  BOOL authenticating;
  FSHPhoto *currentPhoto;
  BOOL isSeamlesslySigningIn;
  NSTimeInterval lastOfflineMessage;
  MenuSource *menuSource;
  NSTimer *reloadTimer;
  GTLServiceFSH *service;
  StreamSource *streamSource;
  BOOL timerPaused;
  UIImage *useImage;
  UserManager *userManager;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"PhotoHunt", @"PhotoHunt");
  }
  return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];

  // Debug code - enables logging on all calls.
  //[GTMHTTPFetcher setLoggingEnabled:YES];

  // Set default Google Analytics view.
  self.trackedViewName = @"viewTheme loading";

  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                             delegate];
  service = appDelegate.service;
  appDelegate.homeView = self;

  userManager = appDelegate.userManager;

  streamSource = [[[StreamSource alloc]
                     initWithDelegate:self
                             useCache:appDelegate.imageCache]
                     autorelease];
  [streamSource retain];
  [self.table setDataSource:streamSource];
  [self.table setDelegate:streamSource];
  menuSource = [[[MenuSource alloc] initWithDelegate:self] autorelease];
  [menuSource retain];
  [self.menu setDataSource:menuSource];
  [self.menu setDelegate:menuSource];

  // Set the black style bar.
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

  // Add a button to the toolbar to trigger the main actions.
  UIBarButtonItem *photoButton = [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                           target:self
                           action:@selector(didTapPhoto)] autorelease];
  [photoButton setEnabled:NO];

  UIBarButtonItem *orderButton = [[[UIBarButtonItem alloc]
      initWithImage:[UIImage imageNamed:@"toggle"]
              style:UIBarButtonItemStylePlain
             target:self
             action:@selector(didTapOrder)] autorelease];

  UIBarButtonItem *menuButton = [[[UIBarButtonItem alloc]
      initWithImage:[UIImage imageNamed:@"hamburger"]
              style:UIBarButtonItemStylePlain
             target:self
             action:@selector(didTapMenu)] autorelease];

  self.navigationItem.leftBarButtonItem = menuButton;
  self.navigationItem.rightBarButtonItems =
      [NSArray arrayWithObjects:orderButton, photoButton, nil];

  [self hideNotification];
  isSeamlesslySigningIn = NO;

  // Kick off theme loading.
  [self.spinner startAnimating];
  self.themeManager = [[[ThemeManager alloc] initWithDelegate:self
                                                   andService:service]
                          autorelease];

  // See whether we can sign in, and kick offf the process if so. If we can
  // then we should wait until we get the response from the sign in attempt
  // to avoid a flash on un-signed-in screen. If we can't sign in, we call
  // an update to display for logged-out users.
  if ([userManager canSignIn]) {
    isSeamlesslySigningIn = YES;
  } else {
    [self.themeManager setUserId:nil];
    [self.themeManager updateThemeDataTriggeredAutomatically:NO];
  }

  if (!reloadTimer) {
    reloadTimer = [[NSTimer
                    scheduledTimerWithTimeInterval:60.0
                                            target:self
                                          selector:@selector(timedReload)
                                          userInfo:nil
                                           repeats:YES]
                   retain];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  timerPaused = YES;
  [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  timerPaused = NO;
  [super viewDidAppear:animated];
}

- (void)dealloc {
  [_themeManager release];
  [_curThemeImages release];
  [_curThemeImagesAllUsers release];
  [_curTheme release];
  [_curUser release];
  [_table release];
  [_menu release];
  [_spinner release];
  [_updateMessage release];
  [_deepLinkPhotoID release];
  [_deepLinkVerb release];
  [reloadTimer release];
  [menuSource release];
  [streamSource release];
  [service release];
  [super dealloc];
}

- (void)comeToForeground {
  [reloadTimer fire];
}

- (void)timedReload {
  if (!timerPaused) {
    [self.themeManager updateThemeDataTriggeredAutomatically:YES];
  }
}

#pragma mark - Connection status

- (void)connectionOffline:(BOOL)major; {
  NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
  // Only show every 5 minutes
  if ((timeStamp - lastOfflineMessage) > 300 && major) {
      lastOfflineMessage = timeStamp;
      UIAlertView *alert =
        [[[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"Connection Problems", nil)
                  message:NSLocalizedString(@"Sorry, we can't seem to connect"
                                            @" right now, tap refresh to try"
                                            @" again later!", nil)
                 delegate:self
      cancelButtonTitle:NSLocalizedString(@"OK",nil)
      otherButtonTitles:nil]
         autorelease];
      [alert show];
  } else if ((timeStamp - lastOfflineMessage) > 150) {
    if (lastOfflineMessage == 0) {
      lastOfflineMessage = timeStamp;
    }
    [self showNotification:@"Sorry, we're having trouble connecting"];
  }
  [self.spinner stopAnimating];
}

- (void)startedAction {
  [self.spinner startAnimating];
}

- (void)completedAction {
  // Skip if we're signing the user in.
  if (isSeamlesslySigningIn) {
    return;
  }
  [self.spinner stopAnimating];
  if (!self.curThemeImages && !self.curThemeImagesAllUsers) {
    [reloadTimer fire];
  }
  timerPaused = NO;
}

#pragma mark - Theme management

- (FSHPhotos *)friendPhotos {
  return self.curThemeImages;
}

- (FSHPhotos *)allUserPhotos {
  return self.curThemeImagesAllUsers;
}

- (NSInteger)counter {
  return self.loadOps;
}

// Every so often when we poll for new images, we also check for updated themes
// and if a new one is available (based on the last retrieved list in the
// theme manager, we will get a callback.
- (void)newThemeAvailable {
  // If we don't have a current theme, get the latest.
  if (!self.curTheme) {
    [self selectTheme:[self.themeManager getLatestTheme]];
    // Reload so we get the theme chooser.
    [menuSource reloadMenu];
    [self.menu reloadData];
  } else {
    // If we have a current theme, signal the user.
    NSString *message = [NSString stringWithFormat:
        NSLocalizedString(@"Theme %@ has been added, would"
                          @" you like to change to it?", nil),
        [self.themeManager getLatestTheme].title];
    UIAlertView *alert = [[[UIAlertView alloc]
           initWithTitle:NSLocalizedString(@"New Theme",nil)
                 message:message
                delegate:self
        cancelButtonTitle:NSLocalizedString(@"No Thanks",nil)
        otherButtonTitles:NSLocalizedString(@"OK", nil), nil] autorelease];
    [alert setTag:kNewThemeTag];
    [alert show];
  }
}

- (void)updateAllUserPhotos:(FSHPhotos *)photos {
  FSHPhoto *photo = [photos.items count] == 0 ?
                        nil : [photos.items objectAtIndex:0];
  if (photo &&
      ![photo.theme.identifier isEqualToString:self.curTheme.identifier]) {
    // We have out of date theme data, ping the updater.
    [self.themeManager updateThemeDataTriggeredAutomatically:NO];
    return;
  }
  NSInteger newPhotos = !self.curThemeImagesAllUsers ? 0 :
      [photos.items count] - [self.curThemeImagesAllUsers.items count];

  self.curThemeImagesAllUsers = photos;
  [self refreshStream];
  if (newPhotos > 0) {
    [self showNotification:[NSString stringWithFormat:@"%d new photos added",
                                newPhotos]];
  }
}

- (void)updateFriendsPhotos:(FSHPhotos *)photos {
  FSHPhoto *photo = [photos.items count] == 0 ?
                        nil : [photos.items objectAtIndex:0];
  if (photo &&
      ![photo.theme.identifier isEqualToString:self.curTheme.identifier]) {
    // We have out of date theme data, ping the updater.
    [self.themeManager updateThemeDataTriggeredAutomatically:NO];
    return;
  }
  NSInteger newPhotos = !self.curThemeImages ? 0 :
      [photos.items count] - [self.curThemeImages.items count];
  self.curThemeImages = photos;
  [self refreshStream];
  if (newPhotos > 0) {
    NSString *msg;
    if (newPhotos == 1) {
      FSHPhoto *p = [photos.items objectAtIndex:0];
      msg = [NSString stringWithFormat:@"%@ added a photo",
                 p.author.displayName];
    } else {
      msg = [NSString stringWithFormat:@"%d new friend photos added",
                 newPhotos];
    }
    [self showNotification:msg];
  }
}

- (FSHTheme *)currentTheme {
  return self.curTheme;
}

- (BOOL)isLatestTheme {
    return self.canTake;
}

- (BOOL)selectTheme:(FSHTheme *)theme {
  self.curTheme = theme;

  if ([self.themeManager setThemeId:self.curTheme.identifier]) {
    self.title = self.curTheme.title;

    [self checkTopNavCamButtonState];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:[NSString stringWithFormat:@"viewTheme %@",
        self.curTheme.identifier]];

    self.curThemeImagesAllUsers = nil;
    self.curThemeImages = nil;
    [self refreshStream];

    return YES;
  } else {
      return NO;
  }
}

- (void)checkTopNavCamButtonState {
  UIBarButtonItem * camButton = (UIBarButtonItem *)
      [self.navigationItem.rightBarButtonItems objectAtIndex:1];
  // Disable the photo button if not the current theme.
  self.canTake = [self.curTheme.identifier
      isEqualToString:[self.themeManager getLatestTheme].identifier];
  [camButton setEnabled:(self.canTake && self.curUser)];
}

- (BOOL)canTakePhoto {
  return self.canTake;
}

- (id<PhotoCardViewDelegate,TakePhotoViewDelegate>)cardDelegate {
  return self;
}

#pragma mark - Sign in/out

- (FSHProfile *)currentUser {
  return self.curUser;
}

- (void)didTapSignInWeb {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                             delegate];
  [appDelegate.userManager signInAndRetrieveUser:NO];
}

- (void)refreshAuth {
  [userManager refreshToken];
}

- (void)loadedUser:(FSHProfile *)user fromId:(NSString *)userId {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                             delegate];
  if ([userId isEqualToString:[appDelegate.userManager selfIdentifier]]) {
    isSeamlesslySigningIn = NO;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:@"&uid" value:user.identifier];
    self.curUser = user;
    self.curThemeImages = nil;
    self.curThemeImagesAllUsers = nil;
    [self.themeManager setUserId:self.curUser.identifier];
    [self checkTopNavCamButtonState];
    [menuSource reloadMenu];
    [self.menu reloadData];
  }
}

- (void)tokenRefreshed {
  if (useImage) {
    [self uploadPhoto];
  }
}

- (void)userLoginFailed {
  [self showNotification:@"Sorry, we couldn't log you in."];
  isSeamlesslySigningIn = NO;
  [self refreshStream];
}

- (void)logout {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                             delegate];
  self.curUser = nil;
  self.curThemeImages = nil;
  self.curThemeImagesAllUsers = nil;
  [self.themeManager setUserId:nil];
  [appDelegate.userManager signOut];
  [menuSource reloadMenu];
  [self.menu reloadData];
  [self refreshStream];
  [self showNotification:NSLocalizedString(@"Signed Out", nil)];
}

#pragma mark - Data loading

- (void)loadDeeplinkedPhoto {
  if (self.deepLinkPhotoID) {
    GTLQueryFSH *photoQuery = [GTLQueryFSH
      queryForImageWithImageId:self.deepLinkPhotoID];
    [service executeRestQuery:photoQuery
            completionHandler:^(GTLServiceTicket *iticket,
                                FSHPhoto *photo,
                                NSError *ierror) {
        if (ierror) {
          GTMLoggerDebug(@"DL Photo Error: %@", ierror);
          // Load the regular view.
          self.deepLinkPhotoID = nil;
        } else {
          for (int i = 0; i < [self.themeManager.themes.items count]; i++) {
            FSHTheme *tTheme = [self.themeManager.themes.items objectAtIndex:i];
            if ([tTheme.identifier isEqualToString:photo.theme.identifier]) {
              if (![self selectTheme:tTheme]) {
                // If we're already on the theme...
                [self refreshStream];
              }
              break;
            }
          }
        }
    }];
  }
}

- (NSIndexPath *)getIndexPathForPhotoIdentifier:(NSString*)identifier {
  NSInteger row = 0;
  NSInteger section = 0;
  BOOL found = NO;
  for (FSHPhoto *p in self.curThemeImages) {
    if ([p.identifier isEqualToString:identifier]) {
      found = YES;
      break;
    }
    row++;
  }

  if (!found) {
    row = 0;
    for (FSHPhoto *p in self.curThemeImagesAllUsers) {
      if ([p.identifier isEqualToString:identifier]) {
        found = YES;
        section = 1;
        break;
      }
      row++;
    }
  }

  if (self.canTake) {
    section++;
  }

  if (found) {
    return [NSIndexPath indexPathForRow:row inSection:section];
  } else {
    return nil;
  }
}

- (FSHPhoto *)imageFromButton:(UIButton *)button {
  NSInteger row = [button tag];

  if (row >= [self.curThemeImages.items count]) {
    row -= [self.curThemeImages.items count];
    return [self.curThemeImagesAllUsers.items objectAtIndex:row];
  }

  return [self.curThemeImages.items objectAtIndex:row];
}


- (void)refreshStream {
  // Do nothing if we're still waiting for login.
  if (isSeamlesslySigningIn) {
    return;
  }

  self.loadOps++;
  [self.table reloadData];

  if (self.deepLinkPhotoID) {
    NSIndexPath *index =
      [self getIndexPathForPhotoIdentifier:self.deepLinkPhotoID];

    if (index) {
      FSHPhoto *photo;

      // Scroll the view to the position of the deep linked photo
      if (([index section] == 1 && self.canTake) || [index section] == 0) {
        photo = [self.curThemeImages.items objectAtIndex:[index row]];
      } else {
        photo = [self.curThemeImagesAllUsers.items objectAtIndex:[index row]];
      }
      [self.table scrollToRowAtIndexPath:index
                        atScrollPosition:UITableViewScrollPositionBottom
                                animated:YES];

      // If we're doing a deep link with a vote action, we need to actually
      // vote. Here we are just directly setting the vote, assuming the user is
      // in a state to do so, because voting is a fairly lightweight action. If
      // we were performing a more heavyweight action that could reveal user
      // information or cause the user some disadvantage, we should certainly
      // check with the user before performing the action. For example a "buy"
      // action may add to cart, but not check out. A "add to calendar" action
      // might display a confirmation prompt, and so on.
      if ([self.deepLinkVerb isEqualToString:@"VOTE"]) {
        BOOL isCurrentTheme = [[self.themeManager getLatestTheme].identifier
                               isEqualToString:self.curTheme.identifier];
        BOOL isCurrentUser = [photo.author.identifier
                              isEqualToString:self.curUser.identifier];

        // Only vote if we've not voted, it is not our photo and the theme
        // is still open.
        if (!(photo.voted) && isCurrentTheme && !isCurrentUser) {
          UIView *cell = [[self.table cellForRowAtIndexPath:index] contentView];
          UIButton *vote = (UIButton *)[[[cell subviews] objectAtIndex:0] vote];
          [vote sendActionsForControlEvents:UIControlEventAllTouchEvents];
          [self showNotification:NSLocalizedString(@"Voted!", nil)];
        }
      } else if ([self.deepLinkVerb isEqualToString:@"PROMOTE"]) {
        // We're using the same mechanism as with voting to handle sending an
        // interactive post if the user was not logged in. Once signed in,
        // we trigger the interactive post dialogue.
        [self shareInteractivePostForPhoto:photo];
      }
      self.deepLinkPhotoID = nil;
    }
  }
}

#pragma mark - Actions

- (void)didTapInvite {
  GPPShare *share = [GPPShare sharedInstance];
  share.delegate = self;
  NSURL *shareUrl = [NSURL
      URLWithString:@"http://fb12e8b8d117.appspot.com/invite.html"];
  NSString *deepLink = @"/";
  id<GPPShareBuilder> builder = [share shareDialog];

  [builder setCallToActionButtonWithLabel:@"JOIN"
                                      URL:shareUrl
                               deepLinkID:@"/"];

  // Construct the prefilled text. The user has the ability to change this in
  // the share dialogue, but we default to the version below. The two replaces
  // are used to generated the hashtag version of the theme name - we remove
  // spaces and commas (but leave other punctuation).
  NSString *prefillText = [NSString stringWithFormat:
                           @"Join the hunt, upload and vote for photos of #%@"
                           @" on PhotoHunt. #photohunt",
                           [[[self.curTheme.title lowercaseString]
                    stringByReplacingOccurrencesOfString:@" " withString:@""]
                    stringByReplacingOccurrencesOfString:@"," withString:@""]];
  [builder setContentDeepLinkID:deepLink];
  [builder setPrefillText:prefillText];
  [builder setURLToShare:shareUrl];
  [builder open];  // Open the share dialog.
}

- (void)didTapOrder {
  [self.themeManager flipOrder];
  [self showNotification:[NSString stringWithFormat:@"Ordered %@ first",
                          [self.themeManager getCurrentOrder]]];
}

- (void)didTapAbout {
  AboutViewController *about = [[[AboutViewController alloc]
                                 initWithNibName:@"AboutViewController"
                                          bundle:nil]
                                autorelease];
  [self.navigationController pushViewController:about animated:YES];
}

- (void)didTapAuthor:(id)sender {
  UIButton *button = (UIButton *)sender;
  FSHPhoto *selected = [self imageFromButton:button];
  NSString *profile = [NSString stringWithFormat:kProfileURL,
                       selected.author.googlePlusId];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:profile]];
}


- (void)didTapProfile {
  ProfileViewController *profile = [[[ProfileViewController alloc]
                                     initWithNibName:@"ProfileViewController"
                                              bundle:nil
                                                user:self.curUser]
                                    autorelease];

  [self.navigationController pushViewController:profile animated:YES];
}

- (void)didTapRefresh {
  timerPaused = YES;
  [self.spinner startAnimating];
  [self.themeManager updateThemeDataTriggeredAutomatically:NO];
}

- (void)didTapImage:(id)sender {
  UIButton *image = (UIButton*)sender;

  FSHPhoto *selected = [self imageFromButton:image];

  if (selected && selected.image.url) {
    ImageViewController *imview = [[[ImageViewController alloc]
                                   initWithNibName:@"ImageViewController"
                                            bundle:nil
                                               url:selected.image.url]
                                  autorelease];
    [self.navigationController pushViewController:imview animated:YES];
  }
}

- (void)didTapDelete:(id)sender {
  UIButton *delete = (UIButton*)sender;

  currentPhoto = [self imageFromButton:delete];

  NSString *delTitle = NSLocalizedString(@"Really Delete?",nil);
  NSString *delMessage = NSLocalizedString(@"Are you sure you want to "
                                           @"delete your photo?",
                                           nil);
  NSString *cancel = NSLocalizedString(@"Cancel",nil);
  NSString *delBut = NSLocalizedString(@"Delete",nil);

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:delTitle
                                                  message:delMessage
                                                 delegate:self
                                        cancelButtonTitle:cancel
                                        otherButtonTitles:delBut, nil];
  [alert show];
  [alert release];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([alertView tag] == kNewThemeTag) {
    if (buttonIndex == 1) {
      [self selectTheme:[self.themeManager getLatestTheme]];
    }
  } else {
    if (buttonIndex == 1 && currentPhoto) {
      // Perform the delete query.
      GTLQueryFSH *deleteQuery;
      deleteQuery = [GTLQueryFSH
                     queryToDeleteImageWithImageId:currentPhoto.identifier];
      NSString *deletedPhoto = currentPhoto.identifier;
      timerPaused = YES;

      // Fire and forget.
     [service executeRestQuery:deleteQuery
             completionHandler:^(GTLServiceTicket *iticket,
                                 id object,
                                 NSError *error) {
          timerPaused = NO;
          if (error) {
            GTMLoggerDebug(@"Error Deleting Photo: %@", error);
            [userManager refreshToken];
          } else {
             GTMLoggerDebug(@"Deleted Photo");
          }

          id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
          [tracker sendView:[NSString stringWithFormat:@"photoDeleted %@",
                             deletedPhoto]];
      }];

      // Remove the item from the table.
      NSMutableArray *items = [NSMutableArray array];
      NSIndexPath *path =
          [self getIndexPathForPhotoIdentifier:currentPhoto.identifier];

      // This is just being paranoid in case the backend decides to serve
      // our own images not under friends.
      int section = [path section];
      BOOL friends = (self.canTake && section == 1) || section == 0;
      if (friends) {
        [items addObjectsFromArray:self.curThemeImages.items];
      } else {
        [items addObjectsFromArray:self.curThemeImagesAllUsers.items];
      }

      [items removeObjectAtIndex:[path row]];

      if (friends) {
        self.curThemeImages.items = items;
      } else {
        self.curThemeImagesAllUsers.items = items;
      }

      [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:path]
                        withRowAnimation:UITableViewRowAnimationRight];
    }

    // Always clear the photo state var.
    currentPhoto = nil;
  }
}

// Trigger a server call to vote on a photo. Note that this will write an app
// activity on the server side for the vote.
- (void)didTapVote:(id)sender {
  FSHPhoto *photo;
  GTLQueryFSH *voteQuery;

  UIButton *vote = (UIButton*)sender;
  NSInteger row = [vote tag];
  BOOL allImage = NO;

  if (row >= [self.curThemeImages.items count]) {
    row -= [self.curThemeImages.items count];
    allImage = YES;
    photo = [self.curThemeImagesAllUsers.items objectAtIndex:row];
  } else {
    photo = [self.curThemeImages.items objectAtIndex:row];
  }

  if (!self.curUser) {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                               delegate];
    self.deepLinkPhotoID = photo.identifier;
    self.deepLinkVerb = @"VOTE";
    [appDelegate.userManager signInAndRetrieveUser:YES];
    return;
  }

  if (photo.voted) {
    return;
  }

  [PhotoCardView disableVoteButton:vote];

  voteQuery = [GTLQueryFSH queryToAddVoteWithImageId:photo.identifier];

  [service executeRestQuery:voteQuery
          completionHandler:^(GTLServiceTicket *iticket,
                              FSHPhoto *votePhoto,
                              NSError *error) {
      if (error) {
        GTMLoggerDebug(@"Vote Error: %@", error);
        [userManager refreshToken];
      } else {
        NSMutableArray *items = [NSMutableArray arrayWithArray:
                                 (allImage ? self.curThemeImagesAllUsers.items
                                           : self.curThemeImages.items)];
        items[row] = [votePhoto retain];
        if (allImage) {
            self.curThemeImagesAllUsers.items = items;
        } else {
            self.curThemeImages.items = items;
        }

        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker sendView:[NSString stringWithFormat:@"photoVoted %@",
                           photo.identifier]];

        NSIndexPath *index =
            [self getIndexPathForPhotoIdentifier:votePhoto.identifier];
        [self.table reloadRowsAtIndexPaths:[NSArray arrayWithObject:index]
                          withRowAnimation:UITableViewRowAnimationFade];

       GTMLoggerDebug(@"%@", @"Vote cast");
     }
  }];
}

- (void)didTapPromote:(id)sender {
  FSHPhoto *photo;
  UIButton *promote = (UIButton*)sender;
  NSInteger row = [promote tag];

  if (row >= [self.curThemeImages.items count]) {
    row -= [self.curThemeImages.items count];
    photo = [self.curThemeImagesAllUsers.items objectAtIndex:row];
  } else {
    photo = [self.curThemeImages.items objectAtIndex:row];
  }

  if (!self.curUser) {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                               delegate];
    self.deepLinkPhotoID = photo.identifier;
    self.deepLinkVerb = @"PROMOTE";
    [appDelegate.userManager signInAndRetrieveUser:YES];
    return;
  }

  [self shareInteractivePostForPhoto:photo];
}

- (void)shareInteractivePostForPhoto:(FSHPhoto *)photo {
  GPPShare *share = [GPPShare sharedInstance];
  share.delegate = self;
  NSURL *shareUrl = [NSURL URLWithString:photo.url];
  NSString *deepLink = [NSString stringWithFormat:@"%@?%@",
                           [shareUrl path],
                           [shareUrl query]];
  id<GPPShareBuilder> builder = [share shareDialog];

  // We're sharing an interactive post which has a content deep link and a
  // call-to-action deep link - this is the URL used when the user taps the
  // call-to-action button on the rendered post on Google+. The deepLinkID will
  // be waht is passed to the iOS or Android apps if the user taps on the button
  // from the respective mobile apps.
  NSURL *ctaUrl = [NSURL URLWithString:
                        [NSString stringWithFormat:@"%@&action=VOTE",
                          [shareUrl absoluteString]]];
  NSString *dlID = [NSString stringWithFormat:@"%@&action=VOTE", deepLink];
  [builder setCallToActionButtonWithLabel:@"VOTE"
                                      URL:ctaUrl
                               deepLinkID:dlID];

  [builder setURLToShare:shareUrl];

  NSString *prefillText = [NSString stringWithFormat:
                   @"Check out this #%@ image on PhotoHunt. #photohunt",
                  [[[self.curTheme.title lowercaseString]
                   stringByReplacingOccurrencesOfString:@" " withString:@""]
                   stringByReplacingOccurrencesOfString:@"," withString:@""]];

  // Add the basic sharing methods for the content URL, content deep-link ID,
  // and prefilled text.
  [builder setContentDeepLinkID:deepLink];
  [builder setPrefillText:prefillText];
  [builder setURLToShare:shareUrl];
  [builder open];  // Open the share dialog.
}

- (void)didTapMenu {
  if (self.menu.frame.origin.x == 0) {
    [self hideMenu];
  } else {
    [self showMenu];
  }
}

#pragma mark - Picker for themes

- (void)didTapChangeTheme {
  UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                initWithTitle:nil
                                delegate:self
                                cancelButtonTitle:@"Close"
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil];

  [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

  CGRect pickerFrame = CGRectMake(0, 90, 320, 216);
  UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
  pickerView.showsSelectionIndicator = YES;
  pickerView.dataSource = self;
  pickerView.delegate = self;
  NSInteger curThemeRow = 0;
  NSInteger themeCount = [self.themeManager.themes.items count];
  for (curThemeRow = 0; curThemeRow < themeCount; curThemeRow++) {
      if ([[(self.themeManager.themes.items[curThemeRow]) identifier]
          isEqualToString:self.curTheme.identifier]) {
          break;
      }
  }
  [pickerView selectRow:curThemeRow inComponent:0 animated:YES];

  [actionSheet addSubview:pickerView];
  [pickerView release];

  [actionSheet showInView:self.view];
  [actionSheet setBounds:CGRectMake(0,0, 320, 411)];
  [actionSheet release];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
    numberOfRowsInComponent:(NSInteger)component {
  if ([self.themeManager.themes.items count] > kMaxThemes) {
    return kMaxThemes;
  } else {
    return [self.themeManager.themes.items count];
  }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  return [[self.themeManager.themes.items objectAtIndex:row] title];
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  FSHTheme *selected = [self.themeManager.themes.items objectAtIndex:row];
  if (![self.curTheme.identifier isEqualToString:selected.identifier]) {
    [self.spinner startAnimating];
    [self selectTheme:selected];
  }
}

#pragma mark - Sharing/deeplink delegate

- (void)didReceiveDeepLink: (GPPDeepLink *)deepLink {
  NSURL *inDL = [NSURL URLWithString:[deepLink deepLinkID]];
  NSDictionary *params = [NSDictionary gtm_dictionaryWithHttpArgumentsString:
                             [inDL query]];

  self.deepLinkPhotoID = [params objectForKey:@"id"];
  self.deepLinkVerb = [params objectForKey:@"action"];

  [self loadDeeplinkedPhoto];
}

- (void)finishedSharing:(BOOL)shared {
  NSString *action = shared ? @"completed" : @"cancelled";
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker sendEventWithCategory:@"uiAction"
                      withAction:action
                       withLabel:@"post-shared"
                       withValue:nil];
}

#pragma mark - Mail feedback

- (void)didTapSendFeedback {
  NSString *subject = NSLocalizedString(@"PhotoHunt IOS Feedback", nil);
  NSString *address = @"photohunt-eng@google.com";
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailer =
    [[MFMailComposeViewController alloc] init];
    [mailer setMailComposeDelegate:self];
    [mailer setSubject:subject];
    NSArray *to = [NSArray arrayWithObject:address];
    [mailer setToRecipients:to];
    [self presentViewController:mailer
                       animated:YES
                     completion:nil];
  } else {
    NSURL *gmail = [NSURL URLWithString:[NSString
                       stringWithFormat:@"googlegmail:/co?to=%@&amp;subject=%@",
                           address, [subject
                               stringByAddingPercentEscapesUsingEncoding:
                                   NSUTF8StringEncoding]]];
    if([[UIApplication sharedApplication] canOpenURL:gmail]) {
      [[UIApplication sharedApplication] openURL:gmail];
    }
  }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
  NSString *action;
  switch (result) {
    case MFMailComposeResultCancelled:
      action = @"cancelled";
      break;
    case MFMailComposeResultSaved:
      action = @"saved";
      break;
    case MFMailComposeResultSent:
      action = @"sent";
      break;
    case MFMailComposeResultFailed:
      action = @"failed";
      break;
    default:
      action = @"not sent";
      break;
  }
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker sendEventWithCategory:@"uiAction"
                      withAction:action
                       withLabel:@"feedback"
                       withValue:nil];
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo upload


// One tapping either of the take photo buttons we are going to pop up a picker
// for the user to choose the gallery or camera. If they take or select a photo
// we create a placeholder and upload it to the server - the server will write
// an app activity when this happens.
- (void)didTapPhoto {
  // Pop up a sheet to grab a photo from either the gallery or camera.
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                   delegate:self
           cancelButtonTitle:@"Cancel"
      destructiveButtonTitle:nil
           otherButtonTitles:@"Take Picture", @"Choose From Gallery", nil];

  actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
  [actionSheet showFromBarButtonItem:[self.navigationItem.rightBarButtonItems
                                          objectAtIndex:1]
                            animated:YES];
  [actionSheet release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) my_picker {
    [my_picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *) my_picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *im = [info objectForKey:UIImagePickerControllerOriginalImage];
  // Did we get an image? User may have cancelled.
  if (!im) {
    return;
  }

  [my_picker dismissViewControllerAnimated:YES completion:nil];

  // Resize the image if required.
  CGSize size = [im size];
  // Arbitary upper limit for triggering resizing.
  if (size.width > 1200 || size.height > 1200) {
    size.width = size.width / 2;
    size.height = size.height / 2;
    UIGraphicsBeginImageContext(size);
    [im drawInRect:CGRectMake(0,0,size.width,size.height)];
    useImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  } else {
    useImage = im;
  }

  FSHPhoto *photo = [FSHPhoto object];
  // Placeholder identifier from PhotoCardView.
  photo.identifier = kPhotoPlaceholder;
  photo.photo = useImage;
  photo.author = self.curUser;
  NSMutableArray *item = [NSMutableArray arrayWithObject:photo];
  [item addObjectsFromArray:self.curThemeImages.items];
  if (!self.curThemeImages) {
    self.curThemeImages = [[[FSHPhotos alloc] init] autorelease];
  }
  self.curThemeImages.items = item;
  [self.table reloadData];
  NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
  [self.table scrollToRowAtIndexPath:index
                    atScrollPosition:UITableViewScrollPositionMiddle
                            animated:YES];
  [self uploadPhoto];
}

- (void)uploadPhoto {
    // Now we need to upload the image. First get an upload URL.
    GTLQueryFSH *uploadUrlQuery = [GTLQueryFSH queryForUploadUrl];
    timerPaused = YES;
    [service executeRestQuery:uploadUrlQuery
            completionHandler:^(GTLServiceTicket *iticket,
                                FSHUploadUrl *uploadUrl,
                                NSError *error) {
        if (error) {
          GTMLoggerDebug(@"Retrieve URL Error: %@", error);
          [userManager refreshToken];
        } else {
          // Then post the body to the image.
          GTLQueryFSH *uploadQuery = [GTLQueryFSH
              queryToUploadImagesWithThemeId:self.curTheme.identifier
                                   uploadUrl:uploadUrl.url
                                       image:useImage];

          [service executeUpload:uploadQuery
               completionHandler:^(NSData *retrievedData, NSError *ierror) {
                   if (ierror) {
                     GTMLoggerDebug(@"Upload Error: %@", ierror);
                   } else {
                     NSError *parseError = nil;
                     NSMutableDictionary *json = [GTLJSONParser
                                                    objectWithData:retrievedData
                                                             error:&parseError];
                     FSHPhoto *photo = [FSHPhoto objectWithJSON:json];

                     NSMutableArray *item = [NSMutableArray array];
                     [item addObjectsFromArray:self.curThemeImages.items];
                     [item setObject:photo atIndexedSubscript:0];
                     self.curThemeImages.items = item;
                     [self.table reloadData];

                     id<GAITracker> tracker = [[GAI sharedInstance]
                                                  defaultTracker];
                     [tracker sendView:[NSString
                                           stringWithFormat:@"photoUploaded %@",
                                           photo.identifier]];

                     useImage = nil;

                     [self showNotification:NSLocalizedString(@"Photo Posted!",
                                                                  nil)];
                   }
                 timerPaused = NO;
          }];
       }
  }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == [actionSheet cancelButtonIndex]) {
    return;
  }

  UIImagePickerController * picker = [[[UIImagePickerController alloc] init]
                                      autorelease];
  picker.delegate = self;

  if (buttonIndex == 0) {
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  } else if (buttonIndex == 1) {
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  }

  [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Notifications and menus

- (void)showNotification:(NSString *)note {
    self.updateMessage.text = note;
    [UIView animateWithDuration:2
                          delay:0.25
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.updateMessage setFrame:
                          CGRectMake(self.updateMessage.frame.origin.x,
                                     0,
                                     self.updateMessage.frame.size.width,
                                     self.updateMessage.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self hideNotification];
                     }];
}

- (void)hideNotification {
    [UIView animateWithDuration:2
                     animations:^{
                         [self.updateMessage setFrame:
                          CGRectMake(self.updateMessage.frame.origin.x,
                                     kNotifyOffset,
                                     self.updateMessage.frame.size.width,
                                     self.updateMessage.frame.size.height)];
                     }
     ];
}

-(void)showMenu {
    [UIView animateWithDuration:.25
                     animations:^{
                         [self.menu setFrame:
                            CGRectMake(0,
                                       self.menu.frame.origin.y,
                                       self.menu.frame.size.width,
                                       self.menu.frame.size.height)];
                     }
     ];

}
- (void)hideMenu {
    [UIView animateWithDuration:.25
                     animations:^{
                         [self.menu setFrame:
                            CGRectMake(-200,
                                       self.menu.frame.origin.y,
                                       self.menu.frame.size.width,
                                       self.menu.frame.size.height)];
                     }
     ];
}

@end
