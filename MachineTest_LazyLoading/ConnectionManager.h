//
//  ConnectionManager.h
//  MachineTest_LazyLoading
//
//  Created by Rajesh Sharma on 26/11/15.
//  Copyright (c) 2015 Practice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ConnectionManager : NSObject

+(ConnectionManager *)sharedConnectionManager;

- (void)getDataFromURL:(NSString *)url completion:(void (^)(id response))completionBlock;
- (void)imageLoadingForURL:(NSString *)imageURL andImageView:(UIImageView *)imageView;
@end
