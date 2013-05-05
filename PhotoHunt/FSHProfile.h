//
//  FSHPerson.h
//  PhotoHunt

#import <Foundation/Foundation.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

// Object to represent a PhotoHunt profile.
@interface FSHProfile : GTLObject

@property (assign) NSInteger identifier;
@property (copy) NSString *googleDisplayName;
@property (copy) NSString *googlePublicProfilePhotoUrl;
@property (copy) NSString *googleUserId;
@property (copy) NSString *googlePlusProfileUrl;

@end
