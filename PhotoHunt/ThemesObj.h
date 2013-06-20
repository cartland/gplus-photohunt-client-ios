//
//  ThemesObj.h
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/17/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemesObj : NSObject

@property (strong) NSArray* items;

- (id)initWithJson:(id)JSON;

- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end
