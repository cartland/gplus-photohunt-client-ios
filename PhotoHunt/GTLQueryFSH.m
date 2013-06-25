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

+ (id)queryForSessionIdWithAccessToken:(FSHAccessToken *)accessToken {
  NSString *methodName = @"/api/connect";
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.bodyObject = accessToken;
  query.expectedObjectClass = [FSHAccessToken class];
  query.type = @"POST";
  return query;
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

+ (id)queryToAddVoteWithPhoto:(NSInteger)photoId {
  NSString *methodName = @"/api/votes";
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhoto class];
  FSHPhoto *im = [[FSHPhoto alloc] init];
  im.photoId = photoId;
  query.bodyObject = im;
  query.type = @"PUT";
  return query;
}

+ (id)queryForUploadUrl {
  NSString *methodName = @"/api/images";
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  FSHUploadUrl *url = [FSHUploadUrl object];
  NSMutableData *body = [NSMutableData data];
  query.bodyObject = url;
  query.urlQueryParameters = [NSMutableDictionary
                              dictionaryWithObjectsAndKeys:body,
                              @"postData",
                              nil];
  query.type = @"POST";
  return query;
}

+ (id)queryToUploadImagesWithThemeId: (NSInteger)themeId
                           uploadUrl: (NSString*)uploadUrl
                               image: (UIImage *)image {
  NSString *methodName = uploadUrl;
  GTLQueryFSH *query = [self queryWithMethodName:methodName];

  NSMutableData *body = [NSMutableData data];
  NSString *boundaryString = @"multipartformboundary1354693654617";
  [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryString]
                    dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[@"Content-Disposition: form-data; name=\"themeId\"\r\n\r\n"
                    dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"%d\r\n", themeId]
                    dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryString]
                    dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:
    @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n",
                     @"image"]
                    dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n"
                    dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:UIImageJPEGRepresentation(image, 1.0)];
  [body appendData:[[NSString stringWithFormat:@"\r\n"]
                    dataUsingEncoding:NSUTF8StringEncoding]];

  [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundaryString]
                    dataUsingEncoding:NSUTF8StringEncoding]];

  query.urlQueryParameters = [NSMutableDictionary
                              dictionaryWithObjectsAndKeys:body,
                              @"postData",
                              boundaryString,
                              @"boundary",
                              nil];
  query.expectedObjectClass = [FSHPhoto class];
  query.type = @"POST";
  return query;
}

+ (id)queryForImageWithImageId:(NSInteger)imageId {
  NSString *methodName = [NSString stringWithFormat:@"/api/photos?photoId=%d",
                             imageId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhoto class];
  query.type = @"GET";
  return query;
}

+ (id)queryToDeleteImageWithImageId:(NSInteger)imageId {
  NSString *methodName = [NSString
                          stringWithFormat:@"/api/photos?photoId=%d",
                              imageId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhoto class];
  query.type = @"DELETE";
  return query;
}

+ (id)queryForImagesWithThemeId:(NSInteger)themeId {
  NSString *methodName = [NSString
      stringWithFormat:@"/api/photos?themeId=%d&items=true", themeId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhotos class];
  query.type = @"GET";
  return query;
}

+ (id)queryForImagesByFriendsInThemeId:(NSInteger)themeId {
  NSString *methodName = [NSString stringWithFormat:
                          @"/api/photos?themeId=%d&items=true&friends=true",
                              themeId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhotos class];
  query.type = @"GET";
  return query;
}

@end
