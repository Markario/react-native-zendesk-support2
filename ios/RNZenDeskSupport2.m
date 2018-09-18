//
//  RNZenDeskSupport2.m
//  Created by Oleksii Kozulin
//  17/10/2018

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTConvert.h>
#else
#import "RCTConvert.h"
#endif

#import "RNZenDeskSupport2.h"
#import <ZendeskCoreSDK/ZendeskCoreSDK.h>
#import <ZendeskSDK/ZendeskSDK.h>

@implementation RNZenDeskSupport2

RCT_EXPORT_MODULE();

- (void)submitRequestCompleted:(NSNotification*)notification {
    [self sendEventWithName:@"submitRequestCompleted" body:notification];
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"submitRequestCompleted"];
}

RCT_EXPORT_METHOD(initialize:(NSDictionary *)config){
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(submitRequestCompleted:)
                                             name:ZDKAPI_RequestSubmissionSuccess
                                           object:nil];
    
    NSString *appId = [RCTConvert NSString:config[@"appId"]];
    NSString *zendeskUrl = [RCTConvert NSString:config[@"zendeskUrl"]];
    NSString *clientId = [RCTConvert NSString:config[@"clientId"]];
    [ZDKZendesk initializeWithAppId:appId clientId:clientId zendeskUrl:zendeskUrl];
    [ZDKSupport initializeWithZendesk:[ZDKZendesk instance]];
}

RCT_EXPORT_METHOD(setupIdentity:(NSDictionary *)identity){
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *email = [RCTConvert NSString:identity[@"customerEmail"]];
        NSString *name = [RCTConvert NSString:identity[@"customerName"]];
        id<ZDKObjCIdentity> userIdentity = [[ZDKObjCAnonymous alloc] initWithName:name
                                                                     email:email];
        [[ZDKZendesk instance] setIdentity:userIdentity];

    });
}

RCT_EXPORT_METHOD(callSupport:(NSDictionary *)fields) {
    NSDictionary *customFields = [RCTConvert NSDictionary:fields[@"customFields"]];
    NSString *subject = [RCTConvert NSString:fields[@"subject"]];
    NSArray *tags = [RCTConvert NSArray:fields[@"tags"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];

        NSMutableArray *customFieldArray = [[NSMutableArray alloc] init];
        
        for (NSString* key in customFields) {
            id value = [customFields objectForKey:key];
            [customFieldArray addObject: [[ZDKCustomField alloc] initWithFieldId:@(key.intValue) andValue:value]];
        }

        ZDKRequestUiConfiguration * config = [ZDKRequestUiConfiguration new];
        config.subject = subject;
        config.tags = tags;
        config.fields = customFieldArray;

        [vc presentViewController:vc animated:YES completion:nil];
    });
}

@end
