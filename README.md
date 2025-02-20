 # Дипломный практикум в Yandex.Cloud

## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

## Этапы выполнения:

## Создание облачной инфраструктуры
Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи Terraform.

### Особенности выполнения:
Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов; Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

#### Предварительная подготовка к установке и запуску Kubernetes кластера.
1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте backend для Terraform: 
а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF) б. Альтернативный вариант: Terraform Cloud
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды terraform destroy и terraform apply без дополнительных ручных действий.
6. В случае использования Terraform Cloud в качестве backend убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

### Ожидаемые результаты:
1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

____

## Создание Kubernetes кластера
На этом этапе необходимо создать Kubernetes кластер на базе предварительно созданной инфраструктуры. Требуется обеспечить доступ к ресурсам из Интернета.

### Это можно сделать двумя способами:
1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера. 
а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.
б. Подготовить ansible конфигурации, можно воспользоваться, например Kubespray
в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом Yandex Managed Service for Kubernetes
а. С помощью terraform resource для kubernetes создать региональный мастер kubernetes с размещением нод в разных 3 подсетях
б. С помощью terraform resource для kubernetes node group

### Ожидаемый результат:
1. Работоспособный Kubernetes кластер.
2. В файле ~/.kube/config находятся данные для доступа к кластеру.
3. Команда kubectl get pods --all-namespaces отрабатывает без ошибок.
____

## Создание тестового приложения
Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

### Способ подготовки:
1. Рекомендуемый вариант:
а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.
б. Подготовьте Dockerfile для создания образа приложения.
2. Альтернативный вариант:
а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

### Ожидаемый результат:
1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или Yandex Container Registry, созданный также с помощью terraform.

____

## Подготовка cистемы мониторинга и деплой приложения
Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

### Цель:

1. Задеплоить в кластер prometheus, grafana, alertmanager, экспортер основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, nginx сервер отдающий статическую страницу.

### Способ выполнения:
1. Воспользоваться пакетом kube-prometheus, который уже включает в себя Kubernetes оператор для grafana, prometheus, alertmanager и node_exporter. Альтернативный вариант - использовать набор helm чартов от bitnami.
2. Если на первом этапе вы не воспользовались Terraform Cloud, то задеплойте и настройте в кластере atlantis для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

### Ожидаемый результат:

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.

____

## Установка и настройка CI/CD
Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

### Цель:
1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.
Можно использовать teamcity, jenkins, GitLab CI или GitHub Actions.

### Ожидаемый результат:
1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

____

## Что необходимо для сдачи задания?
1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

____

# Выполнение работы

## Создание облачной инфраструктуры

Для выполения этой задачи буду использовать yc client и terraform

![image](https://github.com/user-attachments/assets/f5f2eb1e-6429-4a0f-805c-4f5e32933e0b)

Создаю сервисный аккаунт и даю ему права editor для внесения изменений 

~~~hcl
# Создание сервисного аккаунта
 resource "yandex_iam_service_account" "sa" {
   name       = var.account_name
 }

# Назначаем роль editor
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id   = var.folder_id
  role        = "storage.editor"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Создаем статический ключ доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
 service_account_id = yandex_iam_service_account.sa.id
 }

# Используем ключ доступа для создания бакета
resource "yandex_storage_bucket" "sa-bucket" {
  bucket     = "bucket-for-diplom-work"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  anonymous_access_flags {
    read = false
    list = false
  }

  force_destroy = true

provisioner "local-exec" {
  command = "echo export AWS_ACCESS_KEY_ID=${yandex_iam_service_account_static_access_key.sa-static-key.access_key} > ~/diplom-work/terraform/backend.tfvars"
}

provisioner "local-exec" {
  command = "echo export AWS_SECRET_ACCESS_KEY=${yandex_iam_service_account_static_access_key.sa-static-key.secret_key} >> ~/diplom-work/terraform/backend.tfvars"
}
}
~~~
![image](https://github.com/user-attachments/assets/6dcdb005-042d-4571-8d5c-91688acb05ba)![image](https://github.com/user-attachments/assets/cbdf1fad-998e-4ef1-bc3d-5073924c9c97)

Создан сервисный аккаунт с ролью editor
![image](https://github.com/user-attachments/assets/430e704a-1272-4fc9-880d-1e7706167936)

Создан backet 
![image](https://github.com/user-attachments/assets/734ff1ce-184b-4648-aae2-2f751911f975)

Ключ записан в файл backet.tfvars
![image](https://github.com/user-attachments/assets/852b3657-a16f-4597-b811-e3fe14f4752e)


---

Применяю 
~~~
export AWS_ACCESS_KEY_ID=ИД ключа
export AWS_SECRET_ACCESS_KEY=Мой секретный ключ
~~~

Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры храню в разных папках.
backend.tf
~~~hcl
terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "bucket-for-diplom-work"
    region = "ru-central1"
    key    = "for-state/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
~~~

Файл terraform.tfstate подгрузился в ранее созданный backet
![image](https://github.com/user-attachments/assets/640170fc-b587-4143-b30d-15f7c0411a6d)

---

Создано VPC с подсетями в разных зонах доступности:

~~~hcl
resource "yandex_vpc_network" "diplom" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "diplom-subnet1" {
  name           = var.subnet1
  zone           = var.zone1
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = var.cidr1
}

resource "yandex_vpc_subnet" "diplom-subnet2" {
  name           = var.subnet2
  zone           = var.zone2
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = var.cidr2
}
~~~

![image](https://github.com/user-attachments/assets/25a1fa18-23a1-4296-90aa-4a0e6529c4cf)



Команды terraform destroy и terraform apply исполняются без дополнительных ручных действий

---

## Итог создания облачной инфраструктуры:

Terraform сконфигурирован и создана инфраструктура посредством Terraform, без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете.
Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания будут изменения.

--- 

## Создание Kubernetes кластера

Так же буду использовать kubernates и helm

![image](https://github.com/user-attachments/assets/fa4a16fc-7eb7-46bb-8379-24da9e40cfcc)

Приступлю к развёртыванию Kubernetes кластера, разворачивать буду из репозитория Kubespray, склонирую репозиторий на свою рабочую машину с github:

![image](https://github.com/user-attachments/assets/4b4031a1-45ad-41e9-b401-52611e284035)


При помощи terraform буду применять следующий код:
~~~hcl
resource "local_file" "hosts_cfg_kubespray" {
  count = var.exclude_ansible ? 0 : 1 # Если exclude_ansible true, ресурс не создается

  content  = templatefile("${path.module}/hosts.tftpl", {
    workers = yandex_compute_instance.worker
    masters = yandex_compute_instance.master
  })
  filename = "../kubespray/inventory/mycluster/hosts.yaml"
}
~~~
Он создаст hosts.yaml по шаблону

~~~
all:
  hosts:%{ for idx, master in masters }
    master:
      ansible_host: ${master.network_interface[0].nat_ip_address}
      ip: ${master.network_interface[0].ip_address}
      access_ip: ${master.network_interface[0].nat_ip_address}%{ endfor }%{ for idx, worker in workers }
    worker-${idx + 1}:
      ansible_host: ${worker.network_interface[0].nat_ip_address}
      ip: ${worker.network_interface[0].ip_address}
      access_ip: ${worker.network_interface[0].nat_ip_address}%{ endfor }
  children:
    kube_control_plane:
      hosts:%{ for idx, master in masters }
        ${master.name}:%{ endfor }
    kube_node:
      hosts:%{ for idx, worker in workers }
        ${worker.name}:%{ endfor }
    etcd:
      hosts:%{ for idx, master in masters }
        ${master.name}:%{ endfor }
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
~~~

При выполнение terraform, hosts.yaml будет выглядеть так в зависимости от ip адресов

![image](https://github.com/user-attachments/assets/6c7baf65-4e24-40f0-bc7d-ee9884cc2283)

Выполнение terraform

![image](https://github.com/user-attachments/assets/2de4b4ff-e00f-42ff-9305-4203b9938fc9)

Далее мы запустим установку кластера:

~~~
ansible-playbook -i /kuberspray/inventory/mycluster/hosts.yaml -u ubuntu --become --become-user=root --private-key=~/.ssh/id_ed25519 -e 'ansible_ssh_common_args="-o StrictHostKeyChecking=no"' cluster.yml --flush-cache
~~~

![image](https://github.com/user-attachments/assets/3d412ef7-cbaf-4231-906a-d05c978db822)

Спустя время кластер будет готов, на данный момент для управления кластером мы заходим на master по ssh
Дальше мы создаем конфиг файл кластера Kubernetes.

![image](https://github.com/user-attachments/assets/d00bc805-6636-40fc-9180-2541bf1150fe)

Назначаем права проверяем и убеждаемся в том что всё работает

![image](https://github.com/user-attachments/assets/c24e8c98-6996-41b4-bebd-0d4ff24c6c9b)

![image](https://github.com/user-attachments/assets/0f9dc056-5fd2-42d2-84c5-c34e4f857d43)

Перед тем как выйти скопируем конфиг на локальную машину чтобы управлять кластером оттуда:
cat ~/.kube/config
Далее выходим exit и создаем файл конфига на локальной машине

---

## Создание тестового приложения

Создаем новый репозиторий на github и копируем его себе на локлаьную машину:
![image](https://github.com/user-attachments/assets/6c529d44-9e6f-487d-8e89-ec040773e70e)

Выполняем вход на docker hub
![image](https://github.com/user-attachments/assets/d83fffe4-653e-4ca2-9978-ba0496702164)

Создадим статичную страницу для нашего тестового приложения:

~~~html
<html>
    <head>
        <title>Test_diplom</title>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
        <meta name="title" content="Тест для дипломной работы">
        <meta name="author" content="Stogov Anton">
        <meta name="description" content="capture">
    </head>
    <body>
        <h1>Diplow-work</h1>
        <img src="diplom_image.jpg"/>
    </body>
</html>
~~~

Докер файл с nginx для отображения нашей статичной страницы

~~~docker
FROM nginx:1.27.0
RUN rm -rf /usr/share/nginx/html/*
COPY content/ /usr/share/nginx/html/
EXPOSE 80
~~~

Создам образ и запушу его в docker hub
![image](https://github.com/user-attachments/assets/550715c0-e609-4921-9c79-e97b8dbe7d4d)

![image](https://github.com/user-attachments/assets/95b00f2c-80e6-4995-86d8-29c8f5b6eeab)

Проверяю образ на docker hub

![image](https://github.com/user-attachments/assets/69bf8c29-e10d-48dd-8d0e-bcbaf5e96860)

---































































































































