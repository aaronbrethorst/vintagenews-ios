//
//  SLIssueViewController.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLIssueViewController.h"
#import "SLPDFLoader.h"

@interface SLIssueViewController () <ActionSheetCustomPickerDelegate>
@property NSInteger currentPageIndex;
@property(strong) UIBarButtonItem *pagePickerButton;
@property(strong) UIBarButtonItem *previousPageButton;
@property(strong) UIBarButtonItem *nextPageButton;
@end

@implementation SLIssueViewController

- (id)init
{
    self = [super initWithNibName:@"SLIssueViewController" bundle:nil];
    if (self)
    {
        [self addObserver:self forKeyPath:@"currentPageIndex" options:0 context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentPageIndex"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self)
    {
        if ([keyPath isEqual:@"currentPageIndex"])
        {
            [self loadNewPDF];

            self.previousPageButton.enabled = self.currentPageIndex > 0;
            self.nextPageButton.enabled = self.currentPageIndex < self.issue.pdfURLs.count - 1;

            self.pagePickerButton.title = [self titleForPagePicker];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureTitle];

    [self configureDeviceBehavior];

    SLIssueViewController *weakSelf = self;
    [self.issue synchronizeData:^{
        [weakSelf configureView];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[GAI sharedInstance] defaultTracker] sendView:NSStringFromClass([self class])];
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Issue"
                                                      withAction:@"View"
                                                       withLabel:self.issue.dateIssued.description
                                                       withValue:@(1)];
}

- (void)configureView
{
    self.currentPageIndex = 0;

    self.pagePickerButton = [[UIBarButtonItem alloc] initWithTitle:self.titleForPagePicker
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(showPagePickerPopup)];

    self.previousPageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                            target:self
                                                                            action:@selector(previousPage)];

    self.nextPageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                            target:self
                                                                            action:@selector(nextPage)];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.navigationItem.rightBarButtonItems = @[self.nextPageButton, self.previousPageButton, self.pagePickerButton];
    }
    else
    {
        self.toolbarItems = @[self.pagePickerButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],self.previousPageButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil],self.nextPageButton];
        self.navigationController.toolbarHidden = NO;
    }
}

#pragma mark - Actions

- (void)showPagePickerPopup
{
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    for (int i=0; i<self.issue.pdfURLs.count; i++)
    {
        [pages addObject:[NSString stringWithFormat:NSLocalizedString(@"Page %d", @""), i+1]];
    }
    
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Choose a Page", @"")
                                            rows:pages
                                initialSelection:self.currentPageIndex
                                          target:self
                                   successAction:@selector(pageSelected:element:)
                                    cancelAction:@selector(actionPickerCancelled:)
                                          origin:self.pagePickerButton];
}

- (void)pageSelected:(NSNumber*)pageNumber element:(id)element
{
    self.currentPageIndex = pageNumber.integerValue;
}

- (void)previousPage
{
    if (self.currentPageIndex > 0)
    {
        self.currentPageIndex = self.currentPageIndex - 1;
    }
}

- (void)nextPage
{
    if (self.currentPageIndex < self.issue.pdfURLs.count - 1)
    {
        self.currentPageIndex = self.currentPageIndex + 1;
    }
}

#pragma mark - UIPickerViewDataSource/UIPickerViewDelegate

// note: these don't seem to actually be used by the ActionPicker control, but it still requires them. boo.

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"You shouldn't be able to see this";
}


#pragma mark - Private

- (void)loadNewPDF
{
    [SVProgressHUD show];
    
    SLPDFLoader *loader = [[SLPDFLoader alloc] init];
    [loader downloadPDF:self.issue.pdfURLs[self.currentPageIndex]
        progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {

            if (totalBytesExpectedToRead > 0)
            {
                CGFloat progress = ((double)totalBytesRead) / ((double)totalBytesExpectedToRead);
                [SVProgressHUD showProgress:progress];
            }

        } success:^(AFHTTPRequestOperation *operation, id responseObject) {

            [self.webView loadData:responseObject MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
            [SVProgressHUD dismiss];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed to Load", @"")];
        }];
}

- (NSString*)titleForPagePicker
{
    return [NSString stringWithFormat:NSLocalizedString(@"Page %d of %d", @""), (self.currentPageIndex + 1), self.issue.pdfURLs.count];
}

- (void)configureTitle
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;

    self.title = [formatter stringFromDate:self.issue.dateIssued];
}

- (void)configureDeviceBehavior
{
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
//    {
//        self.fullScreenScroll = [[YIFullScreenScroll alloc] initWithViewController:self scrollView:self.webView.scrollView];
//        self.fullScreenScroll.shouldShowUIBarsOnScrollUp = NO;
//    }
}

@end