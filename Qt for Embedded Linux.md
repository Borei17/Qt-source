
file:///S:/main/1_Doing/1_Book/2_Qt/Qt-5.13.0/qt-doc/qtdoc/embedded-linux.html#platform-plugins-for-embedded-linux-devices
Since the Qt 5.0 release, Qt no longer has its own window system (QWS) implementation. For single-process use cases, the Qt Platform Abstraction is a superior solution; multi-process use cases are supported through Wayland.

There are multiple platform plugins that you can use on Embedded Linux systems: EGLFS, LinuxFB, DirectFB, or Wayland. However, the availability of these plugins depend on how Qt is configured. On many boards eglfs is the default plugin. If the default is not suitable, use the QT_QPA_PLATFORM environment variable to request another plugin. Alternatively, for quick tests, the -platform command-line can be used with the same syntax.
- 由于QT 5.0发行，QT不再具有自己的窗口系统（QWS）实现。对于单程用例，QT平台抽象是一种卓越的解决方案;通过`Wayland`支持多流程用例。
- 您可以在嵌入式Linux系统上使用多个平台插件：EGLFS，LinuxFB，DirectFB或Wayland。但是，这些插件的可用性取决于如何配置QT。在许多电路板上，EGLF是默认的插件。如果默认值不合适，请使用qt_qpa_platform变量来请求其他插件。或者，为了快速测试，可以使用相同的语法使用-platform命令行。
# Configure a Specific Device
Building Qt for a given device requires a toolchain and a sysroot. Additionally, some devices require vendor-specific adaptation code for EGL and OpenGL ES 2.0 support. This is not relevant for non-accelerated platforms, such as those that use the LinuxFB plugin, which is meant for software-based rendering only.

The qtbase/mkspecs/devices directory contains configuration and graphics adaptation code for a number of devices. For example, the linux-rasp-pi2-g++ mkspec contains build settings such as the optimal compiler and linker flags for the Raspberry Pi 2 device. The mkspec also contains information about either an implementation of the eglfs hooks (vendor-specific adaptation code), or a reference to the suitable eglfs device integration plugin. The device is selected through the configure tool's -device parameter. The name that follows after this argument must, at least partially, match one of the subdirectories under devices.

The following is an example configuration for the Raspberry Pi 2. For most Embedded Linux boards, the configure command looks similar:
为给定设备构建Qt需要`toolchain`和`Sysroot`。此外，某些设备需要为`EGL`和`OpenGL ES 2.0`支持提供特定于供应商的适应码。这与非加速平台无关，例如使用`LinuxFB`插件的平台，该平台仅适用于基于软件的渲染。
`qtbase/mkspecs/devices`目录包含多个设备的配置和图形自适应代码。例如，`linux-rasp-pi2-g++`包含构建设置，例如Raspberry PI 2设备的最佳编译器和链接器标志。 `mkspec`还包含有关EGLF挂钩（特定于供应商自适应代码）的实现的信息，或者对合适的EGLFS设备集成插件的引用。通过Configure Tool的-Device参数选择设备。在此参数之后的名称必须至少部分地匹配设备下的子目录之一。

以下是Raspberry Pi 2.对于大多数嵌入式Linux板的示例配置，Configure命令看起来类似：

  ./configure -release -opengl es2 -device linux-rasp-pi2-g++ -device-option CROSS_COMPILE=$TOOLCHAIN/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf- -sysroot $ROOTFS -prefix /usr/local/qt5

The most important parameters are -device and -sysroot. By specifying -sysroot, the include files and libraries used by configure's feature detection tests, as well as Qt itself, are taken from the specified location, instead of the host PC's standard locations. Consequently, installing development packages on the host machine has no relevance. For example, to get libinput support, it is not sufficient or necessary to have the libinput development headers and libraries installed on the host environment. Instead, the headers and the libraries for the target architecture, such as ARM, must be present in the sysroot.

pkg-config is supported also when performing cross-compilation. configure automatically sets PKG_CONFIG_LIBDIR to make pkg-config report compiler and linker settings based on the sysroot instead of the host machine. This usually functions well without any further adjustments. However, environment variables such as PKG_CONFIG_PATH must be unset for the host machine before running configure. Otherwise, the Qt build may attempt to use inappropriate headers and libraries from the host system.

Specifying -sysroot results in automatically setting the --sysroot argument when invoking the compiler. In some cases this is not desirable and can be disabled by passing -no-gcc-sysroot to configure.

-prefix, -extprefix, and -hostprefix control the intended destination directory of the Qt build. In the above example the ARM build of Qt is expected to be placed in /usr/local/qt5 on the target device. Note that running make install does not deploy anything to the device. Instead, the install step targets the directory specified by extprefix which defaults to sysroot + prefix and is therefore optional. However, in many cases "polluting" the sysroot is not desirable and thus specifying -extprefix becomes important. Finally, -hostprefix allows separating host tools like qmake, rcc, uic from the binaries for the target. When given, such tools will be installed under the specified directory instead of extprefix.

For more information, see Qt Configure Options.

# Platform Plugins for Embedded Linux Devices
## EGLFS
EGL is an interface between OpenGL and the native windowing system. Qt can use EGL for context and surface management, however the API contains no platform-specifics: The creation of a native window, which will not necessarily be an actual window on the screen, must still be done by platform-specific means. Hence the need for the board or GPU-specific adaptation code. Such adaptations are provided either as eglfs hooks, which can be a single source file compiled into the platform plugin, or as dynamically loaded EGL device integration plugins.

EGLFS is a platform plugin for running Qt5 applications on top of EGL and OpenGL ES 2.0 without an actual windowing system like X11 or Wayland. In addition to Qt Quick 2 and native OpenGL applications, EGLS supports software-rendered windows, like QWidget, too. In the latter case, the widgets' contents are rendered using the CPU into images, which are then uploaded into textures and composited by the plugin.

EGLFS is the recommended plugin for modern Embedded Linux devices that include a GPU.

EGLFS forces the first top-level window - either a QWidget or a QQuickView - to become fullscreen. This window is also chosen to be the root widget window into which all other top-level widgets are composited. For example, dialogs, popup menus, or combo boxes. This behavior is necessary because with EGLFS there is always exactly one native window and one EGL window surface; these belong to the widget or window that is created first. This approach works well when there is a main window that exists for the application's lifetime and all other widgets are either non top-levels or are created afterwards, once the main window is shown.

There are further restrictions for OpenGL-based windows. As of Qt 5.3, eglfs supports a single fullscreen GL window: such as an OpenGL-based QWindow, a QQuickView, or a QOpenGLWidget. Opening additional OpenGL windows or mixing such windows with QWidget-based content is not supported; Qt terminates the application with an error message.

If necessary, eglfs can be configured using the following environment variables:

Environment Variable	Description
QT_QPA_EGLFS_INTEGRATION	In addition to the compiled-in hooks, it is also possible to use dynamically loaded plugins to provide device or vendor-specific adaptation. This environment variable enforces a specific plugin. For example, setting it to eglfs_kms uses the KMS/DRM backend. This is only an option when no static or compiled-in hooks were specified in the device makespecs. In practice, the traditional compiled-in hooks are rarely used, almost all backends are now migrated to plugins. The device makespecs still contain a relevant EGLFS_DEVICE_INTEGRATION entry: the name of the preferred backend for that particular device. This is optional, but very useful to avoid the need to set this environment variable if there are more than one plugin present in the target system. In a desktop environment the KMS or X11 backends are prioritized, depending on the presence of the DISPLAY environment variable.
Note: On some boards a special value of none is used instead of an actual plugin. This indicates that no special integration is necessary to use EGL with the framebuffer; no plugins must be loaded.

QT_QPA_EGLFS_PHYSICAL_WIDTH and QT_QPA_EGLFS_PHYSICAL_HEIGHT	Specifies the physical screen's width and height in millimeters. On platforms where the value cannot be queried from the framebuffer device /dev/fb0 or via other means, a default DPI of 100 is used. Use this variable to override any such defaults. Setting this variable is important because QWidget- or Qt Quick Controls-based applications rely on these values. Running these applications with the hard-coded settings may result in user interface elements with sizes that are unsuitable for the display in use.
QT_QPA_EGLFS_ROTATION	Specifies the rotation applied to software-rendered content in QWidget-based applications. Supported values are 180, 90, and -90. This variable does not apply to OpenGL-based windows, including Qt Quick. Qt Quick applications can apply transformations in their QML scene instead. The standard eglfs mouse cursor always takes the value into account, with an appropriately positioned and rotated pointer image, regardless of the application type. However, special cursor implementations, such as the KMS/DRM backend's hardware cursor, may not support rotation.
QT_QPA_EGLFS_FORCEVSYNC	When set, eglfs requests FBIO_WAITFORVSYNC on the framebuffer device after each call to eglSwapBuffers(). This variable is only relevant for backends relying on the legacy Linux fbdev subsystem. Normally, with a default swap interval of 1, Qt assumes that calling eglSwapBuffers() takes care of vsync; if it doesn't (for example, due to driver bugs), try setting QT_QPA_EGLFS_FORCEVSYNC to a non-zero value.
QT_QPA_EGLFS_FORCE888	When set, the red, green, and blue color channel sizes are ignored when eglfs creates a new context, window or offscreen surface. Instead, the plugin requests a configuration with 8 bits per channel. This can be helpful on devices where configurations with less than 32 or 24 bits per pixel (for example, 5-6-5 or 4-4-4) are chosen by default despite knowing they are not ideal, for example, due to banding effects. Instead of changing application code, this variable provides a shortcut to force 24 or 32 bpp configurations.
Additionally, the following less commonly used variables are available:

Environment Variable	Description
QT_QPA_EGLFS_FB	Overrides the framebuffer device. The default is /dev/fb0. On most embedded platforms this variable isn't very relevant because the framebuffer is used only to query settings like the display dimensions. However, on certain devices, this variable provides the ability to specify which display to use in multiple display setups, similar to the fb parameter in LinuxFB.
QT_QPA_EGLFS_WIDTH and QT_QPA_EGLFS_HEIGHT	Contains the screen's width and height in pixels. While eglfs tries to determine the dimensions from the framebuffer device /dev/fb0, this doesn't always work. It may be necessary to manually specify the sizes.
QT_QPA_EGLFS_DEPTH	Overrides the color depth for the screen. On platforms where the framebuffer device /dev/fb0 is not available or the query is not successful, a default of 32 is used. Use this variable to override any such defaults.
Note: This variable only affects the color depth value reported by QScreen. It has no connection to EGL configurations and the color depth used for OpenGL rendering.

QT_QPA_EGLFS_SWAPINTERVAL	By default, a swap interval of 1 is requested. This variable enables synchronizing to the display's vertical refresh. Use this variable to override the swap interval's value. For instance, passing 0 disables blocking on swap, resulting in running as fast as possible without any synchronization.
QT_QPA_EGLFS_DEBUG	When set, some debugging information is printed on the debug output. For example, the input QSurfaceFormat and the properties of the chosen EGL configuration are printed while creating a new context. When used together with Qt Quick's QSG_INFO variable, you can get useful information for troubleshooting issues related to the EGL configuration.
In addition to QT_QPA_EGLFS_DEBUG, eglfs also supports the more modern categorized logging system of Qt. The following logging categories are available:

qt.qpa.egldeviceintegration – Enables logging for dynamically loaded backends. Very useful to check what backend is in use.
qt.qpa.input – Enables debug output both from the evdev and libinput input handlers. Very useful to check if a given input device was recognized and opened.
qt.qpa.eglfs.kms – Enables verbose logging in the KMS/DRM backend.
After running configure, make sure to inspect the output of it. Not having the necessary eglfs backend, libudev, or libinput enabled due to the corresponding configure tests failing are fairly common issues that can be easily and quickly recognized this way. When there is an undesired "no" result, run configure with -v to turn on verbose output in order to see the compiler and linker invocations for each configure test.

Note: Errors about missing headers, libraries or seemingly cryptic linker failures are often a sign of an incomplete or broken sysroot and have nothing to do with and cannot be solved by Qt.

As an example, when targeting the Raspberry Pi with the Broadcom proprietary graphics drivers, the output should contain something like the following. If this is not the case, there is no point in proceeding further with the build since accelerated graphics will not be functional without the Raspberry Pi-specific backend, even if the rest of Qt compiles successfully.


  QPA backends:
  EGLFS ................................ yes
  EGLFS details:
    EGLFS i.Mx6 ........................ no
    EGLFS i.Mx6 Wayland ................ no
    EGLFS EGLDevice .................... no
    EGLFS GBM .......................... no
    EGLFS Mali ......................... no
    EGLFS Rasberry Pi .................. yes
    EGL on X11 ......................... no

## LinuxFB
This plugin writes directly to the framebuffer via the fbdev subsystem of Linux. Only software-rendered content is supported. Note that on some setups the display performance is expected to be limited.

As of Qt 5.9, DRM dumb buffer support is also available due to fbdev being deprecated in the Linux kernel. This must be requested by setting the QT_QPA_FB_DRM environment variable to a non-zero value. When set, provided that dumb buffers are supported by the system, legacy framebuffer devices like /dev/fb0 are never accessed. Instead, rendering is set up via the DRM APIs, similarly to the eglfs_kms backend of eglfs. The output will be double-buffered and page flipped, providing proper vsync for software-rendered content as well.

Note: when dumb buffers are in use, none of the options described below are applicable since properties like physical and logical screen sizes are all queried automatically.

The linuxfb plugin allows specifying additional settings by passing them in the QT_QPA_PLATFORM environment variable or -platform command-line option. For example, QT_QPA_PLATFORM=linuxfb:fb=/dev/fb1 specifies that the framebuffer device /dev/fb1 must be used instead of the default fb0. Multiple settings can be specified by separating them with a colon.

fb=/dev/fbN - Specifies the framebuffer devices. On multiple display setups this typically allows running the application on different displays. For the time being there is no way to use multiple framebuffers from one Qt application.
size=<width>x<height> - Specifies the screen size in pixels. The plugin tries to query the display dimensions, both physical and logical, from the framebuffer device. This may not always lead to proper results however, and therefore it may become necessary to explicitly specify the values.
mmsize=<width>x<height> - Physical width and height in millimeters.
offset=<width>x<height> - Offset in pixels specifying the top-left corner of the screen. The default position is at (0, 0).
nographicsmodeswitch - Do not switch the virtual terminal to graphics mode (KD_GRAPHICS). In addition to switching to graphics mode, the blinking cursor and screen blanking are normally disabled too. When this parameter is set, these are also skipped.
tty=/dev/ttyN - Overrides the virtual console. Only used when nographicsmodeswitch is not set.
As of Qt 5.9, the behavior of eglfs and linuxfb have been synchronized in regards to window sizing policy: the first top-level window is forced to cover the entire screen, with both platform plugins. If this is not desired, set the QT_QPA_FB_FORCE_FULLSCREEN environment variable to 0 to restore the behavior from earlier Qt versions.

# Input
When no windowing system is present, the mouse, keyboard, and touch input are read directly via evdev or using helper libraries such as libinput or tslib. Note that this requires that device nodes /dev/input/event* are readable by the user. eglfs and linuxfb have all the input handling code compiled-in.

## Using libinput
libinput is a library to handle input devices. It offers an alternative to the Qt's own evdev input support. To enable using libinput, make sure the development files for libudev and libinput are available when configuring and building Qt. xkbcommon is also necessary if keyboard support is desired. With eglfs and linuxfb no further actions are necessary as these plugins use libinput by default. If libinput support is not available or the environment variable QT_QPA_EGLFS_NO_LIBINPUT is set, Qt's own evdev handlers come in to play.

Input on eglfs and linuxfb without libinput
Parameters like the device node name can be set in the environment variables QT_QPA_EVDEV_MOUSE_PARAMETERS, QT_QPA_EVDEV_KEYBOARD_PARAMETERS and QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS. Separate the entries with colons. These parameters act as an alternative to passing the settings in the -plugin command-line argument, and with some backends they are essential: eglfs and linuxfb use built-in input handlers so there is no separate -plugin argument in use.

Additionally, the built-in input handlers can be disabled by setting QT_QPA_EGLFS_DISABLE_INPUT or QT_QPA_FB_DISABLE_INPUT to 1.

## Mouse
The mouse cursor shows up whenever QT_QPA_EGLFS_HIDECURSOR (for eglfs) or QT_QPA_FB_HIDECURSOR (for linuxfb) is not set and Qt's libudev-based device discovery reports that at least one mouse is available. When libudev support is not present, the mouse cursor always show up unless explicitly disabled via the environment variable.

Hot plugging is supported, but only if Qt was configured with libudev support (that is, if the libudev development headers are present in the sysroot at configure time). This allows connecting or disconnecting an input device while the application is running.

The evdev mouse handler supports the following extra parameters:

/dev/input/... - Specifies the name of the input device. When not given, Qt looks for a suitable device either via libudev or by walking through the available nodes.
nocompress - By default, input events that do not lead to changing the position compared to the last Qt mouse event are compressed; a new Qt mouse event is sent only after a change in the position or button state. This can be disabled by setting the nocompress parameter.
dejitter - Specifies a jitter limit. By default dejittering is disabled.
grab - When 1, Qt will grab the device for exclusive use.
abs - Some touchscreens report absolute coordinates and cannot be differentiated from touchpads. In this special situation pass abs to indicate that the device is using absolute events.
## Keyboard
The evdev keyboard handler supports the following extra parameters:

/dev/input/... - Specifies the name of the input device. When not given, Qt looks for a suitable device either via libudev or by walking through the available nodes.
grab - Enables grabbing the input device.
keymap - Specifies the name of a custom keyboard map file.
enable-compose - Enables compositing.
repeat-delay - Sets a custom key repeat delay.
repeat-rate - Sets a custom key repeat rate.
On Embedded Linux systems that do not have their terminal sessions disabled, the behavior on a key press can be confusing as input event is processed by the Qt application and the tty. To overcome this, the following options are available:

EGLFS and LinuxFB attempt to disable the terminal keyboard on application startup by setting the tty's keyboard mode to K_OFF. This prevents keystrokes from going to the terminal. If the standard behavior needs to be restored for some reason, set the environment variable QT_QPA_ENABLE_TERMINAL_KEYBOARD to 1. Note that this works only when the application is launched from a remote console (for example, via ssh) and the terminal keyboard input remains enabled.
An alternative approach is to use the evdev keyboard handler's grab parameter by passing grab=1 in QT_QPA_EVDEV_KEYBOARD_PARAMETERS. This results in trying to get a grab on the input device. If the grab is successful, no other components in the system receive events from it as long as the Qt application is running. This approach is more suitable for applications started remotely as it does not need access to the tty device.
Finally, for many specialized Embedded Linux images it does not make sense to have the standard terminal sessions enabled in the first place. Refer to your build environment's documentation on how to disable them. For example, when generating images using the Yocto Project, unsetting SYSVINIT_ENABLED_GETTYS results in having no getty process running, and thus no input, on any of the virtual terminals.
If the default built-in keymap is not sufficient, a different one can be specified either via the keymap parameter or by using the eglfs-specific loadKeymap() function. The latter allows switching the keymap at runtime. Note however that this requires using eglfs' built-in keyboard handler; it is not supported when the keyboard handler is loaded via the -plugin command-line parameter.

Note: Special system key combinations, such as console switching (Ctrl+Alt+Fx) or zap (Ctrl+Alt+Backspace) are not currently supported and are ignored.

To generate a custom keymap, the kmap2qmap utility can be used. This can be found in the qttools module. The source files have to be in standard Linux kmap format, which is understood by the kernel's loadkeys command. This means one can use the following sources to generate qmap files:

The Linux Console Tools (LCT) project.
Xorg X11 keymaps can be converted to the kmap format with the ckbcomp utility.
As kmap files are plain-text files, they can also be hand crafted.
kmap2qmap is a command line program, that needs at least 2 files as parameters. The last one is the generated .qmap file, while all the others are parsed as input .kmap files. For example:


  kmap2qmap i386/qwertz/de-latin1-nodeadkeys.kmap include/compose.latin1.inc de-latin1-nodeadkeys.qmap

Note: kmap2qmap does not support all the (pseudo) symbols that the Linux kernel supports. When converting a standard keymap, a number of warnings will be shown regarding Show_Registers, Hex_A, and so on; these messages can safely be ignored.

## Touch
For some resistive, single-touch touch screens it may be necessary to fall back to using tslib instead of relying on the Linux multi-touch protocol and the event devices. For modern touch screens this is not necessary. tslib support can be enabled by setting the environment variable QT_QPA_EGLFS_TSLIB or QT_QPA_FB_TSLIB to 1. To change the device, set the environment variable TSLIB_TSDEVICE or pass the device name on the command-line. Note that the tslib input handler generates mouse events and supports single touch only, as opposed to evdevtouch which generates true multi-touch QTouchEvent events too.

The evdev touch handler supports the following extra parameters:

/dev/input/... - Specifies the name of the input device. When not given, Qt looks for a suitable device either via libudev or by walking through the available nodes.
rotate - On some touch screens the coordinates must be rotated, which is done by setting rotate to 90, 180, or 270.
invertx and inverty - To invert the X or Y coordinates in the input events, pass invertx or inverty.
For example, doing export QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS=/dev/input/event5:rotate=180 before launching applications results in an explicitly specified touch device and flipping the coordinates - useful when the orientation of the actual screen and the touch screen do not match.

## Pen-based tablets
The evdevtablet plugin provides basic support for Wacom and similar, pen-based tablets. It generates QTabletEvent events only. To enable it, pass QT_QPA_GENERIC_PLUGINS=evdevtablet in the environment or, alternatively, pass -plugin evdevtablet argument on the command-line. The plugin can take a device node parameter, for example QT_QPA_GENERIC_PLUGINS=evdevtablet:/dev/event1, in case the Qt's automatic device discovery (based either on libudev or a walkthrough of /dev/input/event*) is not functional or misbehaving.

## Debugging Input Devices
It is possible to print some information to the debug output by enabling the qt.qpa.input logging rule, for example by setting the QT_LOGGING_RULES environment variable to qt.qpa.input=true. This is useful for detecting which device is being used, or to troubleshoot device discovery issues.

## Using Custom Mouse Cursor Images
eglfs comes with its own set of 32x32 sized mouse cursor images. If these are not sufficient, a custom cursor atlas can be provided by setting the QT_QPA_EGLFS_CURSOR environment variable to the name of a JSON file. The file can also be embedded into the application via Qt's resource system.

For example, an embedded cursor atlas with 8 cursor images per row can be specified like the following:


  {
    "image": ":/cursor-atlas.png",
    "cursorsPerRow": 8,
    "hotSpots": [
        [7, 2],
        [12, 3],
        [12, 12],
        ...
    ]
  }

Note that the images are expected to be tightly packed in the atlas: the width and height of the cursors are decided based on the total image size and the cursorsPerRow setting. Atlases have to provide an image for all the supported cursors.

# Display Output
When having multiple displays connected, the level of support for targeting one or more of these from one single Qt application varies between the platform plugins and often depends on the device and its graphics stack.

eglfs with eglfs_kms backend
When the KMS/DRM backend is in use, eglfs reports all available screens in QGuiApplication::screens(). Applications can target different screens with different windows via QWindow::setScreen().

Note: The restriction of one single fullscreen window per screen still applies. Changing screens after making the QWindow visible is not supported either. Therefore, it is essential that embedded applications make all the necessary QWindow::setScreen() calls before calling QWindow::show().

When getting started with developing on a given embedded device, it is often necessary to verify the behavior of the device and drivers, and that the connected displays are working as they should. One easy way is to use the hellowindow example. Launching it with -platform eglfs --multiscreen --timeout arguments shows a rotating Qt logo on each connected screen for a few seconds.

Note: Most of the configuration options described below apply to all KMS/DRM-based backends, regardless of the buffer management technology (GBM or EGLStreams).

The KMS/DRM backend also supports custom configurations via a JSON file. Set the environment variable QT_QPA_EGLFS_KMS_CONFIG to the name of the file to enable this. The file can also be embedded into the application via the Qt resource system. An example configuration is below:


  {
    "device": "/dev/dri/card1",
    "hwcursor": false,
    "pbuffers": true,
    "outputs": [
      {
        "name": "VGA1",
        "mode": "off"
      },
      {
        "name": "HDMI1",
        "mode": "1024x768"
      }
    ]
  }

Here we configure the specified device so that

it will not use the hardware cursor (falls back to rendering the mouse cursor via OpenGL; by default hardware cursors are enabled as they are more efficient),
it will back QOffscreenSurface with standard EGL pbuffer surfaces (by default this is disabled and a gbm surface is used instead),
output on the VGA connector is disabled, while HDMI is active with a resolution of 1024x768.
Additionally, such a configuration also disables looking for a device via libudev and instead the specified device is used.

When mode is not defined, the mode that is reported as preferred by the system is chosen. The accepted values for mode are: off, current, preferred, widthxheight, widthxheight@vrefresh, or a modeline string.

Specifying current will choose a mode with a resolution matching the current one. Due to the fact that modesetting is done only when the desired mode is actually different from the active one (unless forced via the QT_QPA_EGLFS_ALWAYS_SET_MODE environment variable), this value is useful to keep the current mode and any content in the planes not touched by Qt.

All screens reported by the DRM layer will be treated as one big virtual desktop by default. The mouse cursor implementation will take this into account and move across the screens as expected. Although not recommended, the virtual desktop mode can be disabled by setting separateScreens to false in the configuration, if desired.

By default, the virtual desktop is formed left to right, based on the order of connectors as reported by the system. This can be changed by setting virtualIndex to a value starting from 0. For example, the following configuration uses the preferred resolution but ensures that the left side in the virtual desktop is the screen connected to the HDMI port, while the right side is the screen connected to the DisplayPort:


  {
    "device": "drm-nvdc",
    "outputs": [
      {
        "name": "HDMI1",
        "virtualIndex": 0
      },
      {
        "name": "DP1",
        "virtualIndex": 1
      }
    ]
  }

The order of elements in the array is not relevant. Outputs with unspecified virtual indices will be placed after the others, with the original order in the DRM connector list preserved.

To create a vertical desktop space (that is, to stack top to bottom instead of left to right), add a virtualDesktopLayout property after device with the value of vertical.

Note: It is recommended that all screens in the virtual desktop use the same resolution, otherwise elements like the mouse cursor may behave in unexpected ways when entering areas that only exist on one given screen.

When virtualIndex is not sufficient, the property virtualPos can be used to explicitly specify the top-left position of the screen in question. Taking the previous example and assuming a resolution of 1080p for HDMI1, the following places a second HDMI-based screen below the first one:


  {
     ...
    "outputs": [
      ...
      {
        "name": "HDMI2",
        "virtualPos": "0, 1080"
      }
    ]
  }

Note: Avoid such configurations when mouse support is desired. The mouse cursor's behavior may be unexpected with non-linear layouts. Touch should present no issues however.

In some cases the automatic querying of the physical screen size via DRM may fail. Normally the QT_QPA_EGLFS_PHYSICAL_WIDTH and QT_QPA_EGLFS_PHYSICAL_HEIGHT environment variable would be used to provide the missing values, however this is not suitable anymore when multiple screens are present. Instead, use the physicalWidth and physicalHeight properties in the outputs list to specify the sizes in millimeters.

Note: Different physical sizes and thus differing logical DPIs are discouraged because it may lead to unexpected issues due to some graphics stack components not knowing about multiple screens and relying solely on the first screen's values.

Each active output from the outputs array corresponds to one QScreen instance reported from QGuiApplication::screens(). The primary screen reported by QGuiApplication::primaryScreen() is by default the screen that gets registered first. When not using virtualIndex, this means the decision is based on the DRM connector order. To override this, set the property primary to true on the desired entry in the outputs list. For example, to ensure the screen corresponding to the VGA output will be the primary even when the system happens to report the HDMI one first, one can do the following:


  {
    "device": "/dev/dri/card0",
    "outputs": [
        { "name": "HDMI1" },
        { "name": "VGA1", "mode": "1280x720", "primary": true },
        { "name": "LVDS1", "mode": "off" }
    ]
  }

For troubleshooting it might be useful to enable debug logs from the KMS/DRM backend. To do this, enable the categorized logging rule, qt.qpa.eglfs.kms.

Note: In an embedded environment virtual desktops are more limited than with a full windowing system. Windows overlapping multiple screens, non-fullscreen windows and moving windows between screens should be avoided and may not function as expected.

The most common and best supported use case for a multi-screen setup is to open a dedicated QQuickWindow or QQuickView for each screen. With the default threaded render loop of the Qt Quick scenegraph, each of these windows will get its own dedicated render thread. This is good because the threads can be throttled independently based on vsync, and will not interfere with each other. With the basic loop this can get problematic and animations may degrade as a result.

As an example, discovering all connected screens and creating a QQuickView for each of them can be done like this:


  int main(int argc, char **argv)
  {
      QGuiApplication app(argc, argv);

      QVector<QQuickView *> views;
      for (QScreen *screen : app.screens()) {
          QQuickView *view = new QQuickView;
          view->setScreen(screen);
          view->setResizeMode(QQuickView::SizeRootObjectToView);
          view->setSource(QUrl("qrc:/main.qml"));
          QObject::connect(view->engine(), &QQmlEngine::quit, qGuiApp, &QCoreApplication::quit);
          views.append(view);
          view->showFullScreen();
      }

      int result = app.exec();

      qDeleteAll(views);
      return result;
  }

Advanced eglfs_kms features
Screen cloning (mirroring) is supported as of Qt 5.11. It can be enabled by the clones property:


  {
    "device": "/dev/dri/card0",
    "outputs": [
        { "name": "HDMI1", "mode": "1920x1080" },
        { "name": "DP1", "mode": "1920x1080", "clones": "HDMI1" }
   ]
  }

Here the content on the display connected via DisplayPort will be the same as on the HDMI one. This is ensured by simply scanning out the same buffer on both.

Note: This can only work if the resolutions are the same, there are no incompatibilities when it comes to accepted buffer formats, and the application does not have any output on the QScreen associated with a clone destination. In practice the latter means that no QWindow associated with the QScreen in question - DP1 in the example - must ever perform a QOpenGLContext::swapBuffers() operation. It is up to the configuration and the application to ensure these.

Headless mode via DRM render nodes is supported as of Qt 5.11. This allows performing GPU compute (OpenGL compute shaders, OpenCL) or offscreen OpenGL rendering without needing DRM master privileges. In this mode applications can function even when there is already another process outputting to the screen.

Just switching device from /dev/dri/card0 to /dev/dri/renderD128 is futile on its own since there are a number of operations that cannot be performed in headless mode. Therefore, this must be combined with a headless property, for example:


  {
      "device": "/dev/dri/renderD128",
      "headless": "1024x768"
  }

Keep in mind that windows are still sized to match the - now virtual - screen size, hence the need for specifying a size in the headless property. There is also a lack of vsync-based throttling.

Once enabled, applications have two typical choices to perform offscreen rendering in headless mode:

Use an ordinary window, such as a QOpenGLWindow subclass, targeting the window's default framebuffer, meaning a gbm_surface in practice:


  MyOpenGLWindow w;
  w.show(); // will not actually show up on screen
  w.grabFramebuffer().save("output.png");

Or the typical offscreen approach with an extra FBO:


  QOffscreenSurface s;
  s.setFormat(ctx.format());
  s.create();
  ctx.makeCurrent(&s);
  QOpenGLFramebufferObject fbo(1024, 768);
  fbo.bind();
  ctx.functions()->glClearColor(1, 0, 0, 1);
  ctx.functions()->glClear(GL_COLOR_BUFFER_BIT);
  fbo.toImage().save("output.png");
  ctx.doneCurrent();

KMS/DRM can be used with two different DRM APIs which are legacy and atomic. The main benefit of DRM atomic API is to allow several DRM plane updates within the same renderloop, whereas legacy API would require one plane update per vsync.

Atomic API is useful when you application needs to blend content into overlays keeping all the updates within the same vsync. Still not all devices support this API and it could be unavailable on some older devices. KMS backend will by default use the legacy API, but you can enable the DRM atomic API with QT_QPA_EGLFS_KMS_ATOMIC environment variable set to 1.

Using a smaller framebuffer than screen resolution can also be useful. This is possible with DRM atomic using the size parameter in the JSON file. The example below uses a 1280x720 framebuffer on a 3840x2160 videomode :


  {
    "device": "/dev/dri/card0",
    "outputs": [
      { "name": "HDMI1", "mode": "3840x2160", "size": "1280x720", "format": "argb8888" }
    ]
  }

## eglfs with eglfs_kms_egldevice backend
This backend, typically used on Tegra devices, is similar to the KMS/DRM backend mentioned above, except that it relies on the EGLDevice and EGLStream extensions instead of GBM.

For technical details about this approach, check out this presentation.

As of Qt 5.7 this backend shares many of its internal implementation with the GBM-based backend. This means that multiple screens and the advanced configuration via QT_QPA_EGLFS_KMS_CONFIG are supported. Some settings, such as hwcursor and pbuffers are not applicable however.

By default the backend will automatically choose the correct EGL layer for the default plane of each output. When necessary, this can be overridden by setting the QT_QPA_EGLFS_LAYER_INDEX environment variable to the index of the desired layer. This approach does not currently support multiple outputs, so its usage should be limited to systems with a single screen. To see which layers are available, and to debug potential startup issues, enable the logging category qt.qpa.eglfs.kms.

In some cases it may be necessary to perform a video mode set on application startup even when the screen reports that the desired resolution is already set. This is normally optimized away, but if the screen stays powered down, try setting the environment variable QT_QPA_EGLFS_ALWAYS_SET_MODE to a non-zero value and relaunch the application.

To configure the behavior of the EGLStream object used by the backend, use the QT_QPA_EGLFS_STREAM_FIFO_LENGTH environment variable. This assumes that KHR_stream_fifo is supported by the target system. By default the stream operates in mailbox mode. To switch to FIFO mode, set a value of 1 or greater. The value specifies the maximum number of frames the stream can hold.

On some systems it may become necessary to target a specific overlay plane through a pre-defined connector. Just forcing a layer index via QT_QPA_EGLFS_LAYER_INDEX does not perform plane configuration and is therefore not suitable in itself. Instead, in such special scenarios use the QT_QPA_EGLFS_KMS_CONNECTOR_INDEX and QT_QPA_EGLFS_KMS_PLANE_INDEX environment variables. When these are set, only the specified connector and plane will be in use, all other outputs will get ignored. The backend will take care of picking the EGL layer that corresponds to the desired plane, and the configuring of the plane.

## Touch input in systems with multiple screens on KMS/DRM
Touchscreens require additional considerations in multi-display systems because touch events have to be routed to the correct virtual screen, and this requires a correct mapping between touchscreens and display outputs.

The mapping is done via the JSON configuration file specified in QT_QPA_EGLFS_KMS_CONFIG and described in the previous sections. When a touchDevice property is present in an element of the outputs array, the value is treated as a device node and the touch device is associated with the display output in question.

For example, assuming our touchscreen has a device node of /dev/input/event5 and is a touchscreen integrated into the monitor connected via HDMI as the secondary screen, the following configuration ensures correct touch (and synthesized mouse) event translation:


   {
      "device": "drm-nvdc",
      "outputs": [
        {
          "name": "HDMI1",
          "touchDevice": "/dev/input/event5",
          "virtualIndex": 1
        },
        {
          "name": "DP1",
          "virtualIndex": 0
        }
      ]
  }

Note: When in doubt, enable logging from both the graphics and input subsystems by setting the environment variable QT_LOGGING_RULES=qt.qpa.*=true before launching the application. This will help identifying the correct input device nodes and may uncover output configuration issues that can be difficult to debug otherwise.

Note: As of Qt 5.8, the above is only supported for the evdevtouch input backend. Other variants, such as the libinput-based one, will continue to route events to the primary screen. To force the usage of evdevtouch on systems where multiple input backends are available, set the environment variable QT_QPA_EGLFS_NO_LIBINPUT to 1.

## eglfs with other backends
Other backends, that are typically based on targeting the framebuffer or a composition API directly via the vendor's EGL implementation, usually provide limited or no support for multiple displays. On i.MX6-based boards with Vivante GPUs the QT_QPA_EGLFS_FB environment variable can be used to specify the framebuffer to target, similarly to linuxfb. On the Raspberry Pi the QT_QPA_EGLFS_DISPMANX_ID environment variable can be used to specify the screen to output to. The value corresponds to one of the DISPMANX_ID_ constants, refer to the Dispmanx documentation. Note that these approaches, unlike KMS/DRM, will not typically allow to output to multiple screens from the same application. Alternatively, driver-specific environment variables or kernel parameters may also be available as well to control the used framebuffer. Refer to the embedded board's documentation.

## Video Memory
Systems with a fixed amount of dedicated video memory may need extra care before running Qt application based on Qt Quick or classes like QOpenGLWidget. The default setting may be insufficient for such applications, especially when they are displayed on a high resolution (for example, full HD) screen. In this case, they may start failing in unexpected ways. It is recommended to ensure that there is at least 128 MB of GPU memory available. For systems that do not have a fixed amount of memory reserved for the GPU this is not an issue.

## linuxfb
Use the fb plugin parameter to specify the framebuffer device to use.

# Unix Signal Handlers
The console-oriented platform plugins like eglfs and linuxfb install signal handlers by default to capture interrupt (SIGINT), suspend and continue (SIGTSTP, SIGCONT) and termination (SIGTERM). This way the keyboard, terminal cursor, and possibly other graphics state can be restored when the application terminates or gets suspended due to kill, or Ctrl+C or Ctrl+Z. (although terminating or suspending via the keyboard is only possible when QT_QPA_ENABLE_TERMINAL_KEYBOARD is set, as outlined above in the Input section). However, in some cases capturing SIGINT can be undesirable as it may conflict with remote debugging for instance. Therefore, the environment variable QT_QPA_NO_SIGNAL_HANDLER is provided to opt out from all built-in signal handling.

# Fonts
Qt normally uses fontconfig to provide access to system fonts. If fontconfig is not available, Qt will fall back to using QBasicFontDatabase. In this case, Qt applications will look for fonts in Qt's lib/fonts directory. Qt will automatically detect pre-rendered fonts and TrueType fonts. This directory can be overridden by setting the QT_QPA_FONTDIR environment variable.

For more information on the supported formats, see Qt for Embedded Linux Fonts.

Note: Qt no longer ships any fonts in the lib/fonts directory. This means that it is up to the platform (the system image) to provide the necessary fonts.

Platform Plugins for Windowing Systems on Embedded Linux Devices
XCB
This is the X11 plugin used on regular desktop Linux platforms. In some embedded environments, that provide X and the necessary development files for xcb, this plugin functions just like it does on a regular PC desktop.

Note: On some devices there is no EGL and OpenGL support available under X because the EGL implementation is not compatible with Xlib. In this case the XCB plugin is built without EGL support, meaning that Qt Quick 2 or other OpenGL-based applications does not work with this platform plugin. It can still be used however to run software-rendered applications (based on QWidget for example).

As a general rule, the usage of XCB on embedded devices is not advisable. Plugins like eglfs are likely to provide better performance, and hardware acceleration.

# Wayland
Wayland is a light-weight windowing system; or more precisely, it is a protocol for clients to talk to a display server.

Qt Wayland provides a wayland platform plugin that allows Qt applications to connect to a Wayland compositor.

For more details, see Wayland and Qt.

Note: You may experience issues with touch screen input while using the Weston reference compositor. For more information, see https://wiki.qt.io/WestonTouchScreenIssues.

Related Topics
Qt for Device Creation
Emulator
Qt Virtual Keyboard
Qt Quick WebGL