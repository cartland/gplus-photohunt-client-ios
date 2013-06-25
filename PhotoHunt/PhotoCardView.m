//
//  PhotoCardView.m
//  PhotoHunt

#import "ImageCache.h"
#import "PhotoCardView.h"

// Photo placeholder string.
NSInteger const kPhotoPlaceholder = -201;
// URL used to call out to the Google+ app to link to a specific profile.
NSString * const kProfileURL  = @"gplus://app/profile/person?personId=g:%@";

@interface PhotoCardView() {
  BOOL canOpenGplusURL;
  UIImage *blankProfile;
}

@end

@implementation PhotoCardView

// Colours.
static const CGFloat kDisabledAlpha = 0.4;
static const CGFloat kFullAlpha = 1.0;
static const CGFloat kGreyBackgroundTone = 0.9;
static const CGFloat kGreyTextTone = 0.2;

// Layout.
static const CGFloat kButtonHeight = 35.0;
static const CGFloat kCardSize = 320.0;
static const CGFloat kDeleteWidth = 35.0;
static const CGFloat kDeleteHeight = 30.0;
static const CGFloat kMargin = 9.0;
static const CGFloat kNameWidth = 163.0;
static const NSInteger kPhotoHeight = 192;
static const CGFloat kPhotoMargin = 4.0;
static const NSInteger kPhotoWidth = 294;
static const NSInteger kProfileSize = 40.0;
static const CGFloat kPromoteWidth = 95.0;
static const NSInteger kSpinnerSize = 25;
static const CGFloat kVoteBgWidth = 82.0;
static const CGFloat kVotesOffset = 30.0;
static const CGFloat kVotesWidth = 60.0;
static const CGFloat kVoteWidth = 71.0;

+ (CGFloat) getHeight {
  return kCardSize;
}

+ (CGFloat) getWidth {
  return kCardSize;
}

+ (void)disableVoteButton:(UIButton *)vote {
  [vote setEnabled:NO];
  vote.alpha = kDisabledAlpha;
}

- (id)init {
  return [self initWithPhoto:nil forRow:0 withDelegate:nil useCache:nil];
}


-(id)initWithPhoto:(PhotoObj *)photo
            forRow:(NSInteger)row
      withDelegate:(id<PhotoCardViewDelegate>)delegate
          useCache:(ImageCache *)cache {
  self = [super initWithFrame:CGRectMake(0.0,
                                         0.0,
                                         [PhotoCardView getWidth],
                                         [PhotoCardView getHeight])];
  if (self) {
    self.delegate = delegate;
    self.cache = cache;
    [self setBackgroundColor:[UIColor colorWithRed:kGreyBackgroundTone
                                             green:kGreyBackgroundTone
                                              blue:kGreyBackgroundTone
                                             alpha:kFullAlpha]];
    NSString *dummyURL = [NSString stringWithFormat:kProfileURL, @"1"];
    canOpenGplusURL = [[UIApplication sharedApplication]
                       canOpenURL:[NSURL URLWithString:dummyURL]];
    [self setPhoto: photo forRow:row];
  }
  return self;
}

- (void)setPhoto:(PhotoObj *)photo forRow:(NSInteger)row {
  ProfileObj *curUser = [self.delegate currentUser];

  // Vote button.
  if (photo.identifier != kPhotoPlaceholder) {
    self.vote = [UIButton buttonWithType:UIButtonTypeCustom];
    self.vote.frame = CGRectMake(kMargin, kMargin, kVoteWidth, kButtonHeight);
    [self.vote setImage:[UIImage imageNamed:@"btn-vote"]
               forState:UIControlStateNormal];
    [self.vote.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.vote setTag:row];
    [self.vote addTarget:self.delegate
                  action:@selector(didTapVote:)
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.vote];

    if (curUser &&
       (photo.voted
           || photo.ownerUserId == curUser.identifier
           || ![self.delegate isLatestTheme])) {
      [PhotoCardView disableVoteButton:self.vote];
    }
  }

  // Vote label.
  if (photo.ownerUserId != kPhotoPlaceholder) {
    UIImageView *voteBg = [[UIImageView alloc]
                               initWithImage:[UIImage imageNamed:@"bubble"]];
    [voteBg setFrame:CGRectMake(kVoteWidth + kMargin,
                                kMargin,
                                kVoteBgWidth,
                                kButtonHeight)];
    [self addSubview:voteBg];

    UILabel *voteLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(kVoteWidth + kVotesOffset,
                                                      kMargin,
                                                      kVotesWidth,
                                                      kButtonHeight)];
    [voteLabel setBackgroundColor:[UIColor clearColor]];
    [voteLabel setText:[NSString stringWithFormat:@"+%d", photo.numVotes]];
    [voteLabel setTextColor:[UIColor redColor]];
    [self addSubview:voteLabel];
  }

  // Main photo.
  UIButton *photoContainer = [[UIButton alloc]
                               initWithFrame:CGRectMake(
                                   kMargin,
                                   51.0,
                                   kPhotoWidth + (2 * kPhotoMargin),
                                   kPhotoHeight + (2 * kPhotoMargin))];
  [photoContainer setBackgroundColor:[UIColor whiteColor]];
  [photoContainer addTarget:self.delegate
                     action:@selector(didTapImage:)
           forControlEvents:UIControlEventTouchUpInside];
  [photoContainer setTag:row];
  UIImageView *photoImage = [[UIImageView alloc]
                                initWithFrame:CGRectMake(kPhotoMargin,
                                                         kPhotoMargin,
                                                         kPhotoWidth,
                                                         kPhotoHeight)];

  [photoImage setContentMode:UIViewContentModeScaleAspectFill];
  [photoImage setClipsToBounds:YES];
  [photoContainer addSubview:photoImage];
  [self addSubview:photoContainer];

  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  spinner.frame = CGRectMake(
      round(([PhotoCardView getWidth] - kSpinnerSize) / 2),
      round(([PhotoCardView getHeight] - kSpinnerSize) / 2),
      kSpinnerSize,
      kSpinnerSize);
  [spinner startAnimating];
  [self addSubview:spinner];

  if (photo.identifier == kPhotoPlaceholder) {
    [photoImage setImage:photo.photo];
    [photoImage setAlpha:kDisabledAlpha];
  } else {
    // Server-side resize image to 588x384 (-w-h) with smart cropping (-p).
    NSString *photoUrl = [self.cache getResizeUrl:photo.fullsizeUrl
                                         forWidth:kPhotoWidth
                                        andHeight:kPhotoHeight];
    [self.cache setImageView:photoImage forURL:photoUrl withSpinner:spinner];
  }


  if (photo.ownerUserId == curUser.identifier &&
      photo.identifier != kPhotoPlaceholder) {
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
    delete.frame = CGRectMake(kCardSize - kMargin - kDeleteWidth,
                              kMargin,
                              kDeleteWidth,
                              kDeleteHeight);
    [delete setImage:[UIImage imageNamed:@"bin"]
            forState:UIControlStateNormal];
    [delete.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [delete setBackgroundColor:[UIColor clearColor]];
    [delete setTag:row];
    [delete addTarget:self.delegate
               action:@selector(didTapDelete:)
     forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:delete];
  }

  // User profile.
  if (photo.ownerProfilePhoto) {
    CGRect frame = CGRectMake(kMargin,
                              kPhotoHeight +
                              (kPhotoMargin * 2) +
                              (kMargin * 3) +
                              kButtonHeight,
                              kProfileSize,
                              kProfileSize);

    UIImageView *profileImage = [[UIImageView alloc] initWithFrame:frame];
    NSString *profileUrl = [self.cache getResizeUrl:photo.ownerProfilePhoto
                                           forWidth:kProfileSize
                                          andHeight:kProfileSize];
    [self.cache setImageView:profileImage forURL:profileUrl withSpinner:nil];
    [profileImage setContentMode:UIViewContentModeScaleAspectFill];
    [profileImage setClipsToBounds:YES];
    [self addSubview:profileImage];

    if (canOpenGplusURL) {
      UIButton *imHolder = [UIButton buttonWithType:UIButtonTypeCustom];
      [imHolder setFrame:frame];
      [imHolder setTag:row];
      [imHolder addTarget:self.delegate
                   action:@selector(didTapAuthor:)
         forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:imHolder];
    }
  }

  // Profile display name.
  if (photo.ownerDisplayName) {
    UILabel* nameLabel = [[UILabel alloc]
                           initWithFrame:CGRectMake((kMargin *2) + kProfileSize,
                                                    kPhotoHeight +
                                                    (kPhotoMargin * 2) +
                                                    (kMargin * 3) +
                                                    kButtonHeight,
                                                    kNameWidth,
                                                    kProfileSize)];
    [nameLabel setText:photo.ownerDisplayName];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setTextColor:[UIColor colorWithRed:kGreyTextTone
                                            green:kGreyTextTone
                                             blue:kGreyTextTone
                                            alpha:kFullAlpha]];
    [self addSubview:nameLabel];
  }

  // Promote button.
  if (photo.identifier != kPhotoPlaceholder) {
    UIButton *promote = [UIButton buttonWithType:UIButtonTypeCustom];
    promote.frame = CGRectMake( kMargin +
                                    kProfileSize +
                                    kNameWidth +
                                    kPhotoMargin,
                                    kPhotoHeight +
                                    (kPhotoMargin * 2) +
                                    (kMargin * 3) +
                                    kButtonHeight,
                                    kPromoteWidth,
                                    kButtonHeight);
    [promote setImage:[UIImage imageNamed:@"btn-promote"]
             forState:UIControlStateNormal];
    [promote setTag:row];
    [promote addTarget:self.delegate
                action:@selector(didTapPromote:)
      forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:promote];
  }
}

-(void)clearSubviews {
  UIView *subview;
  while ((subview = [[self subviews] lastObject])) {
    [subview removeFromSuperview];
  }
}

@end
