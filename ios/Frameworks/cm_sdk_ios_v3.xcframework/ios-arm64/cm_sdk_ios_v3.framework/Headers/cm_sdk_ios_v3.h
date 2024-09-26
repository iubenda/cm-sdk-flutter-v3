//
//  cm_next_sdk_ios.h
//  cm-next-sdk-ios
//
//  Created by Fabio Torre on 28/06/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Project version number for cm_next_sdk_ios.
FOUNDATION_EXPORT double cm_sdk_ios_v3VersionNumber;

//! Project version string for cm_next_sdk_ios.
FOUNDATION_EXPORT const unsigned char cm_sdk_ios_v3VersionString[];

// Forward declarations
@class UrlConfig;
@class ConsentLayerUIConfig;
@protocol CMPManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

// Enums
typedef NS_ENUM(NSInteger, ATTAuthorizationStatus) {
    ATTAuthorizationStatusNotDetermined = 0,
    ATTAuthorizationStatusRestricted,
    ATTAuthorizationStatusDenied,
    ATTAuthorizationStatusAuthorized
};

// CMPManager main class
@interface CMPManager : NSObject

@property (nonatomic, weak, nullable) id<CMPManagerDelegate> delegate;

+ (instancetype)shared;

- (void)setUrlConfig:(UrlConfig *)config;
- (void)setWebViewConfig:(ConsentLayerUIConfig *)config;
- (void)setPresentingViewController:(UIViewController *)viewController;

- (void)checkWithServerAndOpenIfNecessary:(void (^)(NSError * _Nullable))completion;
- (void)openConsentLayer:(void (^)(NSError * _Nullable))completion;
- (void)jumpToSettings:(void (^)(NSError * _Nullable))completion;
- (void)checkIfConsentIsRequired:(void (^)(BOOL))completion;

- (BOOL)hasUserChoice;
- (BOOL)hasPurposeConsent:(NSString *)id;
- (BOOL)hasVendorConsent:(NSString *)id;
- (NSString *)exportCMPInfo;

- (NSArray<NSString *> *)getAllPurposesIDs;
- (NSArray<NSString *> *)getEnabledPurposesIDs;
- (NSArray<NSString *> *)getDisabledPurposesIDs;

- (NSArray<NSString *> *)getAllVendorsIDs;
- (NSArray<NSString *> *)getEnabledVendorsIDs;
- (NSArray<NSString *> *)getDisabledVendorsIDs;

- (void)acceptVendors:(NSArray<NSString *> *)vendors completion:(void (^)(NSError * _Nullable))completion;
- (void)rejectVendors:(NSArray<NSString *> *)vendors completion:(void (^)(NSError * _Nullable))completion;
- (void)acceptPurposes:(NSArray<NSString *> *)purposes updatePurpose:(BOOL)updatePurpose completion:(void (^)(NSError * _Nullable))completion;
- (void)rejectPurposes:(NSArray<NSString *> *)purposes updateVendor:(BOOL)updateVendor completion:(void (^)(NSError * _Nullable))completion;
- (void)rejectAll:(void (^)(NSError * _Nullable))completion;
- (void)acceptAll:(void (^)(NSError * _Nullable))completion;
- (void)importCMPInfo:(NSString *)cmpString completion:(void (^)(NSError * _Nullable))completion;
- (void)resetConsentManagementData:(void (^)(NSError * _Nullable))completion;

// App Tracking Transparency methods
- (void)requestATTAuthorization:(void (^)(ATTAuthorizationStatus))completion API_AVAILABLE(ios(14));
- (ATTAuthorizationStatus)getATTAuthorizationStatus API_AVAILABLE(ios(14));

@end

// UrlConfig class
@interface UrlConfig : NSObject

- (instancetype)initWithId:(NSString *)id
                    domain:(NSString *)domain
                  language:(NSString *)language
                   appName:(NSString *)appName;

@property (nonatomic, strong, readonly) NSString *id;
@property (nonatomic, strong, readonly) NSString *domain;
@property (nonatomic, strong, readonly) NSString *language;
@property (nonatomic, strong, readonly) NSString *appName;

@end

// ConsentLayerUIConfig class
@interface ConsentLayerUIConfig : NSObject

typedef NS_ENUM(NSInteger, Position) {
    PositionFullScreen,
    PositionHalfScreenTop,
    PositionHalfScreenBottom,
    PositionCustom
};

typedef NS_ENUM(NSInteger, BackgroundStyle) {
    BackgroundStyleDimmed,
    BackgroundStyleBlur,
    BackgroundStyleColor,
    BackgroundStyleNone
};

- (instancetype)initWithPosition:(Position)position
                 backgroundStyle:(BackgroundStyle)backgroundStyle
                    cornerRadius:(CGFloat)cornerRadius
                respectsSafeArea:(BOOL)respectsSafeArea
       allowsOrientationChanges:(BOOL)allowsOrientationChanges;

@property (nonatomic, assign, readonly) Position position;
@property (nonatomic, assign, readonly) BackgroundStyle backgroundStyle;
@property (nonatomic, assign, readonly) CGFloat cornerRadius;
@property (nonatomic, assign, readonly) BOOL respectsSafeArea;
@property (nonatomic, assign, readonly) BOOL allowsOrientationChanges;

@end

// CMPManagerDelegate protocol
@protocol CMPManagerDelegate <NSObject>

- (void)didReceiveConsent:(NSString *)consent jsonObject:(NSDictionary<NSString *, id> *)jsonObject;
- (void)didShowConsentLayer;
- (void)didCloseConsentLayer;
- (void)didReceiveError:(NSString *)error;
- (void)didChangeATTStatus:(NSInteger)oldStatus newStatus:(NSInteger)newStatus lastUpdated:(nullable NSDate *)lastUpdated;

@end

NS_ASSUME_NONNULL_END

