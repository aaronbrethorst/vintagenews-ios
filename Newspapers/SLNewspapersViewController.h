//
//  SLMasterViewController.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLNewspaperDetailsViewController;

@interface SLNewspapersViewController : UITableViewController <UISearchDisplayDelegate>

@property(strong,nonatomic) IBOutlet UISearchBar *searchBar;
@property(strong, nonatomic) SLNewspaperDetailsViewController *detailViewController;

@end
