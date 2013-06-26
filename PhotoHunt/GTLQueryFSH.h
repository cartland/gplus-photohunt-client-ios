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

// Given an OAuth 2.0 access token, create a query to retrieve a PhotoHunt
// session ID. This will be stored within the service used to execute the query
// and if the same service is used elsewhere, the actual session response
// does not need to be kept, as it is automatically part of the cookie
// jar on the service object.
+ (id)queryForSessionIdWithAccessToken:(FSHAccessToken *)accessToken;

// Create a query to disconnect the user and the application, marking the
// service as disconnected and removing user data.
+ (id)queryToDisconnect;

// Create a query to add a vote for a given image. If the user has already voted
// or it is there own image it will be ignored service side.
+ (id)queryToAddVoteWithPhoto:(NSInteger)photoId;

// Create a query for a new upload URL. Images in PhotoHunt are uploaded to a
// special one time URL - executing this call will return one of those.
+ (id)queryForUploadUrl;

// Create a query to upload an image, to a URL retrieved from
// |queryForUploadUrl|. If successful, executing this query will return a
// FSHPhoto object.
+ (id)queryToUploadImagesWithThemeId:(NSInteger)themeId
                           uploadUrl:(NSString *)uploadUrl
                               image:(UIImage *)image;
// Create a query to delete an image, specified by |imageId|. If the current
// user is not the author of the image, the delete will fail.
+ (id)queryToDeleteImageWithImageId:(NSInteger)imageId;

@end
