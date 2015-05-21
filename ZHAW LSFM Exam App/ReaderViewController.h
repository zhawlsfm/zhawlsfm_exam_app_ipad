//
//  ReaderViewController.h
//  ZHAW LSFM Exam App
//
//  Created by Adrian on 12.12.14.
//  Copyright (c) 2014 Adrian Busin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReaderViewController : UIViewController <UINavigationControllerDelegate, UIWebViewDelegate> {
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) IBOutlet UIWebView *myWebView;
@property (nonatomic, strong) IBOutlet UINavigationItem *myNavItem;
@property (nonatomic, strong) NSString *documentName;

@end
