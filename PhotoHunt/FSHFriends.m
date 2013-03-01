//
//  FSHFriends.m
//  PhotoHunt

#import "FSHFriends.h"
#import "FSHProfile.h"

@implementation FSHFriends

@dynamic startIndex, count, totalResults, items;

+ (void)load {
  [self registerObjectClassForKind:@"photohunt#friends"];
}

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map = [NSDictionary dictionaryWithObject:[FSHProfile class]
                                                  forKey:@"items"];
  return map;
}

@end
