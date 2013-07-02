//
//  FSHPhoto.h
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSHPhoto : NSObject {
    // Local cached UIImage to represent the photo.
    UIImage *_photo;
}
@property (assign) NSInteger identifier;
@property (assign) NSInteger photoId;
@property (assign) NSInteger ownerUserId;
@property (assign) NSInteger themeId;
@property (assign) NSInteger numVotes;
@property (assign) BOOL voted;
@property (assign) NSInteger created;

@property (copy) NSString *ownerDisplayName;
@property (copy) NSString *ownerGooglePlusId;
@property (copy) NSString *ownerProfileUrl;
@property (copy) NSString *ownerProfilePhoto;
@property (copy) NSString *themeDisplayName;
@property (copy) NSString *fullsizeUrl;
@property (copy) NSString *thumbnailUrl;
@property (copy) NSString *voteCtaUrl;
@property (copy) NSString *photoContentUrl;

- (id)initWithJson:(NSDictionary *)attributes;
- (void)setPhoto:(UIImage *)in_photo;
- (UIImage *)photo;

@end
