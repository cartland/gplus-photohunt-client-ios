//
//  FSHAccessToken.m
//  PhotoHunt

#import "FSHAccessToken.h"

@implementation FSHAccessToken
@dynamic access_token, identifier, googleDisplayName, googlePublicProfilePhotoUrl,
googlePublicProfileUrl, googleUserId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map = [NSDictionary dictionaryWithObject:@"id"
                                                  forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"photohunt#accesstoken"];
}

@end
