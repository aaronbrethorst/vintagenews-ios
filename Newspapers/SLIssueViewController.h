//
//  SLIssueViewController.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLNewspaperIssue.h"

@interface SLIssueViewController : UIViewController
@property(strong) SLNewspaperIssue *issue;
@property(nonatomic,strong) IBOutlet UIWebView *webView;
@end
