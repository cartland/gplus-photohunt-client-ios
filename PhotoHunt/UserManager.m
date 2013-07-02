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
//  UserManager.m
//  PhotoHunt

#import "FSHAccessToken.h"
#import "FSHClient.h"
#import "GAI.h"
#import "GAITracker.h"
#import "UserManager.h"

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

      FSHAccessToken *token = [FSHAccessToken alloc];
      token.access_token = [NSString stringWithFormat:@"%@",
                               self.currentAuth.accessToken];
      NSString *methodName = @"api/connect";
      
      [[FSHClient sharedClient] postPath:methodName parameters:[token dictionary] success:^(AFHTTPRequestOperation *operation, id JSON) {
          FSHAccessToken *session = [[FSHAccessToken alloc] initWithJson:JSON];
          GTMLoggerDebug(@"Logged In User: %d", session.identifier);
          if (self.currentUser.identifier == session.identifier) {
              // No need to refresh user.
              [self.delegate tokenRefreshed];
              [self.delegate completedAction];
          } else {
              FSHProfile *user = [[FSHProfile alloc] init];
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
