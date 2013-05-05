//
//  FSHAccessToken.h
//  PhotoHunt

#import <GoogleOpenSource/GoogleOpenSource.h>

// Object used to pass an OAuth 2.0 access token to PhotoHunt.
@interface FSHAccessToken : GTLObject

// The OAuth 2.0 access token.
@property (copy) NSString* access_token;
@property (assign) NSInteger identifier;
@property (copy) NSString *googleUserId;
@property (copy) NSString *googleDisplayName;
@property (copy) NSString *googlePublicProfileUrl;
@property (copy) NSString *googlePublicProfilePhotoUrl;

@end