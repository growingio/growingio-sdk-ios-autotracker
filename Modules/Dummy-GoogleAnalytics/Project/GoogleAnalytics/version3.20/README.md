- ```
  lipo GoogleAnalytics.a -thin arm64 -ouput GoogleAnalytics-arm64.a
  ```

- ```
  ar -x GoogleAnalytics-arm64.a
  ```

- ```
  libtool -static -o result-arm64.a \
  
  GAICampaign.o \
  
  GAIDictionaryBuilder.o \
  
  GAIEcommerceFields.o \
  
  GAIExceptionParser.o \
  
  GAIFields.o \
  
  GAIStringUtil.o \
  
  GAIUsageTracker.o \
  
  GAIUtil.o \
  
  GAIEcommerceProduct.o \
  
  GAIEcommerceProductAction.o \
  
  GAIEcommercePromotion.o \
  
  GAITrackedViewController.o
  ```

- ```
  lipo -create result-arm64.a result-armv7.a -output GoogleAnalytics.a
  ```

- 
