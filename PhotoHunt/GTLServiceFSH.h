//
//  GTLServiceFSH.h
//  PhotoHunt

#import "GTLService.h"

// Execute a query against the PhotoHunt API.
@interface GTLServiceFSH : GTLService

// Initialise the GTLServiceFSH to point to the supplied URL. 
- (id)initWithURL:(NSString *)url;

// Execute an upload query, call the completion handler after.
- (void)executeUpload:(id<GTLQueryProtocol>)query
    completionHandler:(void (^)(NSData *data, NSError *error))completionHandler;

// Execute a RESTful query to the PhotoHunt API.
- (GTLServiceTicket *)executeRestQuery:(id<GTLQueryProtocol>)query
                     completionHandler:
      (void (^)(GTLServiceTicket *ticket, id object, NSError *error))handler;

// Retrieve an image from the given URL.
- (void)fetchImage:(NSString *)image
    completionHandler:(void (^)(NSData *data, NSError *error))completionHandler;

@end
