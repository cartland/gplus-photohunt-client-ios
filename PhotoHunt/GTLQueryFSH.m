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

+ (id)queryToDisconnect {
  NSString *methodName = @"/api/disconnect";
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  FSHAccessToken *token = [[FSHAccessToken alloc] init];
  token.googleDisplayName = @" "; // Set a filler to generate JSON.
  query.bodyObject = token;
  query.expectedObjectClass = [FSHAccessToken class];
  query.type = @"POST";
  return query;
}

@end
