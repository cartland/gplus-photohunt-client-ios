//
//  ImageCache.m
//  PhotoHunt

#import "ImageCache.h"
#import "UIImageView+AFNetworking.h"

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
    self.imageUrls = [[NSMutableArray alloc]
                         initWithCapacity:kCacheLimit + kCacheBoundLimit];
    self.images = [[NSMutableDictionary alloc]
                         initWithCapacity:kCacheLimit + kCacheBoundLimit];
    self.currentFetches = [[NSMutableSet alloc]
                              initWithCapacity:kCacheLimit + kCacheBoundLimit];
    // Test the scale for whether to use retina. We don't need to check for
    // the presence of this selector as we are iOS 5+ only, and the scale
    // property was added in 4.
    useRetina = [UIScreen mainScreen].scale == 2.0;
  }
  return self;
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
    [imageview setImageWithURL:[NSURL URLWithString:url]];
    [spinner stopAnimating];
    return YES;
}

@end
