//
//  ProfileViewController.h
//  PhotoHunt

#import "FSHFriends.h"
#import "FSHProfile.h"
#import "GAITrackedViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <UIKit/UIKit.h>

@class GTLServicePlus;

// Display a view containing the profile and activities of the signed in user.
@interface ProfileViewController : GAITrackedViewController <
    UITableViewDataSource,
    UITableViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                 user:(FSHProfile *)user;

@property (nonatomic, retain) IBOutlet UITableView *activitiesView;
@property (nonatomic, retain) IBOutlet UIScrollView *friendView;
@property (nonatomic, retain) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activitiesSpinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *friendsSpinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *userSpinner;
@property (nonatomic, retain) FSHProfile *user;
@property (nonatomic, retain) FSHFriends *friends;
@property (nonatomic, retain) GTLPlusMomentsFeed *activities;
@property (nonatomic, retain) GTLServicePlus *plusService;

@end
