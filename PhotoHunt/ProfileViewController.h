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

@property (nonatomic, strong) IBOutlet UITableView *activitiesView;
@property (nonatomic, strong) IBOutlet UIScrollView *friendView;
@property (nonatomic, strong) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activitiesSpinner;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *friendsSpinner;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *userSpinner;
@property (nonatomic, strong) FSHProfile *user;
@property (nonatomic, strong) FSHFriends *friends;
@property (nonatomic, strong) GTLPlusMomentsFeed *activities;
@property (nonatomic, strong) GTLServicePlus *plusService;

@end
