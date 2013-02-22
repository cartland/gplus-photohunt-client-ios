//
//  TakePhotoView.m
//  PhotoHunt

#import "GPPSignInButton.h"
#import "TakePhotoView.h"

@implementation TakePhotoView

static const CGFloat kHeight = 80.0;
static const CGFloat kWidth = 320.0;

+ (CGFloat)getHeight {
    return kHeight;
}

+ (CGFloat)getWidth {
    return kWidth;
}

- (id)init {
  return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<TakePhotoViewDelegate>)delegate {
  CGRect frame = CGRectMake(0.0, 0.0, kWidth, kHeight);
  self = [super initWithFrame:frame];
  if (self) {
    self.delegate = delegate;
    if (![self.delegate currentUser]) {
      GPPSignInButton *signInButton = [[[GPPSignInButton alloc]
                                          init]
                                          autorelease];
      [signInButton setStyle:kGPPSignInButtonStyleWide];
      [signInButton setColorScheme:kGPPSignInButtonColorSchemeLight];
      CGFloat x = roundf((320.0 - signInButton.frame.size.width) / 2.0);
      CGFloat y = roundf((80.0 - signInButton.frame.size.height) / 2.0);
      [signInButton setFrame:CGRectMake(x,
                                        y,
                                        signInButton.frame.size.width,
                                        signInButton.frame.size.height)];
      [self addSubview:signInButton];
      [self setBackgroundColor:[UIColor colorWithRed:0.2
                                               green:0.2
                                                blue:0.2
                                               alpha:1.0]];
    } else {
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100.0,
                                                                 20.0,
                                                                 190.0,
                                                                 40.0)];
      [label setText:@"Snap Today's Theme"];
      [label setFont:[UIFont fontWithName:@"Arial" size:17.0]];
      [label setBackgroundColor:[UIColor clearColor]];

      UIImage *image = [UIImage imageNamed:@"upload.png"];

      UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
      [button setFrame:frame];
      [button setImage:image forState:UIControlStateNormal];
      [button addTarget:self.delegate
                    action:@selector(didTapPhoto)
          forControlEvents:UIControlEventTouchUpInside];

      [self addSubview:button];
      [self addSubview:label];
      [label release];
    }
  }
  return self;
}

@end
