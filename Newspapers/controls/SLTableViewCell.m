//
//  SLTableViewCell.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/23/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLTableViewCell.h"

@implementation SLTableViewCell

+ (CGFloat)rowHeight
{
    return 44.f;
}

+ (NSString *)cellIdentifier
{
    return NSStringFromClass([self class]);
}

+ (id)cellForTableView:(UITableView *)tableView
{
    return [self cellForTableView:tableView created:nil];
}

+ (id)cellForTableView:(UITableView *)tableView created:(void (^)(UITableViewCell* cell))createdBlock
{
    NSString *cellID = [self cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[self alloc] initWithReuseIdentifier:cellID];
        
        if (createdBlock) createdBlock(cell);
    }
    return cell;
}

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.clipsToBounds = YES;
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self.wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.wrapperView];
    }
    return self;
}

@end
