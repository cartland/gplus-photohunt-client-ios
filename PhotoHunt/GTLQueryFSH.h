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

// All functions below return GTLQueryFSH objects which can be passed to
// the GTLServiceFSH execute methods in order to query the PhotoHunt backend.
// By themselves, these functions just set up the query, they don't actually
// make any calls.

// Create a query to disconnect the user and the application, marking the
// service as disconnected and removing user data.
+ (id)queryToDisconnect;

@end
