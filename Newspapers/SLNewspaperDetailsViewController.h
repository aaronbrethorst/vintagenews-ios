//
//  SLDetailViewController.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLNewspapersDataSource.h"

@interface SLNewspaperDetailsViewController : UITableViewController <UISplitViewControllerDelegate>
@property (strong, nonatomic) SLNewspaper *newspaper;
@end
