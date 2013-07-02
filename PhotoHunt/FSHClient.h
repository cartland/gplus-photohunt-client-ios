//
//  FSHClient.h
//  PhotoHunt
//
//  Created by Chris Cartland on 6/20/13.
//  Copyright (c) 2013 Google, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface FSHClient : AFHTTPClient

+ (FSHClient *)sharedClient;

@end