//
//  ThemesObj.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/17/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "ThemesObj.h"

@implementation ThemesObj

@synthesize items = _items;

- (id)initWithItems:(NSArray *)items {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _items = items;
    
    return self;
}

@end
