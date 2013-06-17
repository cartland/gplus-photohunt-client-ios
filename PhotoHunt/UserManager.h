//
//  UserManager.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "FSHFriends.H"
#import "FSHProfile.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "GTLServiceFSH.h"

// Protocol for calling back to the owner with changes in the user status.
@protocol UserManagerDelegate <NSObject>

// Signal a user has completed the authentication flow, and that we have their
// profile information. |userId| will generally be @"me", indicating the
// currently logged in user.
- (void)loadedUser:(FSHProfile *)user
            fromId:(NSString *)userId;

// Signal that there is a connection issue. |major| indicates whether it is a
// user action blocking, or a more minor issue.
- (void)connectionOffline:(BOOL)major;

// Signal that the authentication token in the supplied GTLServiceFSH has been
// update.d
- (void)tokenRefreshed;

// Signal the UserManager is about to start some network activity.
- (void)startedAction;

// Signal that the UserManager has completed its current network activity.
- (void)completedAction;

// Signal that the login failed.
- (void)userLoginFailed;

@end

// UserManager represents the sign in delegate for Google+ Sign In, and also
// the interface to the profile and authorisation for the PhotoHunt back end
// services.
@interface UserManager : NSObject <GPPSignInDelegate>

// Initialise the object with a delegate for state callbacks and a service
// for calling the PhotoHunt backend.
- (id)initWithDelegate:(id<UserManagerDelegate>)delegate
            andService:(GTLServiceFSH *)gtlservice;

// Check whether it is possible to sign in without prompting the user.
- (BOOL)canSignIn;

// Sign in. If the user |canSignIn| then this will not prompt them. If not, they
// will be redirected to either the Google+ app (if installed), Chrome (if
// installed) or mobile Safari. Setting |attemptSSO| to false wil skip the
// Google+ app and attempt to sign in with Chrome, or mobile Safari.
- (void)signInAndRetrieveUser:(BOOL)attemptSSO;

// Communicate with the PhotoHunt backend to get a new server-client session.
- (void)refreshToken;

// Sign the user out of PhotoHunt.
- (void)signOut;

// Return an id string for the user.
- (NSString *)selfIdentifier;

@property (nonatomic, strong) GTMOAuth2Authentication *currentAuth;
@property (nonatomic, weak) id<UserManagerDelegate> delegate;
@property (nonatomic, strong) GTLServiceFSH *service;
@property (nonatomic, strong) FSHProfile *currentUser;

@end
