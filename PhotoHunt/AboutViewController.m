//
//  AboutViewController.m
//  PhotoHunt

#import "AboutViewController.h"
#import "AppDelegate.h"

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.trackedViewName = @"viewAbout";
  }
  return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]
                                             delegate];
  self.version.text = [NSString stringWithFormat:@"version %d",
                           appDelegate.version];
}

@end
