//
//  FSHPhotos.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "GTLObject.h"

// Object to represent a list of PhotoHunt photos.
@interface FSHPhotos : GTLCollectionObject

@property (copy) NSString* startIndex;
@property (copy) NSString* count;
@property (copy) NSString* totalResults;
@property (retain) NSArray* items;

@end
