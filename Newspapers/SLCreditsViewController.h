//
//  SLCreditsViewController.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/24/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLCreditsViewController : UIViewController <UIWebViewDelegate>
@property(strong,nonatomic) IBOutlet UIWebView *webView;
@end
