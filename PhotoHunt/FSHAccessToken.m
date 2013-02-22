//
//  FSHAccessToken.m
//  PhotoHunt

#import "FSHAccessToken.h"

@implementation FSHAccessToken
@dynamic access_token;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map = [NSDictionary dictionaryWithObject:@"id"
                                                  forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"fotoscavengerhunt#accesstoken"];
}

@end
