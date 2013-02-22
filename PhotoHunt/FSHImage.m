//
//  FSHImage.m
//  PhotoHunt

#import "FSHImage.h"

@implementation FSHImage

@dynamic url, width, height;

+ (void)load {
  [self registerObjectClassForKind:@"fotoscavengerhunt#image"];
}

@end
