#
# This policy configuration will be used by all products that
# inherit from Omni
#

BOARD_VENDOR_SEPOLICY_DIRS += \
    vendor/ekrp/sepolicy/common

BOARD_PLAT_PRIVATE_SEPOLICY_DIR += vendor/ekrp/sepolicy/private
BOARD_PLAT_PUBLIC_SEPOLICY_DIR += vendor/ekrp/sepolicy/public
