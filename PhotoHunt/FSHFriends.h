//
//  FSHFriends.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

// Object to represent a list of friends (FSHProfile) in PhotoHunt.
@interface FSHFriends : GTLCollectionObject

@property (copy) NSString* startIndex;
@property (copy) NSString* count;
@property (copy) NSString* totalResults;
@property (strong) NSArray* items;

@end
