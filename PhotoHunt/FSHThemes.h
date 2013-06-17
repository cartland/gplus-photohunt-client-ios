//
//  FSHThemes.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

// Object to represent a list of themes in PhotoHunt.
@interface FSHThemes : GTLCollectionObject

@property (copy) NSString* startIndex;
@property (copy) NSString* count;
@property (copy) NSString* totalResults;
@property (strong) NSArray* items;

@end
