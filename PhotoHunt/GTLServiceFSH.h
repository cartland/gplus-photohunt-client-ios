//
//  GTLServiceFSH.h
//  PhotoHunt

#import <GoogleOpenSource/GoogleOpenSource.h>

// Execute a query against the PhotoHunt API.
@interface GTLServiceFSH : GTLService

// Initialise the GTLServiceFSH to point to the supplied URL. 
- (id)initWithURL:(NSString *)url;

@end
