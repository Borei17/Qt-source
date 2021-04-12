# QTextTable
表是一组按行和列排列的单元格。每个表至少包含一行和一列。每个单元格包含一个块，并被一个框架包围。
通常使用QTextCursor::insertTable()函数创建表并插入到文档中。例如，我们可以在编辑器的当前光标位置插入一个三行两列的表，使用以下代码行:
```c++
    QTextCursor cursor(editor->textCursor());
    cursor.movePosition(QTextCursor::Start);

    QTextTable *table = cursor.insertTable(rows, columns, tableFormat);
```
表格式可以在创建表时定义，也可以在稍后使用setFormat()更改表。

当前被游标编辑的表可以通过QTextCursor::currentTable()找到。
这允许在将其插入文档后更改其格式或尺寸。

可以使用resize()或insertRows()、insertColumns()、removeRows()或removeColumns()来更改表的大小。
使用cellAt()检索表格单元格。

通过在表中移动游标，并使用rowStart()和rowEnd()函数在每行开始和结束处获得游标，可以找到表行开始和结束的位置。

QTextTable中的行和列可以使用mergeCells()和splitCell()函数进行合并和分割。
但是，只有跨多行或多列的单元格才能被分割。
(合并或拆分不会增加或减少行和列的数量。)

请注意，如果将多个列和行合并到一个单元格中，则不能将合并的单元格分割为跨多个行或列的新单元格。
为了能够分割跨多个行和列的单元格，您需要在多个迭代中完成这一操作。

Original Table	Suppose we have a 2x3 table of names and addresses. To merge both columns in the first row we invoke mergeCells() with row = 0, column = 0, numRows = 1 and numColumns = 2.
假设我们有一个2x3的名称和地址表。为了合并第一行中的两列，我们使用row = 0, column = 0, numRows = 1和numColumns = 2调用mergeCells()。
    table->mergeCells(0, 0, 1, 2);
	This gives us the following table. To split the first row of the table back into two cells, we invoke the splitCell() function with numRows and numCols = 1.
    table->splitCell(0, 0, 1, 1);
Split Table	This results in the original table.

# QTimer::singleShot
这个静态函数在给定的时间间隔后调用一个插槽。
使用这个函数非常方便，因为您不需要操心timerEvent或创建本地QTimer对象。
例子:
```c++
 #include <QApplication>
 #include <QTimer>

 int main(int argc, char *argv[])
 {
     QApplication app(argc, argv);
     QTimer::singleShot(600000, &app, SLOT(quit()));
     ...
     return app.exec();
 }
 ```
这个示例程序在10分钟(60万毫秒)后自动终止。
接收者是接收对象，成员是槽位。时间单位为毫秒。

# QElapsedTimer
QElapsedTimer类提供了一种计算运行时间的快速方法。
QElapsedTimer类通常用于快速计算两个事件之间经过了多少时间。它的API与QTime类似，因此使用它的代码可以快速移植到新类中。
然而，与QTime不同的是，QElapsedTimer尝试在可能的情况下使用单调时钟。这意味着不可能将QElapsedTimer对象转换为人类可读的时间。
该类的典型用例是确定在慢操作中花费了多少时间。这种情况最简单的例子是为了调试目的，如下面的例子:
```c++
     QElapsedTimer timer;
     timer.start();

     slowOperation1();

     qDebug() << "The slow operation took" << timer.elapsed() << "milliseconds";
```
在这个示例中，计时器是通过调用start()启动的，经过的计时器是通过elapsed()函数计算的。
经过的时间还可以用于在第一个操作完成后重新计算另一个操作可用的时间。当执行必须在一定时间内完成，但需要几个步骤时，这是很有用的。QIODevice及其子类中的waitfor类型函数就是很好的例子。在这种情况下，代码如下:
```c++
 void executeSlowOperations(int timeout)
 {
     QElapsedTimer timer;
     timer.start();
     slowOperation1();

     int remainingTime = timeout - timer.elapsed();
     if (remainingTime > 0)
         slowOperation2(remainingTime);
 }
```
另一个用例是为特定的时间片执行特定的操作。为此，QElapsedTimer提供了hasExpired()方便函数，它可以用来确定是否已经经过了特定的毫秒数:
```c++
 void executeOperationsForTime(int ms)
 {
     QElapsedTimer timer;
     timer.start();

     while (!timer.hasExpired(ms))
         slowOperation1();
 }
```
在这种情况下，使用QDeadlineTimer通常更方便，它会计算未来的超时时间，而不是跟踪经过的时间。

# QNetworkConfigurationManager
`利用QNetworkConfigurationManager类可以及时检测网络连接状态`
QNetworkConfigurationManager类管理系统提供的网络配置。
QNetworkConfigurationManager提供对系统已知的网络配置的访问，并使应用程序能够在运行时检测系统功能(与网络会话有关)。
QNetworkConfiguration抽象了一组配置选项，描述了如何配置一个网络接口来连接到特定的目标网络。QNetworkConfigurationManager维护和更新QNetworkConfigurationManager的全局列表。应用程序可以通过allConfigurations()访问和过滤这个列表。如果添加了新的配置，或者删除或更改了现有的配置，则会分别发出configurationAdded()、configurationRemoved()和configurationChanged()信号。
当打算立即创建一个新的网络会话而不关心特定的配置时，可以使用defaultConfiguration()。它返回一个QNetworkConfiguration::Discovered配置。如果没有发现，则返回无效的配置。
一些配置更新可能需要一些时间来执行更新。WLAN扫描就是这样一个例子。除非平台执行内部更新，否则可能需要通过QNetworkConfigurationManager:: updateconconfigurations()手动触发配置更新。通过发出updateCompleted()信号来指示更新过程的完成。更新流程确保更新每个现有的QNetworkConfiguration实例。不需要通过allConfigurations()请求更新配置列表。
也看到QNetworkConfiguration。

# QNetworkSession
QNetworkSession类提供对系统接入点的控制，并在多个客户机访问同一个接入点时支持会话管理。
QNetworkSession支持对系统的网络接口进行控制。会话的配置参数是通过它所绑定的QNetworkConfiguration对象确定的。根据会话的类型(单个访问点或业务网络)，会话可以链接到一个或多个网络接口。通过打开和关闭网络会话，开发人员可以启动和停止系统的网络接口。如果配置代表多个接入点(请参阅QNetworkConfiguration:: servicennetwork)，则可能支持漫游等更高级的特性。
QNetworkSession支持同一进程内的会话管理，并且根据平台的能力可能支持进程外会话。如果多个开放会话使用相同的网络配置，则底层网络接口只有在关闭最后一个会话时才会终止。

# QLatin1String: QLatin1String (const char * str)
构造存储str的QLatin1String对象。
字符串数据不会被复制。调用者必须能够保证只要QLatin1String对象存在，str就不会被删除或修改。
# QLatin1String
QLatin1String类为US-ASCII/Latin-1编码的字符串文本提供了一个精简的包装器。
许多QString的成员函数被重载为接受const char *而不是QString。这包括复制构造函数、赋值操作符、比较操作符和各种其他函数，如insert()、replace()和indexOf()。通常对这些函数进行优化，以避免为const char *数据构造QString对象。例如，假设str是一个QString，
```c++
    if (str == "auto" || str == "extern"
            || str == "static" || str == "register") {
        ...
    }
    //is much faster than
    if (str == QString("auto") || str == QString("extern")
            || str == QString("static") || str == QString("register")) {
        ...
    }
```
因为它不会构造四个临时QString对象，也不会对字符数据进行深度复制。
定义QT_NO_CAST_FROM_ASCII(如QString文档中解释的那样)的应用程序不能访问QString的const char * API。为了提供一种有效的方式来指定常量Latin-1字符串，Qt提供了QLatin1String，它只是对const char *的一个非常薄的包装。使用QLatin1String，上面的示例代码将变成
```c++
    if (str == QLatin1String("auto")
            || str == QLatin1String("extern")
            || str == QLatin1String("static")
            || str == QLatin1String("register") {
        ...
    }
```
这段代码的输入有点长，但是它提供了与第一个版本代码完全相同的好处，而且比使用QString::fromLatin1()转换Latin-1字符串更快。
由于使用了QString(QLatin1String)构造函数，QLatin1String可以在任何需要使用QString的地方使用。例如:
`QLabel *label = new QLabel(QLatin1String("MOD")， this);`
注意:如果您使用QLatin1String参数调用的函数实际上没有重载以接受QLatin1String，那么到QString的隐式转换将触发内存分配，这通常是您希望首先使用QLatin1String来避免的。在这些情况下，使用QStringLiteral可能是更好的选择。
参见QString、QLatin1Char、QStringLiteral和QT_NO_CAST_FROM_ASCII。
# 关于QString、QLatin1String、QStringLiteral
编码过程中，会不可避免地涉及到字面字符串，很多时候大家都是直接使用，没有太多考虑转换和效率的问题。

如果调用的函数支持`const char`这样的参数，那么直接使用字面字符串没有问题，这种函数一般都是极为常用的函数才会提供`const char`这样的重载，比如`QString`的`operator==`、`operator+`等等。

如果存在接受`QLatin1String`的参数，那么就可以提供`QLatin1String(“xxx”)`这样的参数，因为`QLatin1String`基本上就是`const char*`的一层薄薄的封装，所以这样做的效率也是挺高的。

但是，在只接受QString参数的函数，无论我们给一个字面字符串或`QLatin1String`，都会隐式构造一个临时的`QString`对象，构造这个对象需要在栈上申请一定的内存空间，然后把字符串拷贝过去，如果这样的调用比较多，那还是一笔不小的开销。此时，我们可以使用QStringLiteral来减少这个开销。

`QStringLiteral`其实是一个宏，展开来就是一个lambda函数的调用，该lambda函数内部使用了一个只读的静态变量保存了`QString`对象内存布局的POD对象，让这份数据保存在了程序的.rodata段。当代码运行到这的时候，实质就是对该lambda函数的调用，该函数返回了一个用上面所说的POD对象构造出来的QString对象，因为QString是隐式共享的，所以这里并没有发生前面所说的开销，就可以提高效率。

总结：
1. 支持const char*或者QLatin1String的地方使用对应的参数
2. 需要QString的地方，如果该QString不会修改的话，那使用QStringLiteral
3. 需要QString且该QString可能会被修改的话，还是直接使用QString或者隐式转换吧

# QCborStreamWriter
- QCborStreamWriter类是一个在单向流上操作的简单CBOR编码器。
- 这个类可用于快速将CBOR内容流直接编码到QByteArray或QIODevice。CBOR是简洁的二进制对象表示，是一种与JSON兼容的非常紧凑的二进制数据编码形式。它是由IETF约束的RESTful Environments (CoRE) WG创建的，它已经在许多新的rfc中使用了它。它将与CoAP协议一起使用。
- QCborStreamWriter提供了一个类似stax的API，类似于QXmlStreamWriter的API。它是相当低级的，需要一点CBOR编码的知识。要了解更简单的API，请参阅QCborValue，特别是编码函数QCborValue::toCbor()。
- QCborStreamWriter的典型用法是在目标QByteArray或QIODevice上创建对象，然后使用需要编码的类型调用append()重载之一。为了创建数组和映射，QCborStreamWriter提供了startArray()和startMap()重载，这些重载必须由相应的endArray()和endMap()函数终止。
- 以下示例编码了与此JSON内容等价的内容:
```c++
{   
    "label": "journald", 
    "autoDetect": false, 
    "condition": "libs.journald", 
    "output": [ "privateFeature" ] 
}
    writer.startMap(4);    // 4 elements in the map

    writer.append(QLatin1String("label"));
    writer.append(QLatin1String("journald"));

    writer.append(QLatin1String("autoDetect"));
    writer.append(false);

    writer.append(QLatin1String("condition"));
    writer.append(QLatin1String("libs.journald"));

    writer.append(QLatin1String("output"));
    writer.startArray(1);
    writer.append(QLatin1String("privateFeature"));
    writer.endArray();

    writer.endMap(); 
```
# QTcpServer
- QTcpServer类提供了一个基于tcp的服务器。
- 这个类使接受传入的TCP连接成为可能。您可以指定端口或让QTcpServer自动选择一个端口。您可以监听一个特定的地址或所有机器的地址。
- 调用listen()让服务器侦听传入的连接。然后，每当客户端连接到服务器时，就会发出newConnection()信号。
- 调用nextPendingConnection()接受挂起的连接作为已连接的QTcpSocket。该函数返回一个指向QAbstractSocket::ConnectedState中的QTcpSocket的指针，您可以使用该指针与客户端通信。
- 如果发生错误，serverError()返回错误的类型，可以调用errorString()来获取对发生的事情的人类可读的描述。
- 当侦听连接时，服务器正在侦听的地址和端口作为serverAddress()和serverPort()可用。
- 调用close()使QTcpServer停止侦听传入的连接。
- 尽管QTcpServer主要是为与事件循环一起使用而设计的，但也可以不使用事件循环而使用它。在这种情况下，您必须使用waitForNewConnection()，它将阻塞直到连接可用或超时。
- 另请参阅QTcpSocket、Fortune服务器示例、线程Fortune服务器示例、Loopback示例和Torrent示例。
  
# 演示如何为网络服务创建服务器。
- 此示例将与Fortune客户端示例或Blocking Fortune客户端示例一起运行。
- 它使用QTcpServer来接受传入的TCP连接，并使用一个简单的基于QDataStream的数据传输协议在关闭连接之前将fortune写入连接的客户机(来自fortune客户机示例)。
```c++
 class Server : public QDialog
 {
     Q_OBJECT

 public:
     explicit Server(QWidget *parent = nullptr);

 private slots:
     void sessionOpened();
     void sendFortune();

 private:
     QLabel *statusLabel = nullptr;
     QTcpServer *tcpServer = nullptr;
     QVector<QString> fortunes;
     QNetworkSession *networkSession = nullptr;
 };
```
服务器是使用一个只有一个插槽的简单类来实现的，用于处理传入的连接。
```c++
     tcpServer = new QTcpServer(this);
     if (!tcpServer->listen()) {
         QMessageBox::critical(this, tr("Fortune Server"),
                               tr("Unable to start the server: %1.")
                               .arg(tcpServer->errorString()));
         close();
         return;
     }
     QString ipAddress;
     QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();
     // use the first non-localhost IPv4 address
     for (int i = 0; i < ipAddressesList.size(); ++i) {
         if (ipAddressesList.at(i) != QHostAddress::LocalHost &&
             ipAddressesList.at(i).toIPv4Address()) {
             ipAddress = ipAddressesList.at(i).toString();
             break;
         }
     }
     // if we did not find one, use IPv4 localhost
     if (ipAddress.isEmpty())
         ipAddress = QHostAddress(QHostAddress::LocalHost).toString();
     statusLabel->setText(tr("The server is running on\n\nIP: %1\nport: %2\n\n"
                             "Run the Fortune Client example now.")
                          .arg(ipAddress).arg(tcpServer->serverPort()));
```
- 在其构造函数中，我们的服务器对象调用`QTcpServer::listen()`来设置一个QTcpServer来监听任意端口上的所有地址。In然后显示标签中选择的端口QTcpServer，以便用户知道fortune客户机应该连接到哪个端口。
```c++
 fortunes << tr("You've been leading a dog's life. Stay off the furniture.")
          << tr("You've got to think about tomorrow.")
          << tr("You will be surprised by a loud noise.")
          << tr("You will feel hungry again in another hour.")
          << tr("You might have mail.")
          << tr("You cannot kill time without injuring eternity.")
          << tr("Computers are not intelligent. They only think they are.");
```
我们的服务器生成一个随机财富列表，它可以发送到连接的客户端。
 `connect(tcpServer, &QTcpServer::newConnection, this, &Server::sendFortune);`
当客户端连接到我们的服务器时，QTcpServer将发出QTcpServer::newConnection()。反过来，这将调用我们的sendFortune()槽:
```c++
 void Server::sendFortune()
 {
     QByteArray block;
     QDataStream out(&block, QIODevice::WriteOnly);
     out.setVersion(QDataStream::Qt_5_10);

     out << fortunes[QRandomGenerator::global()->bounded(fortunes.size())];
```
这个槽的目的是从运气列表中随机选择一行，使用QDataStream将其编码为QByteArray，然后将其写入连接的套接字。这是使用QTcpSocket传输二进制数据的常用方法。首先，我们创建一个QByteArray和一个QDataStream对象，将bytearray传递给QDataStream的构造函数。然后我们显式地设置QDataStream的协议版本为QDataStream::Qt_4_0，以确保我们可以与未来版本的Qt的客户端通信(参见QDataStream::setVersion())。我们继续随机输入财富。
```c++
     QTcpSocket *clientConnection = tcpServer->nextPendingConnection();
     connect(clientConnection, &QAbstractSocket::disconnected,
             clientConnection, &QObject::deleteLater);
```
然后我们调用QTcpServer::nextPendingConnection()，它返回表示连接的服务器端的QTcpSocket。通过将QTcpSocket::disconnected()连接到QObject::deleteLater()，我们可以确保socket在断开连接后被删除。
```c++
     clientConnection->write(block);
     clientConnection->disconnectFromHost();
 }
```
编码后的财富是使用QTcpSocket::write()编写的，最后我们调用QTcpSocket::disconnectFromHost()，它将在QTcpSocket完成将财富写入网络后关闭连接。由于QTcpSocket是异步工作的，数据将在函数返回后写入，控制返回到Qt的事件循环。然后套接字将关闭，这将导致QObject::deleteLater()删除它。

# QTcpServer
- 这个类使接受传入的`TCP`连接成为可能。您可以指定端口或让`QTcpServer`自动选择一个端口。您可以监听一个特定的地址或所有机器的地址。
- 调用`listen()`让服务器侦听传入的连接。然后，每当客户端连接到服务器时，就会发出`newConnection()`信号。
- 调用`nextPendingConnection()`接受挂起的连接作为已连接的`QTcpSocket`。该函数返回一个指向`QAbstractSocket::ConnectedState`中的`QTcpSocket`的指针，您可以使用该指针与客户端通信。
- 如果发生错误，`serverError()`返回错误的类型，可以调用`errorString()`来获取对发生的事情的人类可读的描述。
- 当侦听连接时，服务器正在侦听的地址和端口作为`serverAddress()`和`serverPort()`可用。
- 调用`close()`使`QTcpServer`停止侦听传入的连接。
- 尽管`QTcpServer`主要是为与事件循环一起使用而设计的，但也可以不使用事件循环而使用它。在这种情况下，您必须使用`waitForNewConnection()`，它将阻塞直到连接可用或超时。
  
# QUdpSocket
UDP(用户数据报协议)是一种轻量级、不可靠、面向数据报、无连接的协议。它可以在可靠性不重要的情况下使用。QUdpSocket是QAbstractSocket的子类，允许发送和接收UDP数据报。
使用该类最常见的方法是使用bind()绑定到一个地址和端口，然后调用writeDatagram()和readDatagram() / receiveDatagram()来传输数据。如果您想使用标准的QIODevice函数read()、readLine()、write()等，您必须首先通过调用connectToHost()将套接字直接连接到对等体。
每次将数据报写入网络时，套接字都会发出bytesWritten()信号。如果你只是想发送数据报，你不需要调用bind()。
readyRead()信号在数据报到达时发出。在这种情况下，hasPendingDatagrams()返回true。调用pendingDatagramSize()来获取第一个待处理数据报的大小，并调用readDatagram()或receiveDatagram()来读取它。
注意:当你接收到readyRead()信号时，一个传入的数据报应该被读取，否则这个信号将不会被发送到下一个数据报。
例子:

void Server::initSocket()
{
    udpSocket = new QUdpSocket(this);
    udpSocket->bind(QHostAddress::LocalHost, 7755);

    connect(udpSocket, &QUdpSocket::readyRead,
            this, &Server::readPendingDatagrams);
}

void Server::readPendingDatagrams()
{
    while (udpSocket->hasPendingDatagrams()) {
        QNetworkDatagram datagram = udpSocket->receiveDatagram();
        processTheDatagram(datagram);
    }
}
QUdpSocket also supports UDP multicast. Use joinMulticastGroup() and leaveMulticastGroup() to control group membership, and QAbstractSocket::MulticastTtlOption and QAbstractSocket::MulticastLoopbackOption to set the TTL and loopback socket options. Use setMulticastInterface() to control the outgoing interface for multicast datagrams, and multicastInterface() to query it.

With QUdpSocket, you can also establish a virtual connection to a UDP server using connectToHost() and then use read() and write() to exchange datagrams without specifying the receiver for each datagram.

The Broadcast Sender, Broadcast Receiver, Multicast Sender, and Multicast Receiver examples illustrate how to use QUdpSocket in applications.

# QObject::Sender()
当某一个Object emit一个signal的时候，它就是一个sender,系统会记录下当前是谁emit出这个signal的，所以你在对应的slot里就可以通过 sender()得到当前是谁invoke了你的slot，对应的是QObject->d->sender.

有可能多个Object的signal会连接到同一个signal(例如多个Button可能会connect到一个slot函数onClick()),因此这是就需要判断到底是哪个Object emit了这个signal，根据sender的不同来进行不同的处理

QObject::Sender()返回发送信号的对象的指针，返回类型为QObject *

示例代码：

QTimeEdit *editor = qobject_cast<QTimeEdit *>(sender());


# QLocalSocket
- QLocalSocket类提供了一个本地套接字。
- 在Windows上，这是一个命名管道，在Unix上，这是一个本地域套接字。
- 如果发生错误，socketError()返回错误的类型，可以调用errorString()来获取对发生的事情的人类可读的描述。
- 尽管QLocalSocket是为与事件循环一起使用而设计的，但也可以不使用事件循环而使用它。在这种情况下，必须使用waitForConnected()、waitForReadyRead()、waitForBytesWritten()和waitForDisconnected()，它们会阻塞，直到操作完成或超时超时。

# QLocalServer
- QLocalServer类提供了一个基于本地套接字的服务器。
- 这个类使接受传入的本地套接字连接成为可能。
- 调用listen()让服务器在指定的密钥上开始侦听传入的连接。然后，每当客户端连接到服务器时，就会发出newConnection()信号。
- 调用nextPendingConnection()接受挂起的连接作为已连接的QLocalSocket。该函数返回一个指向QLocalSocket的指针，该指针可用于与客户机通信。
- 如果发生错误，serverError()返回错误的类型，可以调用errorString()来获取对发生的事情的人类可读的描述。
- 当侦听连接时，服务器正在侦听的名称可以通过serverName()获得。
- 调用close()使QLocalServer停止侦听传入的连接。
- 尽管QLocalServer是为与事件循环一起使用而设计的，但也可以不使用事件循环而使用它。在这种情况下，您必须使用waitForNewConnection()，它将阻塞直到连接可用或超时。