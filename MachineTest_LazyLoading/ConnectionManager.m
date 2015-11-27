//
//  ConnectionManager.m
//  MachineTest_LazyLoading
//
//  Created by Rajesh Sharma on 26/11/15.
//  Copyright (c) 2015 Practice. All rights reserved.
//

#import "ConnectionManager.h"


@interface ConnectionManager ()
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;
@property (strong, nonatomic) NSURLSession              *session;
@property (strong, nonatomic) NSOperationQueue          *opperationQueue;

@end

@implementation ConnectionManager

+(ConnectionManager *)sharedConnectionManager {
    
    static ConnectionManager *conManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        conManager = [[ConnectionManager alloc] init];
        conManager.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        conManager.session = [NSURLSession sessionWithConfiguration:conManager.sessionConfiguration];
        conManager.opperationQueue = [[NSOperationQueue alloc] init];
        [conManager.opperationQueue setMaxConcurrentOperationCount:10];
    });
    return conManager;
}

- (void)imageLoadingForURL:(NSString *)imageURL andImageView:(UIImageView *)imageView {

    NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithURL:[NSURL URLWithString:imageURL] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: location];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            imageView.image = [UIImage imageWithData: imageData];
        });
        imageData = nil;
    }];
    [downloadTask resume];
}

- (void)getDataFromURL:(NSString *)url completion:(void (^)(id))completionBlock{
    
    NSURLSessionDataTask *dataTask = [_session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        completionBlock(dic);
    }];
    [dataTask resume];
}
@end
