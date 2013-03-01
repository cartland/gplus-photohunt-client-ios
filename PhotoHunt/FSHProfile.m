//
//  FSHPerson.m
//  PhotoHunt

#import "FSHProfile.h"

@implementation FSHProfile

@dynamic  identifier,
          googleDisplayName,
          googlePublicProfilePhotoUrl,
          googleUserId,
          googlePlusProfileUrl;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
  [NSDictionary dictionaryWithObject:@"id"
                              forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"photohunt#user"];
}

@end
