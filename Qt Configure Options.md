- `configure`是一个命令行工具，它确定如何为特定平台构建Qt。`configure`可以排除Qt中的功能，并确定QT如何构建并将应用程序部署到主机平台上。此页面讨论了一些配置选项，但有关选项的完整列表，请输入命令配置-h。配置应从主Qt源目录运行。
- 除非另有说明，否则此页面中的命令适用于Linux平台。在Windows系统上，配置脚本称为configure.bat。
- 运行`configure`后，使用属于所选工具链的制作工具构建源。
# Source, Build, and Install Directories
- 源目录包含从源包或git存储库中获取的源代码。
- 构建目录是存储与构建相关文件（如Makefiles，Object文件和其他中间文件）的位置。
- 安装目录是安装二进制文件和库的位置，用于系统或应用程序使用。
建议将这些目录保留通过暗影构建和使用-prefix选项分开。这使您可以将Qt源树保留从构建工件和二进制文件中清除，这些工件和二进制文件存储在单独的目录中。如果您希望从同一源树中具有多个构建，则此方法非常方便，但是对于不同的配置。向影子构建，从单独的目录运行配置：
```bash
  mkdir ~/qt-build
  cd ~/qt-build
  ~/qt-source/configure -prefix /opt/Qt5.9
  qmake
```
使用-prefix选项配置意味着Qt二进制文件和库安装到另一个目录中，在这种情况下是/pt/qt5.9。运行qmake在~/qt-build目录中生成makefiles，而不是在源目录中。 Makefile到位后，运行以下命令以构建Qt二进制文件和库，并安装它们：
```bash
  make
  make install
```
注意：只有在使用`-PREFIX`配置QT的情况下，才需要`make install`步骤，该步骤是基于UNIX的平台上的默认值，除非使用`-developer-build`配置选项。在Windows上，QT默认配置为`non-prefix`构建。
注意：`-developer-build`是为了开发Qt而不是用于运输应用程序。这样的构建包含比标准构建更多的导出符号，并使用更高的警告级别编译。
# Modules and Features
- Qt由不同的模块组成，其源可以在顶级源目录中的不同目录中找到。用户可以明确排除特定的顶级目录以限制构建时间。此外，每个QT模块可能具有也可以明确启用或禁用的功能。
## Excluding Qt Modules
- `Configure`的`-skip`选项允许从Qt Build中排除顶级源目录。请注意，许多目录包含多个QT模块。例如，要从Qt构建中排除Qt NFC和QT蓝牙，`./configure -skip qtconnectivity`
## Including or Excluding Features
- `-feature-<feature>` `-no-feature-<feature>`选项分别包括和排除特定功能。
- 例如，要禁用可访问性，`./configure -no-feature-accessibility`

- 使用`Configure -List-rist-featubily`显示命令行上的所有可用功能的列表。请注意，功能可以取决于其他功能，因此禁用功能可能对其他功能具有副作用。
- 作为设备创建的Qt的一部分的Qt配置工具允许通过方便的用户界面调整功能和依赖项。
# Third-Party Libraries
- Qt源包包括第三方库。要设置Qt是否应使用该系统的库或使用捆绑版本，在库的名称之前传递-System或-qt。
- 下表总结了第三方选项：
  - zlib	-qt-zlib	-system-zlib
  - libjpeg	-qt-libjpeg	-system-libjpeg
  - libpng	-qt-libpng	-system-libpng
  - xcb	-qt-xcb	-system-xcb
  - freetype	-qt-freetype	-system-freetype
  - PCRE	-qt-pcre	-system-pcre
  - HarfBuzz-NG	-qt-harfbuzz	-system-harfbuzz
- 还可以通过使用-no而不是-qt禁用对这些库的支持。
- 例如，要使用System的XCB库和禁用Zlib支持，请输入以下内容：
  - `./configure -no-zlib -qt-libjpeg -qt-libpng -system-xcb`
有关选项的完整列表，请参阅使用`Configure -help`的帮助
# Compiler Options
- `-platform`选项设置主机平台和编译器以构建Qt源。支持的平台和编译器列表在“支持的平台”页面中找到，`qtbase/mkspec`目录中有完整列表。
- 例如，在Ubuntu Linux系统上，可以由诸如Clang或G ++之类的多个编译器编译Qt：
  ./configure -platform linux-clang
  ./configure -platform linux-g++
  ./configure -platform linux-g++-32
对于Windows，MINGW或Visual Studio Toolchains可用于编译Qt。
  configure.bat -platform win32-g++
  configure.bat -platform win32-msvc
- 之后，生成的Makefiles将使用相应的编译器命令。
# Cross-Compilation Options
- 要为跨平台开发和部署配置Qt，需要设置目标平台的开发工具链。此设置在支持的平台中变化。
- 常见的选择是：
  - `-xplatform` -目标平台。有效的`-xplatform`选项与`qtbase/mkspecs`中找到的`-platform`选项相同。
  - `-device` - a specific device or chipsets. The list of devices that configure is compatible with are found in qtbase/mkspecs/devices.特定的设备或芯片组。`qtbase/mkspecs`中兼容的设备列表。
  - `-device-option` - sets additional qmake variables. For example, -device-option CROSS_COMPILE=<path-to-toolchain> provides the environment variable, CROSS_COMPILE, as needed by certain devices.设置额外的qmake变量。例如，`-device-option CROSS_COMPILE=<path-to-toolchain>`
注意：非桌面目标的工具链通常与所谓的Sysroot进行
## 平台的具体选项
以下页面提供了如何为特定平台开发配置QT的指南：
Qt for iOS - Building from Source
Qt for WinRT - Building from Source
Qt for Embedded Linux - Building from Source
Qt for Raspberry Pi - a community-driven site for Raspberry devices
Devices - a list of other devices and chipsets
# OpenGL Options for Windows
On Windows, Qt can be configured with the system OpenGL or with ANGLE. By default, Qt is configured to use dynamic OpenGL. This means that it tries to use system OpenGL and falls back to ANGLE, which is bundled with Qt and depends on the DirectX SDK, if native OpenGL does not work. ANGLE enables running Qt applications that depend on OpenGL, without installing the latest OpenGL drivers. If ANGLE also fails, Qt will fall back to software rendering, which is the slowest but most safe of the rendering methods.

The -opengl option can be used to configure Qt to use the OpenGL in the target system, a different version of OpenGL ES (with or without ANGLE), or dynamically switch between the available OpenGL implementations.


  configure.bat -opengl dynamic

With the dynamic option, Qt will try to use native OpenGL first. If that fails, it will fall back to ANGLE and finally to software rendering in case of ANGLE failing as well.


  configure.bat -opengl desktop

With the desktop option, Qt uses the OpenGL installed on Windows, requiring that the OpenGL in the target Windows machine is compatible with the application. The -opengl option accepts two versions of OpenGL ES, es2 for OpenGL ES 2.0 or es1 for OpenGL ES Common Profile.


  configure.bat -opengl es2

You can also use -opengl dynamic, which enable applications to dynamically switch between the available options at runtime. For more details about the benefits of using dynamic GL-switching, see Graphics Drivers.