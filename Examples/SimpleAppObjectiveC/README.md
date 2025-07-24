# SimpleAppObjectiveC

MonetaiSDK를 사용하는 Objective-C 샘플 앱입니다.

## 개요

이 프로젝트는 MonetaiSDK의 주요 기능들을 Objective-C로 구현한 예제입니다. Swift로 작성된 SimpleApp과 동일한 기능을 제공합니다.

## 주요 기능

- **SDK 초기화**: 앱 시작 시 MonetaiSDK 초기화
- **구매 예측**: 사용자의 구매 가능성을 예측
- **이벤트 로깅**: 사용자 행동 이벤트를 서버로 전송
- **할인 배너**: 활성 할인이 있을 때 배너 표시
- **실시간 상태 모니터링**: SDK 초기화 상태를 실시간으로 확인

## 프로젝트 구조

```
SimpleAppObjectiveC/
├── SimpleAppObjectiveC/
│   ├── AppDelegate.h/m          # 앱 델리게이트 및 SDK 초기화
│   ├── ViewController.h/m       # 메인 뷰 컨트롤러
│   ├── DiscountBannerView.h/m   # 할인 배너 뷰
│   ├── Constants.h/m            # 설정 상수
│   ├── SceneDelegate.h/m        # 씬 델리게이트
│   └── main.m                   # 앱 진입점
├── Podfile                      # CocoaPods 의존성 설정
└── README.md                    # 프로젝트 설명
```

## 설정

### 1. SDK 키 설정

`Constants.m` 파일에서 실제 SDK 키로 변경하세요:

```objc
NSString * const kSDKKey = @"your-actual-sdk-key-here";
NSString * const kUserId = @"your-user-id";
```

### 2. 의존성 설치

```bash
cd Examples/SimpleAppObjectiveC
pod install
```

### 3. 프로젝트 실행

`SimpleAppObjectiveC.xcworkspace` 파일을 Xcode에서 열고 실행하세요.

## 사용법

### SDK 초기화

앱이 시작되면 자동으로 SDK가 초기화됩니다:

```objc
// AppDelegate.m에서 자동 초기화
InitializationResult *result = [[MonetaiSDK shared] initializeWithSdkKey:kSDKKey
                                                                  userId:kUserId
                                                           useStoreKit2:kUseStoreKit2
                                                                  error:nil];
```

### 구매 예측

"Predict Purchase" 버튼을 탭하여 구매 예측을 실행할 수 있습니다:

```objc
PredictionResult *result = [[MonetaiSDK shared] predictAndReturnError:nil];
```

### 이벤트 로깅

"Log Event" 버튼을 탭하여 이벤트를 로깅할 수 있습니다:

```objc
NSDictionary *params = @{
    @"button": @"test_button",
    @"screen": @"main"
};
[[MonetaiSDK shared] logEventWithEventName:@"button_click" params:params];
```

### 할인 배너

활성 할인이 있을 때 자동으로 배너가 표시됩니다:

```objc
// 할인 정보 변경 콜백
[MonetaiSDK shared].onDiscountInfoChange = ^(AppUserDiscount * _Nullable discountInfo) {
    // 할인 배너 표시/숨김 처리
};
```

## UI 구성 요소

- **제목**: "MonetaiSDK Demo"
- **상태 표시**: SDK 초기화 상태를 실시간으로 표시
- **예측 버튼**: 구매 예측 기능 실행
- **이벤트 로깅 버튼**: 테스트 이벤트 로깅
- **할인 상태**: 현재 할인 정보 표시
- **결과 표시**: 작업 결과를 텍스트로 표시
- **할인 배너**: 활성 할인이 있을 때 하단에 표시

## 알림 시스템

SDK 초기화 상태를 알림으로 전달합니다:

```objc
// 초기화 성공
[[NSNotificationCenter defaultCenter] postNotificationName:kMonetaiSDKInitializedNotification object:nil];

// 초기화 실패
[[NSNotificationCenter defaultCenter] postNotificationName:kMonetaiSDKInitializationFailedNotification object:error];
```

## 주의사항

1. **SDK 키 보안**: 실제 SDK 키를 버전 관리에 포함하지 마세요
2. **에러 처리**: 네트워크 오류나 SDK 초기화 실패에 대한 적절한 처리가 필요합니다
3. **메모리 관리**: Objective-C에서는 메모리 누수를 방지하기 위해 weak 참조를 적절히 사용하세요

## 문제 해결

### 빌드 오류

1. `pod install`을 실행했는지 확인
2. `.xcworkspace` 파일을 사용하고 있는지 확인
3. MonetaiSDK 프레임워크가 올바르게 링크되었는지 확인

### 런타임 오류

1. SDK 키가 올바른지 확인
2. 네트워크 연결 상태 확인
3. 콘솔 로그에서 오류 메시지 확인

## 라이선스

이 프로젝트는 MonetaiSDK의 샘플 코드입니다.
