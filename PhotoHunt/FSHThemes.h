//
//  FSHThemes.h
//  PhotoHunt
//
//  Created by Chris Cartland on 6/17/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSHThemes : NSObject

@property (strong) NSArray* items;

- (id)initWithJson:(id)attributesArray;

@end
