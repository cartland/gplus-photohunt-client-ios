//
//  FSHUploadUrl.h
//  PhotoHunt
//
//  Created by Cartland Cartland on 6/18/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSHUploadUrl : NSObject

@property (readonly) NSString *url;

- (id)initWithJson:(NSDictionary *)attributes;

@end
