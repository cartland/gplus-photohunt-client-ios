//
//  FSHTheme.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "GTLObject.h"

// Object to represent a PhotoHunt theme.
@interface FSHTheme : GTLObject

@property (assign) NSInteger identifier;
@property (copy) NSString *displayName;

@end
