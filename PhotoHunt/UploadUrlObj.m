//
//  UploadUrlObj.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "UploadUrlObj.h"

@implementation UploadUrlObj
@synthesize url = _url;

- (id)initWithJson:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _url = [attributes valueForKeyPath:@"url"];
    
    return self;
}
@end
