//
//  GTLQueryFSH.h
//  PhotoHunt

#import "FSHAccessToken.h"
#import "GTLQuery.h"

// Provide a series of functions for querying the PhotoHunt API
@interface GTLQueryFSH : GTLQuery

// Type of query.
@property (retain) NSString *type;

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

// Create a query to retrieve a list of friends from PhotoHunt API given a
// user ID. This can be the special id @"me" in order to use the currently
// logged in user.
+ (id)queryForFriendsWithUserId:(NSString *)userId;

// Create a query to retrieve the profile of a user. The user ID can either be
// a general PhotoHunt user ID or the special string @"me" to retrieve the
// currently logged in user.
+ (id)queryForUserWithUserId:(NSString *)userId;

// Create a query to retrieve the current list of themes.
+ (id)queryForThemes;

// Create a query to add a vote for a given image. If the user has already voted
// or it is there own image it will be ignored service side.
+ (id)queryToAddVoteWithImageId:(NSString *)imageId;

// Create a query to remove a vote, from an image specified by |imageId|. If the
// user has not voted the delete will fail.
+ (id)queryToDeleteVoteWithImageId:(NSString *)imageId;

// Create a query for a new upload URL. Images in PhotoHunt are uploaded to a
// special one time URL - executing this call will return one of those.
+ (id)queryForUploadUrl;

// Create a query to upload an image, to a URL retrieved from
// |queryForUploadUrl|. If successful, executing this query will return a
// FSHPhoto object.
+ (id)queryToUploadImagesWithThemeId:(NSString *)themeId
                           uploadUrl:(NSString*)uploadUrl
                               image:(UIImage *)image;

// Create a query to retrieve a given image from the PhotoHunt API.
+ (id)queryForImageWithImageId:(NSString *)imageId;

// Create a query to delete an image, specified by |imageId|. If the current
// user is not the author of the image, the delete will fail.
+ (id)queryToDeleteImageWithImageId:(NSString *)imageId;

// Create a query to retrieve a list of images with a given theme. Order
// sorts the list either by votes (best, -best for reverse order) or recency
// (latest, -latest for reverse order).
+ (id)queryForImagesWithThemeId:(NSString *)themeId
                      orderedBy:(NSString *)order;

// Create a query to retrieve a list of photos uploaded by a given user, with a
// given ordering.
+ (id)queryForImagesWithUserId:(NSString *)userId
                     orderedBy:(NSString *)order;

// Create a query to retrieve a list of images by a friends of a given user,
// with a given ordering.
+ (id)queryForImagesByFriendsWithUserId:(NSString *)userId
                              orderedBy:(NSString *)order;

// Create a query to retrieve a list of images uploaded by friends of a given
// user, within a certain theme, ordered by the given parameter
// (best or latest).
+ (id)queryForImagesByFriendsWithUserId:(NSString *)userId
                              inThemeId:(NSString *)themeId
                              orderedBy:(NSString *)order;

// Create a query to retrieve a lit of images uploaded by a user in a given
// theme, ordered by best or latest.
+ (id)queryForImagesWithUserId:(NSString *)userId
                     inThemeId:(NSString *)themeId
                     orderedBy:(NSString *)order;

@end
