//
//  ImageViewController.m
//  PhotoHunt

#import "ImageViewController.h"
#import "AppDelegate.h"

@interface ImageViewController()  {
  NSString *url;
}

@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil url:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                  url:(NSString *)imageUrl {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    url = [imageUrl copy];
  }
  return self;
}

- (void)dealloc {
  [_imageView release];
  [_scrollview release];
  [_spinner release];
  [url release];
  [super dealloc];
}

- (void)viewDidLoad {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                             delegate];
  [appDelegate.service fetchImage:url
                completionHandler:^(NSData *retrievedData, NSError *error) {
                    [self.spinner stopAnimating];
                    UIImage *pic = [[[UIImage alloc] initWithData:retrievedData]
                                       autorelease];
                    self.imageView = [[[UIImageView alloc]
                                         initWithImage:pic] autorelease];
                    [self.scrollview addSubview:self.imageView];
                    [self.scrollview setDelegate:self];
                    [self.scrollview setContentSize:pic.size];
                    [self.scrollview setClipsToBounds:YES];

                    // Calculate reasonable zoom levels based on the
                    // scrollview width and height
                    CGFloat minZoom = (self.scrollview.frame.size.width
                                          / pic.size.width);
                    CGFloat startZoom = (self.scrollview.frame.size.height
                                            / pic.size.height);
                    if (minZoom > startZoom) {
                      startZoom = minZoom;
                    }

                    // Clip to 1 if the image is small.
                    if (minZoom > 1) {
                      minZoom = 1.0;
                    }
                    if (startZoom > 1) {
                      startZoom = 1.0;
                    }

                    [self.scrollview setMinimumZoomScale:minZoom];
                    [self.scrollview setMaximumZoomScale:3.0];
                    [self.scrollview setZoomScale:startZoom];
                }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.imageView;
}


@end
