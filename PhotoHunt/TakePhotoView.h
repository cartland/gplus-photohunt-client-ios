//
//  TakePhotoView.h
//  PhotoHunt

#import "FSHProfile.h"
#import <UIKit/UIKit.h>

// Delegate for the take photo view, used to trigger the photo taking routine
// and check the state of the user.
@protocol TakePhotoViewDelegate <NSObject>

// Retrieve the currently signed in user, or nil if not logged in.
- (FSHProfile *)currentUser;

// Callback called to trigger photo selection routine.
- (void)didTapPhoto;

@end

// A view to display the take photo or sign in graphic, and to handle responses
// automatically.
@interface TakePhotoView : UIView

// Get the height of the view.
+ (CGFloat) getHeight;

// Get the width of the view.
+ (CGFloat) getWidth;

@property (nonatomic, weak) id<TakePhotoViewDelegate> delegate;

// Initise the object with the given delegate.
- (id)initWithDelegate:(id<TakePhotoViewDelegate>)delegate;

@end
