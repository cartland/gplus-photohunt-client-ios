//
//  FSHFriends.h
//  PhotoHunt
//
//  Created by Chris Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSHFriends : NSObject

@property (strong) NSArray* items;

- (id)initWithJson:(id)attributesArray;

@end
