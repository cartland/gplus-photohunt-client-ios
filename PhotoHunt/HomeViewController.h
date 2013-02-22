//
//  HomeViewController.h
//  PhotoHunt

#import "FSHPhotos.h"
#import "FSHProfile.h"
#import "FSHTheme.h"
#import "FSHThemes.h"
#import "GAITrackedViewController.h"
#import "GPPDeepLink.h"
#import "GPPShare.h"
#import "GPPSignIn.h"
#import "MenuSource.h"
#import <MessageUI/MessageUI.h>
#import "PhotoCardView.h"
#import "TakePhotoView.h"
#import "ThemeManager.h"
#import <UIKit/UIKit.h>
#import "UserManager.h"
#import "StreamSource.h"

// The main view controller mediates most of the interaction between the user
// and PhotoHunt - it displays the stream of photos, provides interaction
// for the user and maintains state.
@interface HomeViewController : GAITrackedViewController <
  GPPDeepLinkDelegate,
  GPPShareDelegate,
  MFMailComposeViewControllerDelegate,
  MenuSourceDelegate,
  PhotoCardViewDelegate,
  StreamSourceDelegate,
  TakePhotoViewDelegate,
  ThemeManagerDelegate,
  UIActionSheetDelegate,
  UIAlertViewDelegate,
  UIImagePickerControllerDelegate,
  UIImagePickerControllerDelegate,
  UINavigationControllerDelegate,
  UIPickerViewDataSource,
  UIPickerViewDelegate,
  UserManagerDelegate> {
}

// Controller state.
@property (nonatomic, retain) ThemeManager *themeManager;
@property (nonatomic, retain) FSHPhotos *curThemeImages;
@property (nonatomic, retain) FSHPhotos *curThemeImagesAllUsers;
@property (nonatomic, retain) FSHTheme *curTheme;
@property (nonatomic, retain) FSHProfile *curUser;
@property (nonatomic, assign) BOOL canTake;
@property (nonatomic, assign) NSInteger loadOps;

// UI components.
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UITableView *menu;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *updateMessage;

// Parameters from deeplinking
@property (nonatomic, copy) NSString *deepLinkPhotoID;
@property (nonatomic, copy) NSString *deepLinkVerb;

// Signal that the application has come to the foreground, allows signalling
// an update should occur.
- (void)comeToForeground;

@end
