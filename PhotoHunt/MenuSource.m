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
//  MenuSource.m
//  PhotoHunt

#import "MenuSource.h"
#import <MessageUI/MessageUI.h>

@interface MenuSource (){
  NSArray *menuData;
}

@end;

static const NSString *kThemeTitle = @"Change Theme";
static const NSString *kProfileTitle = @"Your Activity";
static const NSString *kFeedbackTitle = @"Send Feedback";
static const NSString *kInviteTitle = @"Invite Friends";
static const NSString *kRefreshTitle = @"Refresh";
static const NSString *kSigninWebTitle = @"Sign In Using Web";
static const NSString *kSignoutTitle = @"Sign Out";
static const NSString *kAboutTitle = @"About";
static const NSString *kDisconnectTitle = @"Disconnect";

static NSString * const kGmailURL = @"googlegmail:/co";

@implementation MenuSource

- (id)init {
  return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<MenuSourceDelegate>)delegate {
  self = [super init];
  if (self) {
    self.delegate = delegate;
    [self reloadMenu];
  }
  return self;
}


- (void)reloadMenu {

  NSMutableArray *menu = [NSMutableArray array];

  if ([self.delegate currentTheme]) {
    [menu addObject:kThemeTitle];
  }

  if ([self.delegate currentUser]) {
    [menu addObject:kProfileTitle];
    [menu addObject:kInviteTitle];
    [menu addObject:kSignoutTitle];
    [menu addObject:kDisconnectTitle];
  } else {
    [menu addObject:kSigninWebTitle];
  }

  [menu addObject:kRefreshTitle];
  [menu addObject:kAboutTitle];

  if ([MFMailComposeViewController canSendMail]) {
    [menu addObject:kFeedbackTitle];
  } else if([[UIApplication sharedApplication]
                canOpenURL:[NSURL URLWithString:kGmailURL]]) {
    [menu addObject:kFeedbackTitle];
  }

  menuData = [NSArray arrayWithArray:menu];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [menuData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  NSString *cellIdentifier = @"MENU_CELL";

  UITableViewCell *cell = [tableView
                           dequeueReusableCellWithIdentifier:cellIdentifier];

  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier];
  }

  [cell.textLabel setText:[menuData objectAtIndex:[indexPath row]]];
  [cell.textLabel setTextColor:[UIColor whiteColor]];

  return cell;
}

- (void)tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.delegate hideMenu];
  NSString *selected = [menuData objectAtIndex:[indexPath row]];

  if ([selected isEqual:kThemeTitle]) {
    [self.delegate didTapChangeTheme];
  } else if ([selected isEqual:kFeedbackTitle]){
    [self.delegate didTapSendFeedback];
  } else if ([selected isEqual:kSignoutTitle]) {
    [self.delegate logout];
  } else if ([selected isEqual:kAboutTitle]) {
    [self.delegate didTapAbout];
  } else if ([selected isEqual:kInviteTitle]) {
    [self.delegate didTapInvite];
  } else if ([selected isEqual:kRefreshTitle]) {
    [self.delegate didTapRefresh];
  } else if ([selected isEqual:kProfileTitle]) {
    [self.delegate didTapProfile];
  } else if ([selected isEqual:kSigninWebTitle]) {
    [self.delegate didTapSignInWeb];
  } else if ([selected isEqual:kDisconnectTitle]) {
    [self.delegate didTapDisconnect];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
