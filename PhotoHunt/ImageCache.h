//
//  ImageCache.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "GTLServiceFSH.h"

// Provided a central place to manage the images that are retrieved in various
// parts of PhotoHunt - including the main photos, profile images, and the app
// activity images. Keeps a limited size of cache, and also provides the ability
// to generate URLs for resizing images on the server side.
@interface ImageCache : NSObject

// Initalise with the PhotoHunt service.
-(id)initWithService:(GTLServiceFSH *)service;

// Update |imageView| with the image retrieved from |url|. If |spinner| is
// supplied set it to stop animating when done.
- (BOOL)setImageView:(UIImageView *)imageview
              forURL:(NSString *)url
         withSpinner:(UIActivityIndicatorView *)spinner;

// Return a |url| modified with server-side resize parameters for the provided
// |width| and |height|.
- (NSString *)getResizeUrl:(NSString *)url
                  forWidth:(NSInteger)width
                 andHeight:(NSInteger)height;

// We use |imageUrls| as a ring buffer to implement the LRU cache functionality.
@property (nonatomic, retain) NSMutableArray *imageUrls;
@property (nonatomic, retain) NSMutableSet *currentFetches;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, assign) NSUInteger curImage;
@property (nonatomic, retain) GTLServiceFSH *service;

@end
