//
//  ActivityView.m
//  PhotoHunt

#import "ActivityView.h"
#import "AppDelegate.h"

@implementation ActivityView

static NSString *kAddActivity = @"http://schemas.google.com/AddActivity";

- (id)init {
  return [self initWithActivity:nil useCache:nil];
}

- (void)dealloc {
  [_activity release];
  [super dealloc];
}

- (id)initWithActivity:(GTLPlusMoment *)activity
              useCache:(ImageCache *)cache {
  self = [super initWithFrame:CGRectMake(0.0,
                                         0.0,
                                         320.0,
                                         44.0)];
  if (self) {
    [self setBackgroundColor:[UIColor colorWithRed:0.9
                                             green:0.9
                                              blue:0.9
                                             alpha:1.0]];

    NSString *action = [activity.type isEqualToString:kAddActivity]
                           ? @"Uploaded" : @"Voted on";

    CGRect labelFrame = CGRectMake(90.0, 0.0, 230.0, 44.0);
    UILabel *label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
    NSString *target = [activity.target.name lowercaseString];
    [label setText:[NSString stringWithFormat:@"%@ %@", action, target]];
    [label setFont:[UIFont fontWithName:@"Arial" size:14.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [self addSubview:label];

    CGRect imageFrame = CGRectMake(0.0, 0.0, 80.0, 44.0);
    UIImageView *im = [[[UIImageView alloc] initWithFrame:imageFrame]
                          autorelease];
    [im setContentMode:UIViewContentModeScaleAspectFill];
    [im setClipsToBounds:YES];
    [self addSubview:im];
    NSString *url = [cache getResizeUrl:activity.target.image
                               forWidth:80
                              andHeight:44];
    [cache setImageView:im forURL:url withSpinner:nil];
  }
  return self;
}

@end
