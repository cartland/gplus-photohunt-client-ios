//
//  ThemeManager.m
//  PhotoHunt

#import "FSHClient.h"
#import "FSHPhoto.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "ThemeManager.h"
#import "ThemesObj.h"
#import "PhotosObj.h"

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

- (ThemeObj *)getLatestTheme {
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
    [[FSHClient sharedClient] getPath:@"api/themes" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        ThemesObj *sthemes = [[ThemesObj alloc] initWithJson:JSON];
        
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
    if (self.currentUserId) {
        NSString *imagesByFriendsPath = [NSString stringWithFormat:
                                         @"api/photos?themeId=%d&friends=true",
                                         self.currentThemeId];
        [[FSHClient sharedClient] getPath:imagesByFriendsPath parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
            allFriendsCompleted = YES;
            [delegate completedAction];
            
            PhotosObj *sphotos = [[PhotosObj alloc] initWithJson:JSON];
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
    NSString *allImagesPath = [NSString stringWithFormat:
                               @"api/photos?themeId=%d",
                               self.currentThemeId];
    [[FSHClient sharedClient] getPath:allImagesPath parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        inRequest = NO;
        
        PhotosObj *sphotos = [[PhotosObj alloc] initWithJson:JSON];
        
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

- (void)sortPhotos:(PhotosObj *)photos {
  NSArray *sorted = [photos.items
                        sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                          if (orderByLatest) {
                            if ([(PhotoObj *)a created] >
                                [(PhotoObj *)b created]) {
                              return NSOrderedAscending;
                            } else {
                              return NSOrderedDescending;
                            }
                          } else {
                            if ([(PhotoObj *)a numVotes] <
                                [(PhotoObj *)b numVotes]) {
                              return NSOrderedDescending;
                            } else {
                              return NSOrderedAscending;
                            }
                          }
                        }];
  photos.items = sorted;
}

@end
