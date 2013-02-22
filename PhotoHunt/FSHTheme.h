//
//  FSHTheme.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "GTLObject.h"

// Object to represent a PhotoHunt theme.
@interface FSHTheme : GTLObject

@property (copy) NSString *identifier;
@property (copy) NSString *title;

@end
