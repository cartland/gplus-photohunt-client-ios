//
//  FSHTheme.h
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/17/13.
//  Copyright (c) 2013 Ian Barber. All rights reserved.
//

@interface FSHTheme : NSObject

@property (readonly) NSUInteger identifier;
@property (readonly) NSString *displayName;

- (id)initWithJson:(NSDictionary *)attributes;

@end
