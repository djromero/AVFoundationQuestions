//
//  AVFAppDelegate.h
//  AVFoundationQuestions
//
//  Created by Julián Romero on 5/18/12.
//  Copyright (c) 2012 Wuonm Web Services S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVFViewController;

@interface AVFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AVFViewController *viewController;

@end
