# Дипломный практикум в Yandex.Cloud - Вдовин Вадим

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

--- 

## Решение

1. Запускаем команду terraform apply.

Создаётся вся облачная инфраструктура:

Выполним команду terraform init:

![1](https://github.com/user-attachments/assets/32cebd30-49f2-4e81-8db0-88c8dab2969e)

#### Выполним команду terraform apply:

![2](https://github.com/user-attachments/assets/7b12d1d1-21fa-4e84-8ad5-d0e8cade1a29)           

![3](https://github.com/user-attachments/assets/cd5feb9b-2c69-4f35-bd6e-b087fac15409)

![4](https://github.com/user-attachments/assets/cefc2e18-f796-41a3-87fd-a40b0500cb04)

![5](https://github.com/user-attachments/assets/68985101-e9be-49d6-b811-f036d154c5e0)

### Загружаем файл состояния tdstate, после развёртывания всей инфраструктуры:

![6](https://github.com/user-attachments/assets/5c941f6b-6bfd-4747-a6ac-341a287c441d)


### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

## Решение:

### Для развертывания будем использовать kubespray.

Склонируем репозиторий:
```
git clone https://github.com/kubernetes-sigs/kubespray.git
```

При создании инфраструктуры мы создали динамический hosts.yaml файл

Воспользуемся этим hosts.yaml файлом и плайбуков в kubespray:
```
ansible-playbook -i /home/msi/diplom/ansible/inventory/hosts.yaml cluster.yml -b
```
#### Зайдём на master и проверим:

```
root@master:/home/ubuntu# sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS        AGE
kube-system   calico-kube-controllers-6c7b7dc5d8-bh7ts   1/1     Running   0               3m53s
kube-system   calico-node-kn76t                          1/1     Running   0               5m16s
kube-system   calico-node-rtg4c                          1/1     Running   0               5m16s
kube-system   calico-node-xsn2z                          1/1     Running   0               5m16s
kube-system   coredns-69db55dd76-6xlr6                   1/1     Running   0               2m47s
kube-system   coredns-69db55dd76-bzmpp                   1/1     Running   0               2m39s
kube-system   dns-autoscaler-6f4b597d8c-pph6z            1/1     Running   0               2m40s
kube-system   kube-apiserver-master                      1/1     Running   1               8m21s
kube-system   kube-controller-manager-master             1/1     Running   2 (7m46s ago)   8m21s
kube-system   kube-proxy-98q64                           1/1     Running   0               6m57s
kube-system   kube-proxy-gwdh8                           1/1     Running   0               6m58s
kube-system   kube-proxy-mhr57                           1/1     Running   0               6m57s
kube-system   kube-scheduler-master                      1/1     Running   1               8m21s
kube-system   nginx-proxy-node1                          1/1     Running   0               6m56s
kube-system   nginx-proxy-node2                          1/1     Running   0               7m6s
kube-system   nodelocaldns-sfglk                         1/1     Running   0               2m38s
kube-system   nodelocaldns-wbspn                         1/1     Running   0               2m38s
kube-system   nodelocaldns-wl87w                         1/1     Running   0               2m38s
```

#### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---

## Решение:

#### Подготовил приложение.

[index.html](https://github.com/V4d1M63/netology-diplom/blob/main/applications/index.html)

[Dockerfile](https://github.com/V4d1M63/netology-diplom/blob/main/applications/Dockerfile)

#### Соберём образ командой: docker build -t bbb8c2e28d7d/applications:1.0 .

```
root@vm-mint:/home/msi/diplom/applications# docker build -t bbb8c2e28d7d/applications:1.0 .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  3.584kB
Step 1/3 : FROM nginx:1.20
 ---> 0584b370e957
Step 2/3 : WORKDIR /usr/share/nginx/html
 ---> Running in 9311527e261f
Removing intermediate container 9311527e261f
 ---> c075e569bcb3
Step 3/3 : COPY index.html /usr/share/nginx/html/
 ---> 7abaaecf2a28
Successfully built 7abaaecf2a28
Successfully tagged bbb8c2e28d7d/applications:1.0
```

#### Запускаем контейнер: docker run -d -p 8080:80 bbb8c2e28d7d/applications:1.0

```
root@vm-mint:/home/msi/diplom/applications# docker run -d -p 8080:80 bbb8c2e28d7d/applications:1.0
a4af36b6e9c813b1b9ea4be86845f7e1cf417b6e969f122db3aa12fbd158ca4f

root@vm-mint:/home/msi/diplom/applications# docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS         PORTS                  NAMES
a4af36b6e9c8   bbb8c2e28d7d/applications:1.0   "/docker-entrypoint.…"   11 seconds ago   Up 9 seconds   0.0.0.0:8080->80/tcp   elated_blackburn
```

![7](https://github.com/user-attachments/assets/1354b4d2-a39e-4129-acd2-a64674268dfe)

#### Загружаем в Dockerhub: docker push bbb8c2e28d7d/applications:1.0

```
root@vm-mint:/home/msi/diplom/applications# docker push bbb8c2e28d7d/applications:1.0
The push refers to repository [docker.io/bbb8c2e28d7d/applications]
5e62a8997aa9: Pushed 
07ef16952879: Mounted from library/nginx 
881700cb7ab2: Mounted from library/nginx 
4f49c6d6dd07: Mounted from library/nginx 
a64d597d6b14: Mounted from library/nginx 
c2a3d4a53f9a: Mounted from library/nginx 
fd95118eade9: Mounted from library/nginx 
1.0: digest: sha256:1cd8e8edfc6b004e9e276c43fdfc75c93815e12cb7bdec67da565a1a1bf3f316 size: 1777
```

![8](https://github.com/user-attachments/assets/c05de34c-1e25-4c74-9d7d-75c4c68b1b2d)

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.
---

## Решение:

### Развернём систему мониторинга с помощью Kube-Prometheus.

#### Зайдёт на Master и склонируем репозиторий:

```
root@master:/home/ubuntu# git clone https://github.com/prometheus-operator/kube-prometheus.git
Cloning into 'kube-prometheus'...
remote: Enumerating objects: 19433, done.
remote: Counting objects: 100% (6502/6502), done.
remote: Compressing objects: 100% (490/490), done.
remote: Total 19433 (delta 6312), reused 6015 (delta 6011), pack-reused 12931
Receiving objects: 100% (19433/19433), 10.32 MiB | 13.09 MiB/s, done.
Resolving deltas: 100% (13244/13244), done.

```

#### Переходим в каталог с kube-prometheus и развертываем контейнеры:

<details>
<summary>Вывод текста</summary>

root@master:/home/ubuntu/kube-prometheus# sudo kubectl apply --server-side -f manifests/setup
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusagents.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/scrapeconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com serverside-applied
namespace/monitoring serverside-applied

root@master:/home/ubuntu/kube-prometheus# sudo kubectl apply -f manifests/
alertmanager.monitoring.coreos.com/main created
networkpolicy.networking.k8s.io/alertmanager-main created
poddisruptionbudget.policy/alertmanager-main created
prometheusrule.monitoring.coreos.com/alertmanager-main-rules created
secret/alertmanager-main created
service/alertmanager-main created
serviceaccount/alertmanager-main created
servicemonitor.monitoring.coreos.com/alertmanager-main created
clusterrole.rbac.authorization.k8s.io/blackbox-exporter created
clusterrolebinding.rbac.authorization.k8s.io/blackbox-exporter created
configmap/blackbox-exporter-configuration created
deployment.apps/blackbox-exporter created
networkpolicy.networking.k8s.io/blackbox-exporter created
service/blackbox-exporter created
serviceaccount/blackbox-exporter created
servicemonitor.monitoring.coreos.com/blackbox-exporter created
secret/grafana-config created
secret/grafana-datasources created
configmap/grafana-dashboard-alertmanager-overview created
configmap/grafana-dashboard-apiserver created
configmap/grafana-dashboard-cluster-total created
configmap/grafana-dashboard-controller-manager created
configmap/grafana-dashboard-grafana-overview created
configmap/grafana-dashboard-k8s-resources-cluster created
configmap/grafana-dashboard-k8s-resources-multicluster created
configmap/grafana-dashboard-k8s-resources-namespace created
configmap/grafana-dashboard-k8s-resources-node created
configmap/grafana-dashboard-k8s-resources-pod created
configmap/grafana-dashboard-k8s-resources-workload created
configmap/grafana-dashboard-k8s-resources-workloads-namespace created
configmap/grafana-dashboard-kubelet created
configmap/grafana-dashboard-namespace-by-pod created
configmap/grafana-dashboard-namespace-by-workload created
configmap/grafana-dashboard-node-cluster-rsrc-use created
configmap/grafana-dashboard-node-rsrc-use created
configmap/grafana-dashboard-nodes-darwin created
configmap/grafana-dashboard-nodes created
configmap/grafana-dashboard-persistentvolumesusage created
configmap/grafana-dashboard-pod-total created
configmap/grafana-dashboard-prometheus-remote-write created
configmap/grafana-dashboard-prometheus created
configmap/grafana-dashboard-proxy created
configmap/grafana-dashboard-scheduler created
configmap/grafana-dashboard-workload-total created
configmap/grafana-dashboards created
deployment.apps/grafana created
networkpolicy.networking.k8s.io/grafana created
prometheusrule.monitoring.coreos.com/grafana-rules created
service/grafana created
serviceaccount/grafana created
servicemonitor.monitoring.coreos.com/grafana created
prometheusrule.monitoring.coreos.com/kube-prometheus-rules created
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
deployment.apps/kube-state-metrics created
networkpolicy.networking.k8s.io/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kube-state-metrics-rules created
service/kube-state-metrics created
serviceaccount/kube-state-metrics created
servicemonitor.monitoring.coreos.com/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kubernetes-monitoring-rules created
servicemonitor.monitoring.coreos.com/kube-apiserver created
servicemonitor.monitoring.coreos.com/coredns created
servicemonitor.monitoring.coreos.com/kube-controller-manager created
servicemonitor.monitoring.coreos.com/kube-scheduler created
servicemonitor.monitoring.coreos.com/kubelet created
clusterrole.rbac.authorization.k8s.io/node-exporter created
clusterrolebinding.rbac.authorization.k8s.io/node-exporter created
daemonset.apps/node-exporter created
networkpolicy.networking.k8s.io/node-exporter created
prometheusrule.monitoring.coreos.com/node-exporter-rules created
service/node-exporter created
serviceaccount/node-exporter created
servicemonitor.monitoring.coreos.com/node-exporter created
clusterrole.rbac.authorization.k8s.io/prometheus-k8s created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-k8s created
networkpolicy.networking.k8s.io/prometheus-k8s created
poddisruptionbudget.policy/prometheus-k8s created
prometheus.monitoring.coreos.com/k8s created
prometheusrule.monitoring.coreos.com/prometheus-k8s-prometheus-rules created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s-config created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s-config created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
service/prometheus-k8s created
serviceaccount/prometheus-k8s created
servicemonitor.monitoring.coreos.com/prometheus-k8s created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrole.rbac.authorization.k8s.io/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-adapter created
clusterrolebinding.rbac.authorization.k8s.io/resource-metrics:system:auth-delegator created
clusterrole.rbac.authorization.k8s.io/resource-metrics-server-resources created
configmap/adapter-config created
deployment.apps/prometheus-adapter created
networkpolicy.networking.k8s.io/prometheus-adapter created
poddisruptionbudget.policy/prometheus-adapter created
rolebinding.rbac.authorization.k8s.io/resource-metrics-auth-reader created
service/prometheus-adapter created
serviceaccount/prometheus-adapter created
servicemonitor.monitoring.coreos.com/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/prometheus-operator created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-operator created
deployment.apps/prometheus-operator created
networkpolicy.networking.k8s.io/prometheus-operator created
prometheusrule.monitoring.coreos.com/prometheus-operator-rules created
service/prometheus-operator created
serviceaccount/prometheus-operator created
servicemonitor.monitoring.coreos.com/prometheus-operator created
</details>

```
root@master:/home/ubuntu/diplom-helm# sudo kubectl get po -n monitoring -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP               NODE     NOMINATED NODE   READINESS GATES
alertmanager-main-0                    2/2     Running   0          47s   10.233.75.5      node2    <none>           <none>
alertmanager-main-1                    2/2     Running   0          47s   10.233.75.4      node2    <none>           <none>
alertmanager-main-2                    2/2     Running   0          47s   10.233.102.134   node1    <none>           <none>
blackbox-exporter-6b5475894-s57bn      3/3     Running   0          88s   10.233.102.130   node1    <none>           <none>
grafana-59844d49d5-rtzfm               1/1     Running   0          87s   10.233.102.131   node1    <none>           <none>
kube-state-metrics-6bd55cf7d8-9c9wq    3/3     Running   0          86s   10.233.75.2      node2    <none>           <none>
node-exporter-5mw64                    2/2     Running   0          86s   10.0.1.10        master   <none>           <none>
node-exporter-klmkg                    2/2     Running   0          86s   10.0.2.11        node1    <none>           <none>
node-exporter-m8xrc                    2/2     Running   0          86s   10.0.3.12        node2    <none>           <none>
prometheus-adapter-74894c5547-t9q4z    1/1     Running   0          85s   10.233.75.3      node2    <none>           <none>
prometheus-adapter-74894c5547-tb82q    1/1     Running   0          85s   10.233.102.132   node1    <none>           <none>
prometheus-k8s-0                       1/2     Running   0          45s   10.233.102.135   node1    <none>           <none>
prometheus-k8s-1                       2/2     Running   0          45s   10.233.75.6      node2    <none>           <none>
prometheus-operator-78dd987cb4-drw9z   2/2     Running   0          85s   10.233.102.133   node1    <none>           <none>
```

#### Для доступа к интерфейсу изменим сетевую политику:

[manifests](https://github.com/V4d1M63/netology-diplom/blob/main/manifests/grafana-service.yml)

```
root@master:/home/ubuntu# sudo kubectl -n monitoring apply -f manifest/grafana-service.yml
service/grafana configured
networkpolicy.networking.k8s.io/grafana configured

```
#### Теперь зайти в Grafana можно по любому из адресов node1, node2, master 

![9](https://github.com/user-attachments/assets/ec4d82eb-0a60-4e05-8678-def0501b17e2)

## Далее развернём наше приложение в кластере Kubernetes.

```
root@master:/home/ubuntu/diplom-helm# sudo helm install applications /home/ubuntu/diplom-helm/applications  --set container.tag=1.0
NAME: applications
LAST DEPLOYED: Tue Aug  20 17:05:46 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

root@master:/home/ubuntu/diplom-helm# sudo helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
applications    default         1               2024-20-08 17:05:46.933031575 +0000 UTC deployed        applications-1  1.0     
```

![10](https://github.com/user-attachments/assets/e0700cab-1254-4f75-8888-bf82b37fe190)

Переходим по IP адресу любой из node порт 30003 который задали в service.yaml, и видим работу приложения. 

![11](https://github.com/user-attachments/assets/8366dd01-e036-4bab-8666-ce3f695f3997)

![12](https://github.com/user-attachments/assets/91d8412f-4e8d-4e2a-a9f2-f7e9cf5f1e51)

![13](https://github.com/user-attachments/assets/b792bc21-5246-435e-ba95-fb0f97c10d7b)


### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---

## Решение:

#### Совместно с развёрткой облачной инфраструктуры развернул две ВМ teamcity-server и teamcity-agent.

#### Развернём плейбуками на машинах server и agent сам teamcity и установим postgresgl на server.  

```
ansible-playbook -i /home/msi/diplom/ansible/inventory/hosts.yaml --become --become-user=root /home/msi/diplom/ansible/playbooks/teamcity.yml

PLAY RECAP *****************************************************************************************************************************************************************************************************
teamcity-agent             : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
teamcity-server            : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
```
ansible-playbook -i /home/msi/diplom/ansible/inventory/ --become --become-user=root /home/msi/diplom/ansible/playbooks/postgresql.yml

PLAY RECAP *****************************************************************************************************************************************************************************************************
teamcity-server            : ok=13   changed=10   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

#### Зайдём на адрес Teamcity:

![14](https://github.com/user-attachments/assets/5a6f7ea5-f9e6-45f6-ad84-7b98938e7714)

#### Данные для инициализации берём с конфига Postgresgl и устанавливаем предложенный драйвер JDBC.

![15](https://github.com/user-attachments/assets/3f705b40-332f-4252-a3a2-68c01e9b4053)

#### Авторизируем агента:

![16](https://github.com/user-attachments/assets/4ebdeb49-30d4-4684-b6a1-807c6ce371ad)

#### Подключил Dockerhub

![17](https://github.com/user-attachments/assets/f3ec7085-7412-414d-ac26-e3d9e3b029dc)

#### Подключил в Build Features Docker Support

![18](https://github.com/user-attachments/assets/0f417c0b-0798-47ba-af8e-305198f08046)

### Соберём проект: 

#### [Полный код Build Steps находтся здесь](https://github.com/V4d1M63/netology-diplom/tree/main/Teamcity)

#### Этот скрипт предназначен для получения тега коммита и установки его в качестве параметра сборки.

![19](https://github.com/user-attachments/assets/aafa8b6f-1b94-41ca-9ef3-188d73a85a1a)

#### Создаём образы Docker:

![20](https://github.com/user-attachments/assets/8b325d0f-1d08-4c3e-abad-ee2cfea5ed4e)

#### Отправка собранно образа в Dockerhub:

![21](https://github.com/user-attachments/assets/35e7bcda-163a-4392-bfd0-849dc35f4c2e)

### Проверяем:

#### Изменили версию приложения и запушили.

```
root@vm-mint:/home/msi/diplom-applications# git add *

root@vm-mint:/home/msi/diplom-applications# git commit -m "Version 2.0"
[main 0c30f49] Version 2.0
 1 file changed, 1 insertion(+), 1 deletion(-)

root@vm-mint:/home/msi/diplom-applications# git tag -a 2.0 -m "Version 2.0"

root@vm-mint:/home/msi/diplom-applications# git push origin main
Username for 'https://github.com': V4D1M63
Password for 'https://V4D1M63@github.com': 
Перечисление объектов: 5, готово.
Подсчет объектов: 100% (5/5), готово.
При сжатии изменений используется до 3 потоков
Сжатие объектов: 100% (3/3), готово.
Запись объектов: 100% (3/3), 351 байт | 351.00 КиБ/с, готово.
Всего 3 (изменений 1), повторно использовано 0 (изменений 0), повторно использовано пакетов 0
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To https://github.com/V4D1M63/diplom-applications.git
   f981c64..0c30f49  main -> main

root@vm-mint:/home/msi/diplom-applications# git push origin 2.0
Username for 'https://github.com': V4D1M63
Password for 'https://V4D1M63@github.com': 
Перечисление объектов: 1, готово.
Подсчет объектов: 100% (1/1), готово.
Запись объектов: 100% (1/1), 182 байта | 182.00 КиБ/с, готово.
Всего 1 (изменений 0), повторно использовано 0 (изменений 0), повторно использовано пакетов 0
To https://github.com/V4D1M63/diplom-applications.git
 * [new tag]         2.0 -> 2.0
```

![22](https://github.com/user-attachments/assets/36ed94cb-bb74-41f4-98df-9770bdeaa17a)

![23](https://github.com/user-attachments/assets/17d5c517-af40-401e-912b-9e772f1044a3)

![24](https://github.com/user-attachments/assets/8c285553-1e78-4a45-b578-847e09e96c0e)

### Добавим изменение тега, создание helm и выгрузку его в Git с последующим апдейтом в кластере Kubernetes:

![25](https://github.com/user-attachments/assets/9d3754e3-d5ff-4311-8dc7-207e052d5430)

![26](https://github.com/user-attachments/assets/5ea911e4-580a-4168-a72e-1d51f62de125)

![27](https://github.com/user-attachments/assets/843c4686-92ab-4517-8d55-aa78084c5757)

![28](https://github.com/user-attachments/assets/0e213bb4-8186-4078-9403-6f953c9628c1)

![29](https://github.com/user-attachments/assets/136c5575-e5c4-4224-9fe4-298857dd52c7)

### Запустим изменения: 

```
root@vm-mint:/home/msi/diplom-applications# git add *

root@vm-mint:/home/msi/diplom-applications# git commit -m "Version 14.0"
[main 577a6f0] Version 14.0
 1 file changed, 1 insertion(+), 1 deletion(-)

root@vm-mint:/home/msi/diplom-applications# git tag -a 14.0 -m "Version 14.0"

root@vm-mint:/home/msi/diplom-applications# git push origin main
Username for 'https://github.com': V4D1M63
Password for 'https://V4D1M63@github.com': 
Перечисление объектов: 5, готово.
Подсчет объектов: 100% (5/5), готово.
При сжатии изменений используется до 3 потоков
Сжатие объектов: 100% (3/3), готово.
Запись объектов: 100% (3/3), 352 байта | 352.00 КиБ/с, готово.
Всего 3 (изменений 1), повторно использовано 0 (изменений 0), повторно использовано пакетов 0
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To https://github.com/V4D1M63/diplom-applications.git
   a6a294a..577a6f0  main -> main

root@vm-mint:/home/msi/diplom-applications# git push origin 14.0
Username for 'https://github.com': V4D1M63
Password for 'https://V4D1M63@github.com': 
Перечисление объектов: 1, готово.
Подсчет объектов: 100% (1/1), готово.
Запись объектов: 100% (1/1), 184 байта | 184.00 КиБ/с, готово.
Всего 1 (изменений 0), повторно использовано 0 (изменений 0), повторно использовано пакетов 0
To https://github.com/V4D1M63/diplom-applications.git
 * [new tag]         14.0 -> 14.0
```

![30](https://github.com/user-attachments/assets/f7b135a9-8030-45f6-9395-6b29fbae1f01)

![31](https://github.com/user-attachments/assets/7ba4f668-3a31-4002-b28a-e7c63507028d)

![32](https://github.com/user-attachments/assets/3db011cf-9f78-4a3f-8ffc-a6dc451f5fb6)

#### Зайдём на наши ноды:

![33](https://github.com/user-attachments/assets/22bf460f-5384-4b0a-9916-74e82f1d8329)

![34](https://github.com/user-attachments/assets/858c6ca5-5c78-4e4d-b25e-44d638ce283f)

#### Пробуем обновить версию ещё раз:

![35](https://github.com/user-attachments/assets/7f27b30f-ef68-40cb-a68b-6ab21795b334)

![36](https://github.com/user-attachments/assets/09800523-f357-49d7-87e2-b3935419924c)

![37](https://github.com/user-attachments/assets/c754b56b-219e-46a2-9fd6-b88342d86135)

![38](https://github.com/user-attachments/assets/b26a8807-2bdc-4a5d-8a5b-fa4ea06c83d9)

![39](https://github.com/user-attachments/assets/7afdd204-537f-459f-8847-8be74c3e7807)

![40](https://github.com/user-attachments/assets/86f60770-ca43-41c2-b230-a209abf74238)
