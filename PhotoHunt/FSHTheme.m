//
//  FSHTheme.m
//  PhotoHunt

#import "FSHTheme.h"

@implementation FSHTheme

@dynamic identifier, title;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
  [NSDictionary dictionaryWithObject:@"id"
                              forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"fotoscavengerhunt#theme"];
}

@end
