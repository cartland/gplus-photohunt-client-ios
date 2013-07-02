//
//  FSHTheme.m
//  PhotoHunt
//
//  Created by Chris Cartland on 6/17/13.
//  Copyright (c) 2013 Ian Barber. All rights reserved.
//

#import "FSHTheme.h"

@implementation FSHTheme    
@synthesize identifier = _identifier;
@synthesize displayName = _displayName;

- (id)initWithJson:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _identifier = [[attributes valueForKeyPath:@"id"] integerValue];
    _displayName = [attributes valueForKeyPath:@"displayName"];
        
    return self;
}

@end