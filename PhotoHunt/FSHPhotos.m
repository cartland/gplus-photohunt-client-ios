//
//  FSHPhotos.m
//  PhotoHunt

#import "FSHPhoto.h"
#import "FSHPhotos.h"

@implementation FSHPhotos

@dynamic startIndex, count, totalResults, items;

+ (void)load {
  [self registerObjectClassForKind:@"fotoscavengerhunt#photos"];
}

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map = [NSDictionary dictionaryWithObject:[FSHPhoto class]
                                                  forKey:@"items"];
  return map;
}

@end
