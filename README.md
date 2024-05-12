# Описание дипломной работы.
Коротко по предварительным заметкам, бастионный хост, который есть в официальной инструкции на яндекс облаке, сложнее организовать, посколько naт-инстанс машина сразу в 2х сетях, и соединить остальные из разных областей можно только через дополнительные роутеры или даже ВПН.
Взята более простая модель, бастион в одной сети и через NAT смотрит в интернет, с ограниченями в группе безопасности по 22му порту. Так же, elasticsearch, не захотел работать, когда указываешь в его конфигурации параметр адреса сервера через FQDN, только через ip.
Весь проект можно разделить на 3 папки, terraform, ansible, и server_data/
### Terraform
Сразу небольшое лирическое вступление, терраформ поумнел, и сам работает со всем файлами в папке проекта с расширением tf, include, что бы включить файлы в один исполняемый файл не требуется.

![структура](https://github.com/ermacster/Diplom/blob/master/images/terraform.jpg)

main.tf -  Основной файл, где описываются переменные локально,  а так же параметры для работы с яндекс облаком

authorized_key.json -  файл ключа к облаку, прописываем его в файле gitignore

cloud-init.yaml - описывает мета данные для виртуальных машин, его задействуем в файле vm.tf

vm.tf - Файл, в нем мы прописываем все виртаульные машины, а так же снапшоты для каждого диска. На машины с ELK ставим чуть больше ресурсов, а так же убунту 20.04.

networks.tf - Пожалуй самый функциональный файл, в нем мы создаем сети, подсети, группы  безопасности(разрешаем 22, 53,80й, 443, 9200, 5601, 1050 и 1051 порты и ICMP).Так же, что бы машины начали обращаться к друг другу по FQDN, создаем DNS зону.Бкенд и таргет группы для 
web серверов идут в балансировщик, а так же настраиваем маскарадинг для машин, которые не имеют внешнего адреса(создам маршурт по умолчанию через nat и добавляем его в нужные сети для web,elastisc машин)

outputs.tf - Это файл выводов после работы терраформ. Выводим все FQDN, внешние ip для машин и балансировщика(что бы посмотреть сайт), внутренний ip для elastics.Все выводы дублируем в соответствующие файлы, которые сохраняются в server_data. С ними уже будет работать ansible

![вывод](https://github.com/ermacster/Diplom/blob/master/images/output.jpg)

### Ansible
server_data - директория, в которой храняться все служебные конфиги, файлы с вывода терраформ и amsible, файлы сайты и скрипты.

inventory - файл описывает все машины, и способ подключения через бастионный хост. В нем через lookup  file берем переменную из файла для внешнего IP адреса бастиона, а так же отключаем проверку при первом подключении по ssh ansible_ssh_common_args.

roles - каталог  ролей, в данной работе использую 1 роль, для установки заббикс агент, соответствующий файл с ней работает. В main правим параметры для подключению к серверу по FQDN.

zabbix-agent.yml - файл-плейбук, который задеуствует соответсвуюущю роль, ставим агента на все машины, группа all

zabbix-server.yml - плейбук, для установки заббикс сервера, через докер. Сам докер ставлю через sh скрипт, что бы можно было взаимодействовать с контейнерами.Главное не забыть, что подключение идет через PSK ключ, он есть в заббикс агенте и в отдельном файле.

![заббикс](https://github.com/ermacster/Diplom/blob/master/images/zabbix.jpg)

nginx.yml - ставим nginx через модуль apt, а так же копируем index.html и картинку сайта по пути /var/www/html/ для группы web

![сайт в деле](https://github.com/ermacster/Diplom/blob/master/images/site.jpg)

elastics.yml - тут остановлюсь подробнее, официально ЕЛК сейчас не установить, но яндекс заботливо предложил свой репозиторий) Ставим репозиторий, и сам elastics версии 7.17, копируем конфиг из server_data.Далее про момент, что он не заводится если network_host указать 
FQDN, через туже фунцию lookup берем внутренний ip адрес из файла. Для безопасности, в конце задаем пароли автоматом для всех пользователей сервиса и выводим их сообщении и в файл.Что не успел, ввиду дедлайна, это дипилить регулярное выражение, что бы из этого файла данные подставлялись в файл конфига для kibana  и filebeat

![пароли для elastisc](https://github.com/ermacster/Diplom/blob/master/images/password.jpg)

kibana.yml -  еще не донца автоматизирована, но в файле конфига, который лежит server_data, нужно подставить значение пароля и логина из вывода предыдущей установки. FQDN на elastic прописал заранее, ввиду того, что он не изменен при пересоздании машины, но можно так же взять его из файла через look up

filebeat.yml - так же нужно дать ему данные в конфиг на server_data перед установкой. Саму кусяку) ставим с активацией модуля nginx, он уже должен логи подстроить под нужный формат.


![логи](https://github.com/ermacster/Diplom/blob/master/images/ELK.jpg)
