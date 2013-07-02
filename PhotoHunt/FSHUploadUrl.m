//
//  FSHUploadUrl.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "FSHUploadUrl.h"

@implementation FSHUploadUrl
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
