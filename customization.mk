# Copyright (C) 2019 AngeloGioacchino Del Regno <kholk11@gmail.com>
#
# ROM specific customization for Sony Open Devices
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TARGET_GAPPS_ARCH := arm64

TARGET_KERNEL_HEADERS := kernel/sony/msm-4.14/kernel

CUST_PATH := device/sony/customization

# DEVICE_PACKAGE_OVERLAYS += $(CUST_PATH)/overlay

ifneq ($(filter rr_kugo rr_blanc rr_lilac, $(TARGET_PRODUCT)),)
TARGET_SCREEN_HEIGHT := 1280
TARGET_SCREEN_WIDTH := 720
endif

ifneq ($(filter rr_suzu rr_dora rr_kagura rr_keyaki rr_poplar rr_pioneer rr_voyager rr_discovery rr_kirin, $(TARGET_PRODUCT)),)
TARGET_SCREEN_HEIGHT := 1920
TARGET_SCREEN_WIDTH := 1080
endif

ifneq ($(filter rr_akari rr_apollo, $(TARGET_PRODUCT)),)
TARGET_SCREEN_HEIGHT := 2160
TARGET_SCREEN_WIDTH := 1080
endif

ifneq ($(filter rr_akatsuki, $(TARGET_PRODUCT)),)
TARGET_SCREEN_HEIGHT := 2880
TARGET_SCREEN_WIDTH := 1440
endif

ifneq ($(filter rr_mermaid rr_bahamut, $(TARGET_PRODUCT)),)
TARGET_SCREEN_HEIGHT := 2520
TARGET_SCREEN_WIDTH := 1080
endif

ifneq ($(filter rr_maple, $(TARGET_PRODUCT)),)
TARGET_SCREEN_HEIGHT := 3840
TARGET_SCREEN_WIDTH := 2160
endif

ifneq ($(filter rr_griffin, $(TARGET_PRODUCT)),)
TARGET_SCREEN_HEIGHT := 3840
TARGET_SCREEN_WIDTH := 1644
endif

ifneq ($(filter rr_maple, $(TARGET_PRODUCT)),)
# Faking to 1080 to get the right bootanimation res on:
# Maple(3840x2160)
TARGET_BOOT_ANIMATION_RES := 1080
else ifneq ($(filter rr_griffin, $(TARGET_PRODUCT)),)
# Faking to 1440 to get the best bootanimation res on:
# Griffin (3840x1644)
TARGET_BOOT_ANIMATION_RES := 1440
else
TARGET_BOOT_ANIMATION_RES := $(TARGET_SCREEN_WIDTH)
endif

# Product for OTA
CUSTOM_TARGET_DEVICE := $(CUSTOM_BUILD)

PRODUCT_PACKAGES += \
    e2fsprogs \
    strace

TARGET_RECOVERY_DEVICE_MODULES := tune2fs strace

# Google Wifi Hal
TARGET_INCLUDE_WIFI_EXT := false

# cust packages
PRODUCT_PACKAGES += \
    HotwordEnrollmentOKGoogleHEXAGON \
    HotwordEnrollmentXGoogleHEXAGON

# TEMP: Missing libs for soundtrigger
PRODUCT_PACKAGES += \
    libsmwrapper \
    libmulawdec

# IMS Extras
PRODUCT_PACKAGES += \
    qtiImsInCallUi \
    ConfURIDialer

PRODUCT_BOOT_JARS += \
    telephony-ext

TARGET_FWK_DETECT_PATH := vendor/qcom/opensource/core-utils
TARGET_PROVIDES_QTI_TELEPHONY_JAR := true

# ODM apps are signed with test-keys: stop bind mounting
# these apps, because we are including them in the build
# here to get them signed with our keys for security purposes.
TARGET_USES_ODM_APPS_BINDMOUNT := false

ifeq ($(TARGET_USES_ODM_APPS_BINDMOUNT),false)
# Standard ODM apps
PRODUCT_PACKAGES += \
    datastatusnotification \
    embms \
    QtiTelephonyService \
    uceShimService \
    uimgbaservice \
    uimlpaservice \
    uimremoteclient \
    uimremoteserver

# Standard ODM priv-apps
PRODUCT_PACKAGES += \
    dpmserviceapp \
    ims \
    qcrilmsgtunnel \
    CneApp \
    IWlanService
endif # !TARGET_USES_ODM_APPS_BINDMOUNT

# Bind-mount odm files into subfolder of /system_ext
PRODUCT_PACKAGES += \
    bindmountims.rc

# Extra apps that are not standard in ODM
PRODUCT_PACKAGES += \
    QtiSystemService

# Permissions for Hotword
PRODUCT_COPY_FILES += \
    $(CUST_PATH)/extras/HotwordEnrollmentXGoogleHEXAGON/privapp-permissions-xGoogleHEXAGON.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-xGoogleHEXAGON.xml \
    $(CUST_PATH)/extras/HotwordEnrollmentOKGoogleHEXAGON/privapp-permissions-OkGoogleHEXAGON.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-OkGoogleHEXAGON.xml

# We are re-signing the IMS app, so we are installing it from the build system:
# copy emptyfile to ims/lib/arm64 purely to create the folder
PRODUCT_COPY_FILES += \
    $(CUST_PATH)/ims/emptyfile:$(TARGET_COPY_OUT_PRODUCT)/priv-app/ims/lib/arm64/bind_mount_lib64_here

# USB debugging at boot
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp,adb \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1

# Recovery UI hack for Ganges video mode panels
ifneq ($(filter ganges, $(SOMC_PLATFORM)),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.recovery.ui.blank_unblank_on_init=true
endif

# Update recovery with the ota for legacy
ifneq ($(filter loire tone yoshino, $(SOMC_PLATFORM)),)
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.recovery_update=true
else
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.recovery_update=false
endif

# VoLTE
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.is_voip_enabled=1 \
    persist.vendor.radio.rat_on=combine \
    persist.vendor.radio.voice_on_lte=1

TARGET_USES_AOSP_APNS_CONF := true

# Wallpapers
PRODUCT_PACKAGES += \
    PixelLiveWallpaperPrebuilt

# Widevine
$(call inherit-product-if-exists, vendor/widevine/widevine.mk)

# Updatable Apex
DEXPREOPT_GENERATE_APEX_IMAGE := true

-include $(CUST_PATH)/pe_cust.mk
-include vendor/rr/config/common_full_phone.mk
