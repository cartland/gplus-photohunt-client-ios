//
//  ThemeManager.m
//  PhotoHunt

#import "FSHPhoto.h"
#import "GTLQueryFSH.h"
#import "GTLServiceFSH.h"
#import "GTMLogger.h"
#import "ThemeManager.h"

static const NSInteger kThemeCheckInterval = 300;
static NSString * const kLatestOrder = @"recent";
static NSString * const kBestOrder = @"best";

@interface ThemeManager () {
  id<ThemeManagerDelegate> delegate;
  GTLServiceFSH *service;
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
  return [self initWithDelegate:nil andService:nil];
}

- (id)initWithDelegate:(id<ThemeManagerDelegate>)tmdelegate
            andService:(GTLServiceFSH *)gtlservice {
  self  = [super init];
  if (self) {
    delegate = tmdelegate;
    service = [gtlservice retain];
    orderByLatest = YES;
    [self reloadThemes];
  }
  return self;
}

- (void)dealloc {
  [_themes release];
  [_allPhotos release];
  [_friendPhotos release];
  [_currentThemeId release];
  [_currentUserId release];
  [service release];
  [super dealloc];
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
  return [self.themes objectAtIndexedSubscript:0];
}

- (BOOL)setThemeId:(NSString *)themeId {
  if (![themeId isEqualToString:self.currentThemeId]) {
    self.currentThemeId = themeId;
    self.allPhotos = nil;
    self.friendPhotos = nil;
    if ([themeId isEqualToString:[self getLatestTheme].identifier]) {
      orderByLatest = YES;
    } else {
      orderByLatest = NO;
    }
    [self updateThemeDataTriggeredAutomatically:NO];
    return YES;
  }
  return NO;
}


- (BOOL)setUserId:(NSString *)userId {
  if (![self.currentUserId isEqualToString:userId]) {
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
  GTLQueryFSH *themeQuery = [GTLQueryFSH queryForThemes];
  [service executeRestQuery:themeQuery
          completionHandler:^(GTLServiceTicket *ticket,
                              FSHThemes *sthemes,
                              NSError *error) {
              if (error) {
                [self handleError:error];
                return;
              } else if (!sthemes ||
                         !sthemes.items ||
                         [sthemes.items count] == 0) {
                // If it doesn't look right, just ignore it.
                return;
              } else {
                BOOL newTheme = NO;
                if (!self.themes ||
                    [self.themes.items count] < [sthemes.items count]) {
                  newTheme = YES;
                }
                self.themes = sthemes;

                if (newTheme) {
                  [delegate newThemeAvailable];
                }
              }
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
    GTLQueryFSH *friendsQuery  =
    [GTLQueryFSH queryForImagesByFriendsWithUserId:self.currentUserId
                                         inThemeId:self.currentThemeId
                                         orderedBy:[self getCurrentOrder]];
    [service executeRestQuery:friendsQuery
            completionHandler:^(GTLServiceTicket *iticket,
                                FSHPhotos *sphotos,
                                NSError *error) {
              allFriendsCompleted = YES;
              [delegate completedAction];
              if (error) {
                [self handleError:error];
                if (self.allPhotos) {
                  [self callAllImagesUpdate];
                }
                return;
              }

              self.friendPhotos = sphotos;
              if (self.allPhotos) {
                [self callAllImagesUpdate];
              }
              [self sortPhotos:self.friendPhotos];
              [delegate updateFriendsPhotos:self.friendPhotos];
            }];
  }

  GTLQueryFSH *alluserQuery =
      [GTLQueryFSH queryForImagesWithThemeId:self.currentThemeId
                                   orderedBy:[self getCurrentOrder]];

  [service executeRestQuery:alluserQuery
          completionHandler:^(GTLServiceTicket *iticket,
                              FSHPhotos *sphotos,
                              NSError *error) {
            inRequest = NO;
            if (error) {
              [self handleError:error];
              return;
            }

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
    [fMap setObject:p.identifier forKey:p.identifier];
  }

  NSMutableArray *items = [NSMutableArray array];
  for (FSHPhoto* p in self.allPhotos.items) {
    if (![fMap objectForKey:p.identifier]) {
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
  NSArray *sortedArray = [photos.items
                          sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                            if (orderByLatest) {
                              if ([[(FSHPhoto *)a dateCreated] intValue] >
                                  [[(FSHPhoto *)b dateCreated] intValue]) {
                                return NSOrderedAscending;
                              } else {
                                return NSOrderedDescending;
                              }
                            } else {
                              if ([[(FSHPhoto *)a votes] intValue] <
                                  [[(FSHPhoto *)b votes] intValue]) {
                                return NSOrderedDescending;
                              } else {
                                return NSOrderedAscending;
                              }
                            }
                          }];
  photos.items = sortedArray;
}

@end
