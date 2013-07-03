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
//  ThemeManager.m
//  PhotoHunt

#import "FSHClient.h"
#import "FSHPhoto.h"
#import "FSHPhotos.h"
#import "FSHThemes.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "ThemeManager.h"

static const NSInteger kThemeCheckInterval = 300;
static NSString * const kLatestOrder = @"recent";
static NSString * const kBestOrder = @"best";

@interface ThemeManager () {
  id<ThemeManagerDelegate> delegate;
  NSTimeInterval lastRetrievedThemesAt;
  BOOL isBackgroundCall;
  BOOL orderByLatest;
  NSInteger allCount;
  BOOL inRequest;
  BOOL allFriendsCompleted;
}

@end;

@implementation ThemeManager

- (id)init {
  return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<ThemeManagerDelegate>)tmdelegate {
  self  = [super init];
  if (self) {
    delegate = tmdelegate;
    orderByLatest = YES;
    [self reloadThemes];
  }
  return self;
}


#pragma mark - Calls from owner

- (void)authRefreshed {
  [self updateThemeDataTriggeredAutomatically:NO];
}

- (NSString *)getCurrentOrder {
  return orderByLatest ? kLatestOrder : kBestOrder;
}

- (NSString *)flipOrder {
  orderByLatest = !orderByLatest;
  if (self.friendPhotos) {
    [self sortPhotos:self.friendPhotos];
    [delegate updateFriendsPhotos:self.friendPhotos];
  }
  if (self.allPhotos) {
    [self sortPhotos:self.allPhotos];
    [delegate updateAllUserPhotos:self.allPhotos];
  }
  return [self getCurrentOrder];
}

- (void)triggerRetry {
  [self updateThemeDataTriggeredAutomatically:isBackgroundCall];
}

- (void)updateThemeDataTriggeredAutomatically:(BOOL)background {
  isBackgroundCall = background;
  NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
  if (!self.themes || timeStamp - lastRetrievedThemesAt > kThemeCheckInterval) {
    [self reloadThemes];
    lastRetrievedThemesAt = timeStamp;
  }
  
  [self reloadThemeData];
}

- (FSHTheme *)getLatestTheme {
  return [self.themes.items objectAtIndex:0];
}

- (BOOL)setThemeId:(NSInteger)themeId {
  if (themeId != self.currentThemeId) {
    self.currentThemeId = themeId;
    self.allPhotos = nil;
    self.friendPhotos = nil;
    if (themeId  == [self getLatestTheme].identifier) {
      orderByLatest = YES;
    } else {
      orderByLatest = NO;
    }
    [self updateThemeDataTriggeredAutomatically:NO];
    return YES;
  }
  return NO;
}


- (BOOL)setUserId:(NSInteger)userId {
  if (self.currentUserId != userId) {
    self.currentUserId = userId;
    self.allPhotos = nil;
    self.friendPhotos = nil;
    allCount = 0;
    [self updateThemeDataTriggeredAutomatically:NO];
    [delegate startedAction];
    return YES;
  }
  return NO;
}

#pragma mark - Query and handle errors

- (void) handleError:(NSError *)error {
  GTMLoggerDebug(@"Theme Error: %@", error);
  
  if ([error.domain isEqual:@"com.google.HTTPStatus"] && error.code == 401) {
    [delegate refreshAuth];
  } else if ([error.domain isEqual:@"com.google.HTTPStatus"] && error.code == 500) {
    // Issue with the backend, treat it as likely recoverable in future.
    [delegate completedAction];
    if(!self.allPhotos && !self.friendPhotos) {
      [delegate connectionOffline:NO];
    }
  } else if (error.domain == NSURLErrorDomain ||
             [error.domain isEqual:@"com.google.HTTPStatus"]) {
    if (!isBackgroundCall) {
      [delegate connectionOffline:YES];
    } else {
      if(!self.allPhotos && !self.friendPhotos) {
        [delegate connectionOffline:NO];
      }
      [delegate completedAction];
    }
    return;
  }
  
  // Try again in 5 seconds.
  [NSTimer scheduledTimerWithTimeInterval:5.0
                                   target:self
                                 selector:@selector(triggerRetry)
                                 userInfo:nil
                                  repeats:NO];
}

- (void)reloadThemes {
  FSHClient *client = [FSHClient sharedClient];
  NSString *path = [client pathForThemes];
  
  [client getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSArray *array = responseObject;
    FSHThemes *sthemes = [[FSHThemes alloc] initWithArray:array];
    
    if (![sthemes.items count]) {
      // If it doesn't look right, just ignore it.
      return;
    } else {
      BOOL newTheme = NO;
      if ([self.themes.items count] < [sthemes.items count]) {
        newTheme = YES;
      }
      self.themes = sthemes;
      
      if (newTheme) {
        [delegate newThemeAvailable];
      }
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [self handleError:error];
    return;
  }];
}

-(void)reloadThemeData {
  if (!self.currentThemeId || (inRequest && isBackgroundCall)) {
    // NOP if we don't have a theme to load.
    return;
  }
  
  // Flag to prevent too many requests happening at once.
  inRequest = YES;
  // Flag to signal completion.
  allFriendsCompleted = NO;
  
  // Retrieve photos by friends and all photos in parallel. If friends
  // returns first, update the friends list, and on the all photos response
  // deduplicate then update that. If all photos returns first hold off
  // updating - once friends photos come back (with an error or success)
  // deduplicate if necessary and refresh both.
  FSHClient *client = [FSHClient sharedClient];

  if (self.currentUserId) {
    NSString *imagesByFriendsPath = [client pathForPhotosByTheme:self.currentThemeId friendsOnly:YES];
    
    [client getPath:imagesByFriendsPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSArray *array = responseObject;
      FSHPhotos *sphotos = [[FSHPhotos alloc] initWithArray:array];

      allFriendsCompleted = YES;
      [delegate completedAction];

      self.friendPhotos = sphotos;
      if (self.allPhotos) {
        [self callAllImagesUpdate];
      }
      [self sortPhotos:self.friendPhotos];
      [delegate updateFriendsPhotos:self.friendPhotos];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      allFriendsCompleted = YES;
      [delegate completedAction];
      
      [self handleError:error];
      if (self.allPhotos) {
        [self callAllImagesUpdate];
      }
    }];
  }
  
  NSString *allImagesPath = [client pathForPhotosByTheme:self.currentThemeId friendsOnly:NO];
  
  [client getPath:allImagesPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSArray *array = responseObject;
    FSHPhotos *sphotos = [[FSHPhotos alloc] initWithArray:array];

    inRequest = NO;
    
    if (!self.allPhotos || [sphotos.items count] > allCount) {
      self.allPhotos = sphotos;
    }
    
    if (!self.currentUserId || allFriendsCompleted) {
      [self callAllImagesUpdate];
    }
    
    if (!self.currentUserId) {
      // We will only reach this if there is no current user,
      // so we know friends query isn't going to complete.
      [delegate completedAction];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    inRequest = NO;
    
    [self handleError:error];
  }];
}

- (void)callAllImagesUpdate {
  if (self.friendPhotos) {
    [self deduplicatePhotos];
  }
  allCount = [self.allPhotos.items count];
  [self sortPhotos:self.allPhotos];
  [delegate updateAllUserPhotos:self.allPhotos];
  allCount = [self.allPhotos.items count];
}

#pragma mark - Photo array functions

- (BOOL)deduplicatePhotos {
  if (!self.allPhotos || !self.friendPhotos) {
    return NO;
  }
  
  NSMutableDictionary *fMap = [NSMutableDictionary dictionaryWithCapacity:
                               [self.friendPhotos.items count]];
  
  for (FSHPhoto* p in self.friendPhotos.items) {
    NSNumber *ident = [NSNumber numberWithInt:p.identifier];
    [fMap setObject:ident forKey:ident];
  }
  
  NSMutableArray *items = [NSMutableArray array];
  for (FSHPhoto* p in self.allPhotos.items) {
    NSNumber *ident = [NSNumber numberWithInt:p.identifier];
    if (![fMap objectForKey:ident]) {
      [items addObject:p];
    }
  }
  if ([items count] < [self.allPhotos.items count]) {
    self.allPhotos.items = items;
    return YES;
  }
  return NO;
}

- (void)sortPhotos:(FSHPhotos *)photos {
  NSArray *sorted = [photos.items
                     sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                       if (orderByLatest) {
                         if ([(FSHPhoto *)a created] >
                             [(FSHPhoto *)b created]) {
                           return NSOrderedAscending;
                         } else {
                           return NSOrderedDescending;
                         }
                       } else {
                         if ([(FSHPhoto *)a numVotes] <
                             [(FSHPhoto *)b numVotes]) {
                           return NSOrderedDescending;
                         } else {
                           return NSOrderedAscending;
                         }
                       }
                     }];
  photos.items = sorted;
}

@end
