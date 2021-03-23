---
title: Ubuntu 從封存檔手動安裝 jdk 及設定 alternative(切換版本)
author: Kinlish
date: 2021-03-21 00:00:00 +0800
categories: [Java]
tags: [jdk, install, alternative]
pin: true
---

安裝jdk似乎是再簡單不過了，但若是想從封存檔來源安裝並能夠納入替代管理清單，那麼需要多一點步驟。
本文介紹如何在Ubuntu中以 `apt` 安裝及使用封存檔案安裝的方式設定替代管理清單 `alternative`並且切換欲使用版本。

## 檢查已安裝配置的 jdk/jre 版本
```console
$ java -version
$ javac -version
```
鍵入如上命令，若事前未安裝則會提示可選的安裝版本及指令，若已安裝則顯示已設定的java版本資訊。

## 使用 apt 安裝
```console
$ sudo apt install default-jdk
```
這裡選擇安裝 default-jdk，可依自身需求調整，通常使用此法安裝後也會自動的設定好 alternatives，幾乎能開始進行開發作業了，但若是有使用到讀取 JAVA_HOME 環境變數的程式那麼後面將會說明方法。

## 從封存檔案安裝
通常藉由 apt 安裝的 jdk 版本比較舊，而需要使用更新的功能則需要手動下載封存檔案進行安裝，例如從[Oracle](https://www.oracle.com/java/technologies/)下載jdk安裝，及其設定的步驟。
```console
$ #將封存檔解壓縮至目的位置
$ sudo tar xzf jdk-16_linux-x64_bin.tar.gz -C /usr/lib

$ #將 JAVA_HOME 環境變數寫入 /etc/profile
$ sudo echo 'export JAVA_HOME=/usr/lib/jdk-16' > /etc/profile.d/java_path.sh

$ #重新設定一次環境，匯出 JAVA_HOME 環境變數
$ source /etc/profile; source ~/.bashrc
```

### 封存檔安裝設定 alternatives
如上的步驟，我們將 jdk 解壓縮並設定了 JAVA_HOME 環境變數，現在使用 alternative 安裝至系統並連結至 `/usr/bin`，而系統PATH環境變數基本上都會引入 `/usr/bin`，並且可以利用它進行多個版本切換（不同於 [virtualenv](https://virtualenv.pypa.io/en/latest/)），語法如下：
```shell
update-alternatives --install <link> <name> <path> <priority>
```

以下是安裝 `java` 和 `javac` 的範例（先設定好 JAVA_HOME 環境變數）：
```console
$ #設定java
$ sudo update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 500
$ #設定javac
$ sudo update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 500
```
注意最後的優先權數字，那是代表著當設定的程式路徑不存在時，選擇由優先權高的替補。

## 由 alternative 切換版本
現在我們在系統藉由 apt 安裝 default-jdk 及透過封存檔案安裝 oracle jdk，可以查詢已經安裝的版本：
```console
$ sudo update-alternatives --list java
/usr/lib/jdk-16/bin/java
/usr/lib/jvm/java-11-openjdk-amd64/bin/java
```
安裝多於一個版本的時候可以使用如下方式選擇使用的版本：
```console
$ sudo update-alternatives --config java
[sudo] password for charlie: 
There are 2 choices for the alternative java (providing /usr/bin/java).

  Selection    Path                                         Priority   Status
------------------------------------------------------------
* 0            /usr/lib/jvm/java-11-openjdk-amd64/bin/java   1111      auto mode
  1            /usr/lib/jdk-16/bin/java                      500       manual mode
  2            /usr/lib/jvm/java-11-openjdk-amd64/bin/java   1111      manual mode

Press <enter> to keep the current choice[*], or type selection number:
```
見上面的輸出，現在系統指定到的版本是 0 編號，若要切換至 jdk-16 版本就鍵入 1 進行切換。

## 由 alternative 移除版本
若安裝的版本不再需要了，由 alternatives 移除方式語法如下：
```console
$ sudo update-alternatives -remove <name> <path>
```
以下是移除藉由 apt 安裝的 jdk 的例子:
```console
$ sudo update-alternatives --remove java /usr/lib/jvm/java-11-openjdk-amd64/bin/java
```
透過 apt 安裝的套件經過 alternatives 移除僅將替代連結移除，不會將安裝的套件移除，若要清除它執行以下：
```console
$ #若不知先前安裝的版本，可先查詢藉由 apt 安裝的jdk
$ sudo apt list --installed | grep jdk
default-jdk-headless/focal,now 2:1.11-72 amd64 [installed,automatic]
default-jdk/focal,now 2:1.11-72 amd64 [installed]
openjdk-11-jdk-headless/focal-updates,focal-security,now 11.0.10+9-0ubuntu1~20.04 amd64 [installed,automatic]
openjdk-11-jdk/focal-updates,focal-security,now 11.0.10+9-0ubuntu1~20.04 amd64 [installed,automatic]
openjdk-11-jre-headless/focal-updates,focal-security,now 11.0.10+9-0ubuntu1~20.04 amd64 [installed,automatic]
openjdk-11-jre/focal-updates,focal-security,now 11.0.10+9-0ubuntu1~20.04 amd64 [installed,automatic]

$ #移除已安裝的套件
$ sudo apt autoremove default-jdk
```

另外要注意的是，藉由 alternatives 安裝的 jdk 不會設定 JAVA_HOME 環境變數，需要再行調整。
