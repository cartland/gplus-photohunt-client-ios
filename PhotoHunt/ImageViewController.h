//
//  ImageViewController.h
//  PhotoHunt

#import <UIKit/UIKit.h>

// Display a view of an individual image.
@interface ImageViewController : UIViewController <
  UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollview;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                  url:(NSString *)url;

@end
