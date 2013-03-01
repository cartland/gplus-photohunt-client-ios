//
//  GTLServiceFSH.m
//  PhotoHunt

#import "GTLQueryFSH.h"
#import "GTLServiceFSH.h"

@interface GTLServiceFSH () {
  NSURL* baseUrl;
}

@end

@implementation GTLServiceFSH


- (id)init {
  return [self initWithURL:nil];
}

- (id)initWithURL:(NSString *)url {
  self = [super init];
  if (self) {
    baseUrl = [[NSURL URLWithString:url] retain];
  }
  return self;
}

- (void)dealloc {
  [baseUrl release];
  [super dealloc];
}

- (void)executeUpload:(GTLQueryFSH *)query
    completionHandler:(void (^)(NSData *data, NSError *error))handler {
  NSURL *url = [NSURL URLWithString: query.methodName relativeToURL: baseUrl];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  NSString *boundary = [query.urlQueryParameters objectForKey:@"boundary"];
  NSString *contentType = [NSString stringWithFormat:
                           @"multipart/form-data; boundary=%@", boundary];
  [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

  NSMutableData *body = [query.urlQueryParameters objectForKey:@"postData"];

  NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

  GTMHTTPFetcherService *fetcherService = self.fetcherService;
  GTMHTTPFetcher* fetcher = [fetcherService fetcherWithRequest:request];

  [fetcher setPostData:body];
  [fetcher beginFetchWithCompletionHandler:handler];
}

- (void)fetchImage:(NSString *)image
    completionHandler:(void (^)(NSData *data, NSError *error))handler {
  NSMutableURLRequest *request = [NSMutableURLRequest
                                  requestWithURL:[NSURL URLWithString:image]];
  GTMHTTPFetcherService *fetcherService = self.fetcherService;
  GTMHTTPFetcher* fetcher = [fetcherService fetcherWithRequest:request];
  [fetcher beginFetchWithCompletionHandler:handler];
}


- (GTLServiceTicket *)executeRestQuery:(GTLQueryFSH *)query
                     completionHandler:
    (void (^)(GTLServiceTicket *ticket, id object, NSError *error))handler {
  NSURL *url = [NSURL URLWithString:query.methodName relativeToURL:baseUrl];

  GTLObject *bodyObject = query.bodyObject;
  if ([query.type isEqualToString:@"POST"]) {
    return [self fetchObjectByInsertingObject:bodyObject
                                       forURL:url
                            completionHandler:handler];
  } else if ([query.type isEqualToString:@"PUT"]) {
    return [self fetchObjectByUpdatingObject:bodyObject
                                      forURL:url
                           completionHandler: handler];
  } else if ([query.type isEqualToString:@"DELETE"]) {
    return [self deleteResourceURL:url ETag:nil completionHandler:handler];
  } else {
    return [self fetchObjectWithURL:url completionHandler:handler];
  }
}

@end
