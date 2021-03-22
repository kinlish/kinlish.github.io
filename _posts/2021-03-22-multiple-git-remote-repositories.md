---
title: Git設定多個repositories
author: Kinlish
date: 2021-03-22 00:00:00 +0800
categories: [Git, scm]
tags: [git, remote, multiple]
pin: true
---

使用兩個或多個Git Repositories能夠同時推送多個遠端與從多個遠端倉儲取回變更源碼。
在這裡首先將設定多個遠端，使你可以使用一個 `git push` 命令即可推送到多個遠端倉儲。

## Prerequisites

* 了解 `git init`、`git pull`、`git commit`、`git push`
* 擁有多於一個遠端git repositories

## 加入多個遠端

當你使用 `git init` 初始化本地倉儲後，通常都會與遠端倉儲同步。要能夠與遠端倉儲同步，需要先指定一個可存取的 git repository。

首先加入一個遠端repo
```shell
# 新增遠端repo語法
git remote add $REMOTE_ID $REMOTE_URL
```

依照慣例，原始/主要的 repo REMOTE_ID 稱為 `origin`。以下是實際的例子：
```shell
# 加入原始/主要的遠端repo，REMOTE_ID 為 origin
git remote add origin git@github.com:kinlish/test.git
# 加入另一個具名的遠端repo，REMOTE_ID 為 upstream
git remote add upstream git@crossx.com:kinlish/test.git
```

上面的範例，分別新增了位於 github.com 的遠端倉儲名為 test 的專案與位於 crossx.com 的遠端倉儲名為 test 的專案，他們個別有唯一識別的ID `origin` 與 `upstream`。

## 設定個別分支的遠端
雖然我們可以加入多個遠端repo進行多遠端版控，但也能設定特定分支推送到設定的遠端，如下示例：
```shell
# 建立 dev 分支並切換過去
git checkout -b dev
# 設定 dev 分支推送到 upstream 遠端的 rdev 分支
git push -u upstream rdev
```

上面的範例設定 dev 分支推送到 upstream 遠端的 rdev 分支，未來在本地 dev 分支變更推送後就僅會同步到 upstream/rdev 分支。

## 修改remote URL
如果想要修改已經設定的遠端倉儲URL，可以進行如下操作：
```shell
# 語法為 git remote set-url $REMOTE_ID $REMOTE_URL
git remote set-url upstream git@internal.gitea:kinlish/test.git
```

## 列出遠端倉儲
要檢視所有的遠端倉儲，可以鍵入如下：
```console
$ git remote -v
upstream	git@internal.gitea:kinlish/test.git (fetch)
upstream	git@internal.gitea:kinlish/test.git (push)
origin      git@github.com:kinlish/test.git (fetch)
origin	    git@github.com:kinlish/test.git (push)
```

## 移除遠端倉儲
如果已經加入的遠端倉儲不再需要，可以鍵入如下移除：
```shell
# 假設要移除遠端 upstream 
git remote remove upstream
```

## 推送到多個遠端倉儲
現在我們能夠將一個專案的遠端倉儲設定為多個，並且個別的分支能夠推送到自訂的遠端，接下來我們可以設定使用一次 `git push` 就推送至多個遠端倉儲。
為此，選擇一個將引用所有遠端倉儲的 `$REMOTE_ID`，我們將它命名為 `all`，請見如下示例：
```shell
# 建立一個命名為 all 的 $REMOTE_ID，主要倉儲設定為 github.com
git remote add all git@github.com:kinlish/test.git
# 加入推送的遠端倉儲url
git remote set-url --add --push all git@github.com:/test.git
# 加入另一個推送的遠端倉儲url
git remote set-url --add --push all git@internal.gitea:kinlish/test.git
```

如果不想要額外建立 all 的 $REMOTE_ID，第一步略過並在之後使用 origin 取代 all 即可。
現在就能使用一道命令就推送到多個遠端倉儲囉！
```shell
# 語法：git push $REMOTE_ID $BRANCH
git push all master
# 如果使用慣例的 `origin` $REMOTE_ID，那麼在推送時就更簡單
git push
```

## 從多個遠端拉取
`git pull` 無法用於從多個遠端拉取，但我們可以使用 `fetch`，請見如下：
```console
$ git fetch --all
Fetching origin
Fetching gitea
```

這將會從所有遠端取回版本資訊，接著我們可以使用如下命令切換到特定分支的最新版本
```console
$ git checkout BRANCH
$ git reset --hard $REMOTE_ID/BRANCH
```
