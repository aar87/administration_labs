# Основы администрирования информационных систем

## 1. Подключение операционной системы Ubuntu 22.04
Для создания воспользуемся Docker`ом.
```shell
docker container run -d -it --name ubuntu --rm ubuntu:22.04
```
В процессе подключения будет скачивание образа ubuntu:22.04.
Скачанный однажды образ может быть переиспользован при создании аналогичных контейнеров.
Ниже лог командной строки zshell.
```commandline
Unable to find image 'ubuntu:22.04' locally
22.04: Pulling from library/ubuntu
6414378b6477: Pull complete 
Digest: sha256:0e5e4a57c2499249aafc3b40fcd541e9a456aab7296681a3994d631587203f97
Status: Downloaded newer image for ubuntu:22.04
a091edd197f33cd0afe6afefa51d8d27e5ecef31979a14ecb5d19265768986bc
```
## 2. Настроить основные параметры ОС
С помощью команды ниже находим 
```shell
docker ps
```
```commandline
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS         PORTS     NAMES
a091edd197f3   ubuntu:22.04   "/bin/bash"   9 minutes ago   Up 9 minutes             ubuntu
```
После определения ID и Name можно войти в запущенный контейнер.
```shell
docker exec -it a091edd197f3 bash
```
```commandline
root@a091edd197f3:/# 
```
Выполнив, мы попадаем в командную строку запущенного контейнера.
Для операционной системы Ubuntu существует пакетный менеджер apt.
С помощью данного пакета обновим локальный репозиторий, который отвечает
за информацию о доступных обновлениях и дополнительных приложений для установки.
```shell
apt update
```
```commandline
Get:1 http://archive.ubuntu.com/ubuntu jammy InRelease [270 kB]
Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
Get:3 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [2452 kB]
Get:4 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
Get:5 http://archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
Get:6 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [3323 kB]
Get:7 http://archive.ubuntu.com/ubuntu jammy/multiverse amd64 Packages [266 kB]
Get:8 http://archive.ubuntu.com/ubuntu jammy/universe amd64 Packages [17.5 MB]          
Get:9 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [1223 kB]   
Get:10 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [45.2 kB]
Get:11 http://archive.ubuntu.com/ubuntu jammy/main amd64 Packages [1792 kB]                                                                                                                                                       
Get:12 http://archive.ubuntu.com/ubuntu jammy/restricted amd64 Packages [164 kB]                                                                                                                                                  
Get:13 http://archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [52.2 kB]                                                                                                                                         
Get:14 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1512 kB]                                                                                                                                           
Get:15 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [2734 kB]                                                                                                                                               
Get:16 http://archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 Packages [3413 kB]                                                                                                                                         
Get:17 http://archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [81.4 kB]                                                                                                                                             
Get:18 http://archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [33.7 kB]                                                                                                                                         
Fetched 35.2 MB in 8s (4226 kB/s)                                                                                                                                                                                                 
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
```
Успешно обновилась информация о локальных репозиториях запущенного контейнера.
## 3. Настроить системный монитор для контроля параметров
Установим программу для просмотра состояния операционной системы
```shell
apt install htop
```
```commandline
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  libnl-3-200 libnl-genl-3-200
Suggested packages:
  lm-sensors lsof strace
The following NEW packages will be installed:
  htop libnl-3-200 libnl-genl-3-200
0 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
Need to get 200 kB of archives.
After this operation, 589 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://archive.ubuntu.com/ubuntu jammy/main amd64 libnl-3-200 amd64 3.5.0-0.1 [59.1 kB]
Get:2 http://archive.ubuntu.com/ubuntu jammy/main amd64 libnl-genl-3-200 amd64 3.5.0-0.1 [12.4 kB]
Get:3 http://archive.ubuntu.com/ubuntu jammy/main amd64 htop amd64 3.0.5-7build2 [128 kB]
Fetched 200 kB in 0s (473 kB/s)
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package libnl-3-200:amd64.
(Reading database ... 4393 files and directories currently installed.)
Preparing to unpack .../libnl-3-200_3.5.0-0.1_amd64.deb ...

Progress: [  0%] [.............................................................................................................................................................................................................] 
Unpacking libnl-3-200:amd64 (3.5.0-0.1) .......................................................................................................................................................................................] 

Selecting previously unselected package libnl-genl-3-200:amd64.................................................................................................................................................................] 
Preparing to unpack .../libnl-genl-3-200_3.5.0-0.1_amd64.deb ...

Unpacking libnl-genl-3-200:amd64 (3.5.0-0.1) ...#################..............................................................................................................................................................] 

Selecting previously unselected package htop.####################################..............................................................................................................................................] 
Preparing to unpack .../htop_3.0.5-7build2_amd64.deb ...

Unpacking htop (3.0.5-7build2) ...##############################################################...............................................................................................................................] 

Setting up libnl-3-200:amd64 (3.5.0-0.1) ...####################################################################...............................................................................................................] 

Progress: [ 54%] [##############################################################################################################...............................................................................................] 
Setting up libnl-genl-3-200:amd64 (3.5.0-0.1) ...###############################################################################################...............................................................................] 

Progress: [ 69%] [#############################################################################################################################################................................................................] 
Setting up htop (3.0.5-7build2) ...############################################################################################################################################................................................] 

Progress: [ 85%] [#############################################################################################################################################################################................................] 
Processing triggers for libc-bin (2.35-0ubuntu3.8) ...#########################################################################################################################################################................]
```
Далее можно запустить и посмотреть состояние системы
```shell
htop
```
```commandline
    0[|||                                                                                                2.0%]   Tasks: 3, 0 thr; 1 running
    1[|                                                                                                  0.7%]   Load average: 1.02 1.02 1.00 
    2[||                                                                                                 1.4%]   Uptime: 20:05:42
  Mem[|||||||                                                                                      823M/1.94G]
  Swp[                                                                                               0K/1024M]

  PID USER      PRI  NI  VIRT   RES   SHR S CPU%-MEM%   TIME+  Command
    1 root 20   0  4496  3372  3044 S  0.0  0.2  0:00.04 /bin/bash
   12 root       20   0  4632  3708  3144 S  0.0  0.2  0:00.03 bash
  267 root       20   0  5248  4212  3248 R  0.0  0.2  0:00.02 htop

```
## 4. Настроить сетевой монитор для контроля парамеров
Для сетевого мониторинга нужно уистановить утилиту мониторинга сетевой активности iftop.
```shell
apt install iftop
```
```commandline
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  dbus libapparmor1 libdbus-1-3 libexpat1 libpcap0.8
Suggested packages:
  default-dbus-session-bus | dbus-session-bus
The following NEW packages will be installed:
  dbus iftop libapparmor1 libdbus-1-3 libexpat1 libpcap0.8
0 upgraded, 6 newly installed, 0 to remove and 0 not upgraded.
Need to get 658 kB of archives.
After this operation, 2143 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 libapparmor1 amd64 3.0.4-2ubuntu2.4 [39.7 kB]
Get:2 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 libdbus-1-3 amd64 1.12.20-2ubuntu4.1 [189 kB]
Get:3 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 libexpat1 amd64 2.4.7-1ubuntu0.4 [91.2 kB]
Get:4 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 dbus amd64 1.12.20-2ubuntu4.1 [158 kB]
Get:5 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpcap0.8 amd64 1.10.1-4ubuntu1.22.04.1 [145 kB]
Get:6 http://archive.ubuntu.com/ubuntu jammy/universe amd64 iftop amd64 1.0~pre4-7 [35.6 kB]
Fetched 658 kB in 1s (1127 kB/s)
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package libapparmor1:amd64.
(Reading database ... 4422 files and directories currently installed.)
Preparing to unpack .../0-libapparmor1_3.0.4-2ubuntu2.4_amd64.deb ...

Progress: [  0%] [.............................................................................................................................................................................................................] 
Unpacking libapparmor1:amd64 (3.0.4-2ubuntu2.4) ...............................................................................................................................................................................] 

Selecting previously unselected package libdbus-1-3:amd64......................................................................................................................................................................] 
Preparing to unpack .../1-libdbus-1-3_1.12.20-2ubuntu4.1_amd64.deb ...

Unpacking libdbus-1-3:amd64 (1.12.20-2ubuntu4.1) ..............................................................................................................................................................................] 

Selecting previously unselected package libexpat1:amd64........................................................................................................................................................................] 
Preparing to unpack .../2-libexpat1_2.4.7-1ubuntu0.4_amd64.deb ...

Unpacking libexpat1:amd64 (2.4.7-1ubuntu0.4) ...###########....................................................................................................................................................................] 

Selecting previously unselected package dbus.######################............................................................................................................................................................] 
Preparing to unpack .../3-dbus_1.12.20-2ubuntu4.1_amd64.deb ...

Unpacking dbus (1.12.20-2ubuntu4.1) ...####################################....................................................................................................................................................] 

Selecting previously unselected package libpcap0.8:amd64.##########################............................................................................................................................................] 
Preparing to unpack .../4-libpcap0.8_1.10.1-4ubuntu1.22.04.1_amd64.deb ...

Unpacking libpcap0.8:amd64 (1.10.1-4ubuntu1.22.04.1) ...###################################....................................................................................................................................] 

Selecting previously unselected package iftop.######################################################...........................................................................................................................] 
Preparing to unpack .../5-iftop_1.0~pre4-7_amd64.deb ...

Unpacking iftop (1.0~pre4-7) ...############################################################################...................................................................................................................] 

Setting up libexpat1:amd64 (2.4.7-1ubuntu0.4) ...###################################################################...........................................................................................................] 

Progress: [ 52%] [##########################################################################################################...................................................................................................] 
Setting up libapparmor1:amd64 (3.0.4-2ubuntu2.4) ...################################################################################...........................................................................................] 

Progress: [ 60%] [###########################################################################################################################..................................................................................] 
Setting up libdbus-1-3:amd64 (1.12.20-2ubuntu4.1) ...################################################################################################..........................................................................] 

Progress: [ 68%] [###########################################################################################################################################..................................................................] 
Setting up dbus (1.12.20-2ubuntu4.1) ...#############################################################################################################################..........................................................] 

Progress: [ 76%] [###########################################################################################################################################################..................................................] 
Setting up libpcap0.8:amd64 (1.10.1-4ubuntu1.22.04.1) ...#############################################################################################################################.........................................] 

Progress: [ 84%] [############################################################################################################################################################################.................................] 
Setting up iftop (1.0~pre4-7) ...#####################################################################################################################################################################.........................] 

Progress: [ 92%] [############################################################################################################################################################################################.................] 
Processing triggers for libc-bin (2.35-0ubuntu3.8) ...################################################################################################################################################################.........] 
```
После установки можно запустить утилиту и проверить сетевую активность
```shell
iftop
```
```commandline
                                             12.5Kb                                       25.0Kb                                        37.5Kb                                       50.0Kb                                  62.5Kb
└─┴─┴─┴─┴──
























──
TX:             cum:      0B    peak:      0b                                                                                                                                                      rates:      0b      0b      0b
RX:                       0B               0b                                                                                                                                                                  0b      0b      0b
TOTAL:                    0B               0b                                                                                                                                                                  0b      0b      0b 
```
Сетевой активность внутри контейнера не обнаружено.
После закрытия iftop будет такжа показана некоторая информация
```commandline
interface: eth0
IP address is: 172.17.0.2
MAC address is: **:**:**:**:**:**
```
Для имитации сетевой активности запустим ubuntu с открытым внешнем портом, по которому можно запросить сервер.
```shell
docker container run -d -p 8080:8080 -it --name ubuntu --rm ubuntu:22.04
```
```commandline
CONTAINER ID   IMAGE          COMMAND       CREATED          STATUS          PORTS                                       NAMES
f3ea897d248f   ubuntu:22.04   "/bin/bash"   37 seconds ago   Up 35 seconds   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   ubuntu
```
Перейдем в созданный контейнер. По аналогии с пунктом 2.
Заново обновим apt и установим iftop, т.к. в новом контейнере все чистого листа.
Запустим iftop
```shell
iftop
```
После запуска нужно из локального ПК вне контейнера сделать сетевой запрос локального хоста (localhost) для порта 8080.
Варианты:
1) Браузер http://localhost:8080
2) curl http://localhost:8080
```commandline
                                             12.5Kb                                       25.0Kb                                        37.5Kb                                       50.0Kb                                  62.5Kb
└─┴─┴─┴─┴──
f3ea897d248f                                                                                        => 192.168.65.5                                                                                            0b      0b     29b
                                                                                                    <=                                                                                                         0b      0b     29b
f3ea897d248f                                                                                        => 172.17.0.1                                                                                              0b      0b      8b
                                                                                                    <=                                                                                                         0b      0b     13b











──
TX:             cum:    180B    peak:    560b                                                                                                                                                      rates:      0b      0b     38b
RX:                     200B             560b                                                                                                                                                                  0b      0b     42b
TOTAL:                  380B            1.09Kb                                                                                                                                                                 0b      0b     80b
```
В сетевом мониторе видим активность.

## Заключение
С помощью docker очень удобно запускать легковесные, быстроразворачиваемые системы.
В частности можно поднимать локальные сервера и разбираться с настройками без необходимости покупать VPS.
Конечно в большинстве случаем конфигурация, пакеты и настройки серверов очень похожи. Это предусмотрено в docker и
может быть настроен Dockerfile, который позволяет создать шаблон для сборки контейнера и автоматически при поднятии
выполнить нужные команды: обновить пакетный менеджер (apt), установить монитор и git.

