//
//  FSHPerson.m
//  PhotoHunt

#import "FSHProfile.h"

@implementation FSHProfile

@dynamic  identifier,
          displayName,
          profilePhotoUrl,
          googlePlusId,
          googlePlusProfileUrl;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
  [NSDictionary dictionaryWithObject:@"id"
                              forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"fotoscavengerhunt#profile"];
}

@end
