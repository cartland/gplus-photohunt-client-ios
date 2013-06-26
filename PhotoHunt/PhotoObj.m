//
//  PhotoObj.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "PhotoObj.h"

@implementation PhotoObj
@synthesize identifier = _identifier;
@synthesize photoId = _photoId;
@synthesize ownerUserId = _ownerUserId;
@synthesize themeId = _themeId;
@synthesize numVotes = _numVotes;
@synthesize voted = _voted;
@synthesize created = _created;

@synthesize ownerDisplayName = _ownerDisplayName;
@synthesize ownerGooglePlusId = _ownerGooglePlusId;
@synthesize ownerProfileUrl = _ownerProfileUrl;
@synthesize ownerProfilePhoto = _ownerProfilePhoto;
@synthesize themeDisplayName = _themeDisplayName;
@synthesize fullsizeUrl = _fullsizeUrl;
@synthesize thumbnailUrl = _thumbnailUrl;
@synthesize voteCtaUrl = _voteCtaUrl;
@synthesize photoContentUrl = _photoContentUrl;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _identifier = [[attributes valueForKeyPath:@"id"] integerValue];
    _photoId = [[attributes valueForKeyPath:@"id"] integerValue];
    _ownerUserId = [[attributes valueForKeyPath:@"ownerUserId"] integerValue];
    _themeId = [[attributes valueForKeyPath:@"themeId"] integerValue];
    _numVotes = [[attributes valueForKeyPath:@"numVotes"] integerValue];
    _voted = [[attributes valueForKeyPath:@"voted"] boolValue];
    _created = [[attributes valueForKeyPath:@"created"] integerValue];
    _ownerDisplayName = [attributes valueForKeyPath:@"ownerDisplayName"];
    _themeDisplayName = [attributes valueForKeyPath:@"themedisplayName"];
    _fullsizeUrl = [attributes valueForKeyPath:@"fullsizeUrl"];
    _thumbnailUrl = [attributes valueForKeyPath:@"thumbnailUrl"];
    _voteCtaUrl = [attributes valueForKeyPath:@"voteCtaUrl"];
    _photoContentUrl = [attributes valueForKeyPath:@"photoContentUrl"];
    
    return self;
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
