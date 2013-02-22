//
//  FSHPhoto.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "FSHImage.h"
#import "FSHProfile.h"
#import "FSHTheme.h"
#import "GTLObject.h"

// Object to represent a PhotoHunt photo.
@interface FSHPhoto : GTLObject {
  // Local cached UIImage to represent the photo.
  UIImage *_photo;
}

@property (copy) NSString *identifier;
@property (copy) NSString *url;
@property (copy) NSString *votes;
@property (copy) NSString *dateCreated;
@property (retain) FSHProfile *author;
@property (retain) FSHImage *image;
@property (retain) FSHImage *thumbnail;
@property (retain) FSHTheme *theme;
// If user has voted, will be a string timestamp, e.g. 1355422604552.
@property (copy) NSString *voted;

- (void)setPhoto:(UIImage *)in_photo;
- (UIImage *)photo;

@end
