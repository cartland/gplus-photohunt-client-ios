//
//  AboutViewController.h
//  PhotoHunt

#import "GAITrackedViewController.h"
#import <UIKit/UIKit.h>

// Displays an about screen including the version number.
@interface AboutViewController : GAITrackedViewController

@property (nonatomic, retain) IBOutlet UILabel *version;

@end
