/*
 *
 * Copyright 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//  FSHClient.m
//  PhotoHunt

#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import "FSHClient.h"
#import "FSHUploadUrl.h"

@implementation FSHClient

+ (FSHClient *)sharedClient {
  static FSHClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                             delegate];
  NSString *baseUrlString = appDelegate.photohuntWebUrl;
  dispatch_once(&onceToken, ^{
    _sharedClient = [[FSHClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrlString]];
  });
  
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  
  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
  [self setParameterEncoding:AFJSONParameterEncoding];
  
  // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
  
  return self;
}

- (NSString *)pathForPhoto:(NSInteger)photoId {
  return [NSString stringWithFormat:@"api/photos?photoId=%d", photoId];
}

- (NSString *)pathForDisconnect {
  return @"api/disconnect";
}

- (NSString *)pathToDeletePhoto:(NSInteger)photoId {
  return [NSString stringWithFormat:@"api/photos?photoId=%d", photoId];
}

- (NSString *)pathToPutVote {
  return @"api/votes";
}

- (NSDictionary *)paramsToVoteForPhoto:(id)photoId {
  return [[NSDictionary alloc] initWithObjectsAndKeys:
          photoId,
          @"photoId", nil];
}

- (NSString *)pathForUploadUrl {
  return @"api/images";
}

- (NSString *)pathForFriends {
  return @"api/friends";
}

- (NSString *)pathForThemes {
  return @"api/themes";
}

- (NSString *)pathForPhotosByTheme:(NSInteger)themeId friendsOnly:(BOOL)friendsOnly {
  if (friendsOnly) {
    return [NSString stringWithFormat:
            @"api/photos?themeId=%d&friends=true",
            themeId];
  } else {
    return [NSString stringWithFormat:
            @"api/photos?themeId=%d",
            themeId];
  }
}

- (NSString *)pathForConnect {
  return @"api/connect";
}

- (NSDictionary *)paramsForConnectWithToken:(FSHAccessToken *)token {
  return [token dictionary];
}

- (void)uploadPhoto:(UIImage *)image
            success:(void (^)(AFHTTPRequestOperation *operation, FSHPhoto *photo))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  FSHClient *client = [FSHClient sharedClient];
  NSString *path = [client pathForUploadUrl];
  
  [client postPath:path
        parameters:nil
           success:
   ^(AFHTTPRequestOperation *operation, id responseObject) {
     NSDictionary *attributes = responseObject;
     FSHUploadUrl *urlResponse = [[FSHUploadUrl alloc] initWithAttributes:attributes];
     
     NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
     
     NSMutableURLRequest *request =
     [client multipartFormRequestWithMethod:@"POST"
                                       path:urlResponse.url
                                 parameters:nil
                  constructingBodyWithBlock:
      ^(id<AFMultipartFormData> formData) {
        [formData
         appendPartWithFileData:imageData
         name:@"image"
         fileName:@"photo.jpg"
         mimeType:@"image/jpeg"];
      }];
     
     AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id data) {
       NSError *error;
       NSDictionary *attributes = [NSJSONSerialization
                                   JSONObjectWithData:data
                                   options:nil
                                   error:&error];
       FSHPhoto *photo = [[FSHPhoto alloc] initWithAttributes:attributes];
       success(operation, photo);
     }
                               failure:
      ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
      }];
     [op start];
   }
           failure:
   ^(AFHTTPRequestOperation *operation, NSError *error) {
     failure(operation, error);
   }];
}

@end