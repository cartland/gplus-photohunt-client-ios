//
//  FSHThemes.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/17/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "FSHThemes.h"
#import "FSHTheme.h"

@implementation FSHThemes

@synthesize items = _items;

// Init array of themes with JSON returned from AFNetworking
- (id)initWithJson:(id)attributesArray {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (![attributesArray isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[attributesArray count]];
    for (id attributes in attributesArray) {
        if (![attributes isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        FSHTheme *item = [[FSHTheme alloc] initWithJson:attributes];
        [mutableArray addObject:item];
    }
    _items = [NSArray arrayWithArray:mutableArray];
    
    return self;
}

@end
