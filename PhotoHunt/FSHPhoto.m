//
//  FSHPhoto.m
//  PhotoHunt

#import "FSHPhoto.h"

@implementation FSHPhoto

@dynamic identifier, photoId, ownerUserId, themeId, numVotes, voted,
    created, ownerDisplayName, ownerGooglePlusId, ownerProfilePhoto,
    ownerProfileUrl, themeDisplayName, fullsizeUrl, thumbnailUrl, voteCtaUrl,
    photoContentUrl;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map = [NSDictionary dictionaryWithObject:@"id"
                                                  forKey:@"identifier"];
  return map;
}

+ (void)load {
  [self registerObjectClassForKind:@"photohunt#photo"];
}

- (void)setPhoto:(UIImage *)in_photo {
  self->_photo = in_photo;
}

- (UIImage *)photo {
  if (self->_photo) {
    return self->_photo;
  } else if (self.fullsizeUrl) {
    NSURL *url = [NSURL URLWithString:self.fullsizeUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self->_photo = [[UIImage alloc] initWithData:data];
    return self->_photo;
  }

  return nil;
}

@end
