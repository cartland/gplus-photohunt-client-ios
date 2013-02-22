//
//  FSHPerson.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import "GTLObject.h"

// Object to represent a PhotoHunt profile.
@interface FSHProfile : GTLObject

@property (copy) NSString *identifier;
@property (copy) NSString *displayName;
@property (copy) NSString *profilePhotoUrl;
@property (copy) NSString *googlePlusId;
@property (copy) NSString *googlePlusProfileUrl;

@end
