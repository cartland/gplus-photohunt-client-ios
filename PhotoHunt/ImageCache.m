//
//  ImageCache.m
//  PhotoHunt

#import "ImageCache.h"

// Arbitary limit on the size of the cache.
static NSUInteger const kCacheLimit = 26;
// How much may we exceed the cache limit by.
static NSUInteger const kCacheBoundLimit = 10;

@interface ImageCache() {
  BOOL useRetina;
}

@end

@implementation ImageCache

- (id)init {
  return [self initWithService:nil];
}

- (id)initWithService:(GTLServiceFSH *)service {
  self = [super init];
  if (self) {
    self.service = service;
    self.imageUrls = [[[NSMutableArray alloc]
                         initWithCapacity:kCacheLimit + kCacheBoundLimit]
                         autorelease];
    self.images = [[[NSMutableDictionary alloc]
                         initWithCapacity:kCacheLimit + kCacheBoundLimit]
                         autorelease];
    self.currentFetches = [[[NSMutableSet alloc]
                              initWithCapacity:kCacheLimit + kCacheBoundLimit]
                              autorelease];
    // Test the scale for whether to use retina. We don't need to check for
    // the presence of this selector as we are iOS 5+ only, and the scale
    // property was added in 4.
    useRetina = [UIScreen mainScreen].scale == 2.0;
  }
  return self;
}

- (void)dealloc {
  [_imageUrls release];
  [_currentFetches release];
  [_images release];
  [_service release];
  [super dealloc];
}

- (NSString *)getResizeUrl:(NSString *)url
                  forWidth:(NSInteger)width
                 andHeight:(NSInteger)height {
  NSError *error = nil;

  // Request larger images for retina displays.
  if (useRetina) {
    width *= 2;
    height *= 2;
  }

  if (height == width) {
    NSString *size = [NSString stringWithFormat:@"sz=%d", width];

    NSRegularExpression *regex =[NSRegularExpression
        regularExpressionWithPattern:@"\\?sz=\\d+"
                             options:NSRegularExpressionCaseInsensitive
                               error:&error];

    NSString *replaced = [regex stringByReplacingMatchesInString:url
                                   options:0
                                     range:NSMakeRange(0, [url length])
                              withTemplate:@""];
    NSString *resizeUrl = [NSString stringWithFormat:@"%@?%@", replaced, size];
    return resizeUrl;
  } else {
    NSString *size = [NSString stringWithFormat:@"=w%d-h%d-c", width, height];
    NSRegularExpression *regex = [NSRegularExpression
        regularExpressionWithPattern:@"\\=[swh]\\d+"
                             options:NSRegularExpressionCaseInsensitive
                               error:&error];
    NSString *resizeUrl =
        [regex stringByReplacingMatchesInString:url
                                        options:0
                                          range:NSMakeRange(0, [url length])
                                   withTemplate:size];
    return resizeUrl;
  }
}

- (BOOL) setImageView:(UIImageView *)imageview
               forURL:(NSString *)url
          withSpinner:(UIActivityIndicatorView *)spinner {
  [imageview retain];
  [spinner retain];

  // Update the LRU list so we know this URL has been accessed recently
  [self.imageUrls setObject:url atIndexedSubscript:self.curImage];
  self.curImage = (self.curImage + 1) % kCacheLimit;

  // If we have it cached, return it straight away.
  if ([self.images valueForKey:url]) {
    // Push the image to the callers imageview, and trigger the spinner.
    [imageview setImage:(UIImage *)[self.images valueForKey:url]];
    [spinner stopAnimating];
    [spinner release];
    [imageview release];
    return YES;
  }

  if (![self.currentFetches containsObject:url]) { // Don't repeat fetch.
    [self.currentFetches addObject:url];
    [self.service fetchImage:url
           completionHandler:^(NSData *retrievedData,
                               NSError *error) {
               UIImage *pic = [[[UIImage alloc] initWithData:retrievedData]
                                  autorelease];

               // Scale the image for retina if needed.
               if (useRetina) {
                 pic = [UIImage imageWithCGImage:pic.CGImage
                                           scale:2
                                     orientation:pic.imageOrientation];
               }

               [spinner stopAnimating];
               [spinner release];

               [imageview setImage:pic];
               [imageview release];

               [self.currentFetches removeObject:url];

               [self.images setValue:pic forKey:url];

               // Add some headspace so we're not thrashing
               // the cache the whole time.
               if ([self.images count] > kCacheLimit + kCacheBoundLimit) {
                 // If we have too many items, then grab all the known URLs.
                 NSMutableSet *keys = [NSMutableSet
                                          setWithArray:[self.images allKeys]];
                 // We then remove any URLs which have been within the last
                 // kCacheLimit accessses (there may be duplicates).
                 [keys minusSet:[NSSet setWithArray:self.imageUrls]];
                 [self.images removeObjectsForKeys:[keys allObjects]];
               }
           }];
  }
  return NO;
}

@end
