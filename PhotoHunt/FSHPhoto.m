//
//  FSHPhoto.m
//  PhotoHunt

#import "FSHPhoto.h"

@implementation FSHPhoto

@dynamic identifier, url, votes, author, image,
    thumbnail, theme, voted, dateCreated;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
  [NSDictionary dictionaryWithObject:@"id"
                              forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"fotoscavengerhunt#photo"];
}

- (void)setPhoto:(UIImage *)in_photo {
  self->_photo = in_photo;
  [self->_photo retain];
}

- (UIImage *)photo {
  if (self->_photo) {
    return self->_photo;
  } else if (self.image.url) {
    NSURL *url = [NSURL URLWithString:self.image.url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self->_photo = [[UIImage alloc] initWithData:data];
    [self->_photo retain];
    return self->_photo;
  }

  return nil;
}

@end
