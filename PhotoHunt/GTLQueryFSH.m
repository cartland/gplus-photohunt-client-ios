//
//  GTLQueryFSH.m
//  PhotoHunt

#import "FSHFriends.h"
#import "FSHImage.h"
#import "FSHProfile.h"
#import "FSHPhoto.h"
#import "FSHPhotos.h"
#import "FSHAccessToken.h"
#import "FSHSession.h"
#import "FSHTheme.h"
#import "FSHThemes.h"
#import "FSHUploadUrl.h"
#import "GTLQueryFSH.h"

@implementation GTLQueryFSH

- (void)dealloc {
  [_type release];
  [super dealloc];
}

+ (NSDictionary *)parameterNameMap {
  NSDictionary *map =
  [NSDictionary dictionaryWithObject:@"id"
                              forKey:@"identifier"];
  return map;
}

+ (id)queryForSessionIdWithAccessToken:(FSHAccessToken *)accessToken {
  NSString *methodName = @"/api/session";
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.bodyObject = accessToken;
  query.expectedObjectClass = [FSHSession class];
  query.type = @"POST";
  return query;
}

+ (id)queryForFriendsWithUserId:(NSString *)userId {
  NSString *methodName = [NSString stringWithFormat:@"/api/people/%@/friends",
                          userId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHFriends class];
  query.type = @"GET";
  return query;
}

+ (id)queryForUserWithUserId:(NSString *)userId {
  NSString *methodName = [NSString stringWithFormat:@"/api/people/%@",
                          userId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHProfile class];
  query.type = @"GET";
  return query;
}

+ (id)queryForThemes {
  NSString *methodName = @"/api/themes";
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHThemes class];
  query.type = @"GET";
  return query;
}

+ (id)queryToAddVoteWithImageId:(NSString *)imageId {
  NSString *methodName = [NSString stringWithFormat:@"/api/images/vote/%@",
                          imageId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhoto class];
  query.type = @"PUT";
  return query;
}

+ (id)queryToDeleteVoteWithImageId:(NSString *)imageId {
  NSString *methodName = [NSString stringWithFormat:@"/api/images/vote/%@",
                          imageId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhoto class];
  query.type = @"DELETE";
  return query;
}

+ (id)queryForUploadUrl {
  NSString *methodName = @"/api/images/uploadurl";
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  FSHUploadUrl *url = [FSHUploadUrl object];
  url.url = @"";
  query.bodyObject = url;
  query.expectedObjectClass = [FSHUploadUrl class];
  query.type = @"POST";
  return query;
}

+ (id)queryToUploadImagesWithThemeId: (NSString *)themeId
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
  [body appendData:[[NSString stringWithFormat:@"%@\r\n", themeId]
                    dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryString]
                    dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:
    @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n",
                     @"photo"]
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

+ (id)queryForImageWithImageId:(NSString *)imageId {
  NSString *methodName = [NSString stringWithFormat:@"/api/images/%@", imageId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhoto class];
  query.type = @"GET";
  return query;
}

+ (id)queryToDeleteImageWithImageId:(NSString *)imageId {
  NSString *methodName = [NSString stringWithFormat:@"/api/images/%@", imageId];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHSession class];
  query.type = @"DELETE";
  return query;
}

+ (id)queryForImagesWithThemeId:(NSString *)themeId
                      orderedBy:(NSString *)order {
  NSString *methodName = [NSString
                          stringWithFormat:@"/api/images/theme/%@?orderBy=%@",
                              themeId,
                              order];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhotos class];
  query.type = @"GET";
  return query;
}

+ (id)queryForImagesWithUserId:(NSString *)imageId orderedBy:(NSString *)order {
  NSString *methodName = [NSString stringWithFormat:
                          @"/api/people/%@/images?orderBy=%@",
                              imageId,
                              order];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHSession class];
  query.type = @"GET";
  return query;
}

+ (id)queryForImagesByFriendsWithUserId:(NSString *)imageId
                              inThemeId:(NSString *)themeId
                              orderedBy:(NSString *)order {
  NSString *methodName = [NSString stringWithFormat:
                          @"/api/people/%@/friends/images/%@?orderBy=%@",
                              imageId,
                              themeId,
                              order];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhotos class];
  query.type = @"GET";
  return query;
}

+ (id)queryForImagesByFriendsWithUserId:(NSString *)userId
                              orderedBy:(NSString *)order {
  NSString *methodName = [NSString stringWithFormat:
                          @"/api/people/%@/friends/images?orderBy=%@",
                              userId,
                              order];
  GTLQueryFSH *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [FSHPhotos class];
  query.type = @"GET";
  return query;
}

+ (id)queryForImagesWithUserId:(NSString *)userId
                     inThemeId:(NSString *)themeId
                     orderedBy:(NSString *)order {
    NSString *methodName = [NSString stringWithFormat:
                            @"/api/people/%@/images/%@?orderBy=%@",
                                userId,
                                themeId,
                                order];
    GTLQueryFSH *query = [self queryWithMethodName:methodName];
    query.expectedObjectClass = [FSHPhotos class];
    query.type = @"GET";
    return query;
}

@end
