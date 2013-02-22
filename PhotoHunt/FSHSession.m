//
//  FSHSession.m
//  PhotoHunt

#import "FSHSession.h"

@implementation FSHSession

@dynamic session;

+ (void)load {
  [self registerObjectClassForKind:@"fotoscavengerhunt#session"];
}

@end
