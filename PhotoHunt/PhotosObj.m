//
//  PhotosObj.m
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import "PhotosObj.h"
#import "PhotoObj.h"

@implementation PhotosObj

@synthesize items = _items;

// Init array with JSON returned from AFNetworking
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
        
        PhotoObj *item = [[PhotoObj alloc] initWithJson:attributes];
        [mutableArray addObject:item];
    }
    _items = [NSArray arrayWithArray:mutableArray];
    
    return self;
}

@end
