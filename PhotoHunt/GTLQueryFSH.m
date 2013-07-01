//
//  GTLQueryFSH.m
//  PhotoHunt

#import "FSHAccessToken.h"
#import "FSHPhoto.h"
#import "FSHPhotos.h"
#import "FSHUploadUrl.h"
#import "GTLQueryFSH.h"

@implementation GTLQueryFSH


+ (NSDictionary *)parameterNameMap {
  NSDictionary *map = [NSDictionary dictionaryWithObject:@"id"
                                                  forKey:@"identifier"];
  return map;
}

@end
