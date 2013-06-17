//
//  StreamSource.m
//  PhotoHunt

#import "FSHPhoto.h"
#import "StreamSource.h"

@implementation StreamSource

- (id)init {
  return [self initWithDelegate:nil useCache:nil];
}

- (id)initWithDelegate:(id<StreamSourceDelegate>)delegate
                useCache:(ImageCache *)cache {
  self = [super init];
  if (self) {
    self.delegate = delegate;
    self.cache = cache;
  }
  return self;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if ([self.delegate canTakePhoto]) {
    // If we're in the latest theme, allow a slow for the take photo button.
    return 3;
  } else {
    // Otherwise, just have the pictures.
    return 2;
  }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  // If we are in the button section, just return the one.
  if ([self.delegate canTakePhoto]) {
    if (section == 0) {
      return 1;
    }
  } else {
    section += 1;
  }

  // If we are in the friends section use friendPhotos.
  if (section == 1){
    if (![self.delegate friendPhotos]) {
      return 0;
    }
    return [[[self.delegate friendPhotos] items] count];
  }

  if (![self.delegate allUserPhotos]) {
    return 0;
  }
  return [[[self.delegate allUserPhotos] items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FSHPhoto *photo = nil;
  NSString *cellIdentifier;
  NSInteger row = [indexPath row];
  NSInteger section = [indexPath section];
  NSInteger tagOffset = 0;

  if ((section == 0 && ![self.delegate canTakePhoto]) ||
      (section == 1 && [self.delegate canTakePhoto])) {
    photo = [[[self.delegate friendPhotos] items] objectAtIndex:row];
    tagOffset = row;
  } else if (section > 0) {
    photo = [[[self.delegate allUserPhotos] items] objectAtIndex:row];
    tagOffset = [[[self.delegate friendPhotos] items] count] + row;
  }

  if (photo) {
    cellIdentifier = [NSString stringWithFormat:@"%d-photoCard",
                          [self.delegate counter]];
  } else {
    cellIdentifier = [NSString stringWithFormat:@"%d-headerCell",
                          [self.delegate counter]];
  }

  UITableViewCell *cell = [tableView
                           dequeueReusableCellWithIdentifier:cellIdentifier];

  if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellIdentifier];

    if ([self.delegate canTakePhoto] && section == 0) {
      TakePhotoView *button = [[TakePhotoView alloc]
                               initWithDelegate:[self.delegate cardDelegate]];
      [cell.contentView addSubview:button];
    } else if (photo) {
      PhotoCardView *card = [[PhotoCardView alloc] initWithPhoto:photo
                                      forRow:tagOffset
                                withDelegate:[self.delegate cardDelegate]
                                    useCache:self.cache];
      [card setTag:tagOffset];
      [cell.contentView addSubview:card];
    }
  } else if (photo) {
    [[[cell.contentView subviews] lastObject] clearSubviews];
    [[[cell.contentView subviews] lastObject] setPhoto:photo
                                                forRow:tagOffset];
  }

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
  heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self.delegate canTakePhoto] && [indexPath section] == 0) {
    // Return a fixed height for the button.
    return [TakePhotoView getHeight];
  }
  return [PhotoCardView getHeight];
}

- (BOOL)haveHeaders {
  return [self.delegate currentTheme] &&
         [self.delegate currentUser] &&
         [[[self.delegate friendPhotos] items] count] > 0;
}

- (CGFloat)tableView:(UITableView *)tableView
  heightForHeaderInSection:(NSInteger)section {
  if (![self haveHeaders] ) {
      return 0.0;
  }
  if (section == 0 && [self.delegate canTakePhoto]) {
    return 0.0;
  }
  return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView
  viewForHeaderInSection:(NSInteger)section {
  if (![self haveHeaders]) {
      return nil;
  }
  if ([self.delegate canTakePhoto]) {
    if (section == 0) {
      return nil;
    }
  } else {
    section += 1;
  }

  // create the parent view that will hold header Label.
  UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                 0.0,
                                                                 320.0,
                                                                 80.0)];
  [customView setBackgroundColor:[UIColor colorWithRed:0.95
                                                 green:0.95
                                                  blue:0.95
                                                 alpha:1.0]];

  // create the button object.
  UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0,
                                                                    0.0,
                                                                    300.0,
                                                                    44.0)];
  headerLabel.backgroundColor = [UIColor clearColor];
  headerLabel.opaque = NO;
  headerLabel.textColor = [UIColor blackColor];
  headerLabel.highlightedTextColor = [UIColor whiteColor];
  headerLabel.font = [UIFont fontWithName:@"Arial-Bold" size:17];

  if (section == 1) {
    headerLabel.text = @"Photos By Friends";
  } else if (section == 2) {
    headerLabel.text = @"Photos By Everyone";
  }

  [customView addSubview:headerLabel];

  return customView;
}

@end
