//
//  FSHThemes.m
//  PhotoHunt

#import "FSHTheme.h"
#import "FSHThemes.h"

@implementation FSHThemes

@dynamic startIndex, count, totalResults, items;

+ (void)load {
  [self registerObjectClassForKind:@"fotoscavengerhunt#themes"];
}

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map = [NSDictionary dictionaryWithObject:[FSHTheme class]
                                                  forKey:@"items"];
  return map;
}

@end
