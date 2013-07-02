/*
 *
 * Copyright 2013 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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


- (void)viewDidLoad {
    UIImage *pic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    self.imageView = [[UIImageView alloc] initWithImage:pic];
    [self.view addSubview:self.imageView];
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
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.imageView;
}


@end
