//
//  MenuSource.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "FSHProfile.h"
#import "ThemeObj.h"

// A delegate to handle the callbacks from the menu actions.
@protocol MenuSourceDelegate <NSObject>

// Hide the menu.
- (void)hideMenu;

// Log the user out.
- (void)logout;

// Display the about page.
- (void)didTapAbout;

// Handle inviting other users.
- (void)didTapInvite;

// Refresh the stream.
- (void)didTapRefresh;

// Display the users profile or activities.
- (void)didTapProfile;

// Sign in, using the web.
- (void)didTapSignInWeb;

// Display the theme picker.
- (void)didTapChangeTheme;

// Display a place for the user to enter their feedback.
- (void)didTapSendFeedback;

// Disconnect the user from the PhotoHunt application.
- (void)didTapDisconnect;

// Return the current user.
- (FSHProfile *)currentUser;

// Return the current theme.
- (ThemeObj *)currentTheme;

@end

// Manage the table used as the sliding menu.
@interface MenuSource : NSObject <
    UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic, weak) id<MenuSourceDelegate> delegate;

// Initialise the object with the suppled delegate.
- (id)initWithDelegate:(id<MenuSourceDelegate>)delegate;

// Refresh the menu, to check for state changes.
- (void)reloadMenu;

@end
