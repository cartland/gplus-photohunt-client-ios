//
//  FSHImage.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "GTLObject.h"

// Object to represent an individual image within PhotoHunt.
@interface FSHImage : GTLObject

@property (copy) NSString* url;
@property (copy) NSString* width;
@property (copy) NSString* height;

@end
