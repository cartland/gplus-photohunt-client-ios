//
//  FSHTheme.m
//  PhotoHunt

#import "FSHTheme.h"

@implementation FSHTheme

@dynamic identifier, displayName;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
  [NSDictionary dictionaryWithObject:@"id"
                              forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"photohunt#theme"];
}

@end
