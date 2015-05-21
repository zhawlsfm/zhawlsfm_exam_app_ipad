//
//  ReaderViewController.m
//  ZHAW LSFM Exam App
//
//  Created by Adrian on 12.12.14.
//  Copyright (c) 2014 Adrian Busin. All rights reserved.
//

#import "ReaderViewController.h"

@interface ReaderViewController ()

@end

@implementation ReaderViewController

@synthesize myNavItem;
@synthesize documentName;
@synthesize myWebView;

UIActivityIndicatorView *activityIndicator;

//todo: wenn aus background dann schliessen

- (void)viewDidLoad {
    [super viewDidLoad];
    myNavItem.title = documentName;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Zurück",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed)];
    myNavItem.leftBarButtonItem = backButton;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    [myWebView setDelegate:self];
    myWebView.scalesPageToFit = YES;
    
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:documentName];
    NSURL *urlen = [NSURL fileURLWithPath:path];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:urlen];
    [myWebView loadRequest:urlRequest];
    [myWebView setScalesPageToFit:YES];
    
    //todo: set color
    

    //Set baseurl?
    //NSString *bpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //NSURL *baseURL = [NSURL fileURLWithPath:bpath];
    
    //Apple Way but links wont work
    //NSData *pdfData = [NSData dataWithContentsOfFile:path];
    //[(UIWebView *)myWebView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
    
    //Load html string
    //[myWebView loadHTMLString:localDocumentsDirectoryPdfFilePath baseURL:nil];
}

- (void)backButtonPressed {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark UIWebViewDelegate methods

// We want to know when the UIWebView is loading a document, so we can show the network activity indicator
// We can show it on the view itself, or on the top status bar; the code below shows it on the status bar

- (void)webViewDidStartLoad:(UIWebView *)webView {
    myNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(activityIndicator) [activityIndicator stopAnimating];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *test = request.URL.relativeString;
    NSLog(@"Link: %@",test);
    
    if ([request.URL.relativeString isEqualToString:@"http://www.lsfm.zhaw.ch/aboutzhawlsfm.html"]) {
    } else if (request.URL.relativeString.length>7 && [[request.URL.relativeString substringToIndex:8] isEqualToString:@"about://"]) {
        
        /*
         NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:documentName];
        
        //NSString* path2 = [path stringByAppendingPathComponent:@"#page9"];
        
        NSData *pdfData = [NSData dataWithContentsOfFile:path];
        [(UIWebView *)myWebView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
        return NO;
         */
        
    } else if ([request.URL.relativeString isEqualToString:@"about:blank"]) {
        return YES;
    } else if (request.URL.relativeString.length>6 && [[request.URL.relativeString substringToIndex:7] isEqualToString:@"file://"]) {
        return YES;
    } else if (request.URL.relativeString.length>11 && [[request.URL.relativeString substringToIndex:12] isEqualToString:@"http://youtu"]) {   //http://youtu.be/adVzDB26OuQ
    } else if (request.URL.relativeString.length>21 && [[request.URL.relativeString substringToIndex:22] isEqualToString:@"http://www.youtube.com"]) {   //http://www.youtube.com/watch?v=adVzDB26OuQ&feature=youtu.be
    } else if (request.URL.relativeString.length>19 && [[request.URL.relativeString substringToIndex:20] isEqualToString:@"http://m.youtube.com"]) {   //http://m.youtube.com/watch?feature=youtu.be&v=adVzDB26OuQ
    } else if (request.URL.relativeString.length>6 && [[request.URL.relativeString substringToIndex:7] isEqualToString:@"mailto:"]) {
    } else if (request.URL.relativeString.length>3 && [[request.URL.relativeString substringToIndex:4] isEqualToString:@"tel:"]) {
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    }
    return NO;
}


@end
