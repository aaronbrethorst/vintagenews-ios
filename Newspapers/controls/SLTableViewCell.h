//
//  SLTableViewCell.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/23/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLTableViewCell : UITableViewCell
@property(strong,nonatomic) IBOutlet UIView *wrapperView;
+ (CGFloat)rowHeight;
+ (NSString *)cellIdentifier;
+ (id)cellForTableView:(UITableView *)tableView;
+ (id)cellForTableView:(UITableView *)tableView created:(void (^)(UITableViewCell* cell))createdBlock;
- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;
@end
