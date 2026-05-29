# Примеры сборки и наслаивания

Ниже список последовательно собираемых образов для различных целей. Каждый следущий слой собирается поверх предыдущего. В Dockerfile базовый образ указывается с помощью переменных BASE_IMAGE и BASE_TAG.

## Запуск 1С

* client
* s6-overlay
* client-vnc

## 1С и OneScript

* client
* s6-overlay
* client-vnc
* oscript

## 1С + OneScript для запуска VA

* client
* s6-overlay
* client-vnc
* oscript
* test-utils

## SonarScanner (анализ кода, без vnc)

* client
* jdk
* sonar-scanner

Реализовано в скриптах:

* [build-sonar-scanner.sh](build-sonar-scanner.sh)
* [build-sonar-scanner.bat](build-sonar-scanner.bat)

## 1C как Jenkins агент

* client
* s6-overlay
* client-vnc
* jdk
* swarm-jenkins-agent или k8s-jenkins-agent

## 1С + OneScript как Jenkins агент

* client
* s6-overlay
* client-vnc
* oscript
* jdk
* swarm-jenkins-agent или k8s-jenkins-agent

## 1С + OneScript как Jenkins агент для запуска тестов

* client
* s6-overlay
* client-vnc
* oscript
* jdk
* test-utils
* swarm-jenkins-agent или k8s-jenkins-agent

Реализовано в скриптах:

* [build-base-swarm-jenkins-agent.sh](build-base-swarm-jenkins-agent.sh)
* [build-base-swarm-jenkins-agent.bat](build-base-swarm-jenkins-agent.bat)
* [build-base-k8s-jenkins-agent.sh](build-base-k8s-jenkins-agent.sh)

## EDT

* edt

Реализовано в скриптах:

* [build-edt.sh](build-edt.sh)
* [build-edt.bat](build-edt.bat)

## EDT как Jenkins агент

* edt
* s6-overlay
* swarm-jenkins-agent или k8s-jenkins-agent

Реализовано в скриптах:

* [build-edt-swarm-agent.sh](build-edt-swarm-agent.sh)
* [build-edt-swarm-agent.bat](build-edt-swarm-agent.bat)
* [build-edt-k8s-agent.sh](build-edt-k8s-agent.sh)

## OneScript как Jenkins агент

* oscript поверх library/eclipse-temurin:17
* s6-overlay
* swarm-jenkins-agent или k8s-jenkins-agent

Реализовано в скриптах:

* [build-oscript-swarm-agent.sh](build-oscript-swarm-agent.sh)
* [build-oscript-swarm-agent.bat](build-oscript-swarm-agent.bat)
* [build-oscript-k8s-agent.sh](build-oscript-k8s-agent.sh) # TODO

## Сервер хранилища + Apache

* crs
* crs-apache
