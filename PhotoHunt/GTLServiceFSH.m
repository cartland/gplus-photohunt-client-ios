//
//  GTLServiceFSH.m
//  PhotoHunt

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
    baseUrl = [NSURL URLWithString:url];
  }
  return self;
}

@end
