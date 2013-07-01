//
//  GTLQueryFSH.h
//  PhotoHunt

#import "FSHAccessToken.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

// Provide a series of functions for querying the PhotoHunt API
@interface GTLQueryFSH : GTLQuery

// Type of query.
@property (strong) NSString *type;

// Selector specifying which fields to include in a partial response.
@property (copy) NSString *fields;
@property (assign) BOOL debug;

@end
