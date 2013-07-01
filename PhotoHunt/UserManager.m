//
//  UserManager.m
//  PhotoHunt

#import "AccessTokenObj.h"
#import "GAI.h"
#import "GAITracker.h"
#import "UserManager.h"
#import "FSHClient.h"

@implementation UserManager

- (id)init {
  return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<UserManagerDelegate>)delegate{
  self  = [super init];
  if (self) {
    self.delegate = delegate;
  }
  return self;
}


- (BOOL)canSignIn {
  // Check whether we can sign in. If it looks like we should be able to sign in
  // then we return YES so that the caller can avoid taking extra action until
  // the user been retrieved. This call also kicks off the actual authentication
  // process, so we will attempt to seamlessly sign in, and call the usual
  // finishedWithAuth:error: delegate.
  return [[GPPSignIn sharedInstance] trySilentAuthentication];
}

- (void)signInAndRetrieveUser:(BOOL)attemptSSO {
  [GPPSignIn sharedInstance].attemptSSO = attemptSSO;
  [[GPPSignIn sharedInstance] authenticate];
}

- (void)signOut {
  [[GPPSignIn sharedInstance] signOut];
  self.currentAuth = nil;
  self.currentUser = nil;
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *) error {
  if (error) {
    [self.delegate userLoginFailed];
    GTMLoggerDebug(@"Auth Error: %@", error);
    return;
  }

  self.currentAuth = auth;
  [self refreshToken];
}

- (void)refreshToken {
  if (self.currentAuth) {
    [self.delegate startedAction];
  }

  [self.currentAuth authorizeRequest:nil completionHandler:^(NSError *error) {
      if (error) {
        GTMLoggerDebug(@"Token Fetch Error: %@", error);
        if ([error code] == 400) {
          // Our token is bad, clear it.
          [self signOut];
        }
        [self.delegate userLoginFailed];
        return;
      }

      AccessTokenObj *token = [AccessTokenObj alloc];
      token.access_token = [NSString stringWithFormat:@"%@",
                               self.currentAuth.accessToken];
      NSString *methodName = @"/api/connect";
      
      [[FSHClient sharedClient] postPath:methodName parameters:[token dictionary] success:^(AFHTTPRequestOperation *operation, id JSON) {
          AccessTokenObj *session = [[AccessTokenObj alloc] initWithJson:JSON];
          GTMLoggerDebug(@"Logged In User: %d", session.identifier);
          if (self.currentUser.identifier == session.identifier) {
              // No need to refresh user.
              [self.delegate tokenRefreshed];
              [self.delegate completedAction];
          } else {
              ProfileObj *user = [[ProfileObj alloc] init];
              user.identifier = session.identifier;
              user.googleUserId = session.googleUserId;
              user.googleDisplayName = session.googleDisplayName;
              user.googlePublicProfilePhotoUrl = session.googlePublicProfilePhotoUrl;
              [self.delegate loadedUser:user fromId:[self selfIdentifier]];
              [self.delegate completedAction];
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          GTMLoggerDebug(@"Session Error: %@", error);
          [self.delegate userLoginFailed];
      }];
  }];
}

- (NSString *)selfIdentifier {
  return @"me";
}

@end
