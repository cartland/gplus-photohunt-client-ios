//
//  ImageViewController.h
//  PhotoHunt

#import <UIKit/UIKit.h>

// Display a view of an individual image.
@interface ImageViewController : UIViewController <
  UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollview;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                  url:(NSString *)url;

@end
