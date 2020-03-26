# 1cWinCtrl - внешняя компонента 1С 

Предназначена для управления окнами Windows и Linux, разработана по технологии Native API.

### Возможности компоненты:
- Получение списка окон и списка процессов
- Управление размерами и положением окна
- Получение снимка окна и снимка экрана
- Доступ к данным буфера обмена

### Свойства

- <a href="#ScreenInfo">СвойстваЭкрана (ScreenInfo)</a>
- <a href="#DisplayList">СписокДисплеев (DisplayList)</a>
- <a href="#WindowList">СписокОкон (WindowList)</a>
- <a href="#ProcessId">ИдентификаторПроцесса (ProcessId)</a>
- <a href="#ActiveWindow">АктивноеОкно (ActiveWindow)</a>
- <a href="#ClipboardText">ТекстБуфераОбмена (ClipboardText)</a>
- <a href="#ClipboardImage">КартинкаБуфераОбмена (ClipboardImage)</a>
- <a href="#CursorPos">ПозицияКурсора (CursorPos)</a>

### Методы

Работа с процессами:
- <a href="#FindTestClient">НайтиКлиентТестирования (FindTestClient)</a>
- <a href="#GetProcessList">ПолучитьСписокПроцессов (GetProcessList)</a>
- <a href="#GetProcessInfo">ПолучитьСвойстваПроцесса (GetProcessInfo)</a>
- <a href="#WebSocket">ВебСокет (WebSocket)</a>
- <a href="#Sleep">Пауза (Sleep)</a>

Информация об окружении:
- <a href="#GetDisplayList">ПолучитьСписокДисплеев (GetDisplayList)</a>
- <a href="#GetDisplayInfo">ПолучитьСвойстваДисплея (GetDisplayInfo)</a>

Управление окном приложения:
- <a href="#GetWindowList">ПолучитьСписокОкон (GetWindowList)</a>
- <a href="#GetWindowInfo">ПолучитьСвойстваОкна (GetWindowInfo)</a>
- <a href="#GetWindowSize">ПолучитьРазмерОкна (GetWindowSize)</a>
- <a href="#SetWindowSize">УстановитьРазмерОкна (SetWindowSize)</a>
- <a href="#SetWindowPos">УстановитьПозициюОкна (SetWindowPos)</a>
- <a href="#ActivateWindow">АктивироватьОкно (ActivateWindow)</a>
- <a href="#MaximixeWindow">РаспахнутьОкно (MaximixeWindow)</a>
- <a href="#RestoreWindow">РазвернутьОкно (RestoreWindow)</a>
- <a href="#MinimizeWindow">СвернутьОкно (MinimizeWindow)</a>

Захват изображения экрана:
- <a href="#TakeScreenshot">ПолучитьСнимокЭкрана (TakeScreenshot)</a>
- <a href="#CaptureWindow">ПолучитьСнимокОкна (CaptureWindow)</a>
- <a href="#CaptureProcess">ПолучитьСнимокПроцесса (CaptureProcess)</a>

Работа с буфером обмена:
- <a href="#EmptyClipboard">ОчиститьБуферОбмена (EmptyClipboard)</a>

Расширенный функционал работы с буфером обмена вынесен в объект <a href="#ClipboardControl">**ClipboardControl**</a>.

### Общая информация

Внешняя компонента поддерживает как синхронный, так и асинхронный вызов.
Для асинхронного вызова в полном соответствии с документацией Синтакс-помощника
1С:Предприятие применяются методы:
- НачатьВызов<ИмяМетода>(<ОписаниеОповещения>, <Параметры>)
- НачатьПолучение<ИмяСвойства>(<ОписаниеОповещения>)

Пример асинхронного вызова внешней компоненты:
```bsl
&НаКлиенте
Процедура ПодключениеВнешнейКомпонентыЗавершение(Подключение, ДополнительныеПараметры) Экспорт
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученаВерсияКомпоненты", ЭтотОбъект);
	ВнешняяКомпонента.НачатьПолучениеВерсия(ОписаниеОповещения);
КонецПроцедуры

&НаКлиенте
Процедура ПолученаВерсияКомпоненты(Значение, ДополнительныеПараметры) Экспорт
	Заголовок = "Управление окнами, версия " + Значение;
КонецПроцедуры	
```

Далее по тексту все примеры будут приводиться для синхронных вызовов. В публикуемом примере
[**1cWinCtrl.epf**](https://github.com/lintest/1cWinCtrl/releases) используются только асинхронные вызовы.

Многие свойства и методы компоненты возвращают сложные типы данных, которые сериализованы 
в строку формата JSON. Поэтому имеет смысл объявить в вызывающем модуле универсальную 
функцию, которая будет использоваться ниже в примерах работы компоненты:
```bsl
Функция ПрочитатьСтрокуJSON(ТекстJSON)
	Если ПустаяСтрока(ТекстJSON) Тогда
		Возврат Неопределено;
	Иначе
		ПоляДаты = Новый Массив;
		ПоляДаты.Добавить("CreationDate");
		ЧтениеJSON = Новый ЧтениеJSON();
		ЧтениеJSON.УстановитьСтроку(ТекстJSON);
		Возврат ПрочитатьJSON(ЧтениеJSON, , ПоляДаты);
	КонецЕсли;
КонецФункции
```
### Сборка проекта

Готовая сборка внешней компоненты находится в файле 
[/Example/Templates/_1cWinCtrl/Ext/Template.bin](https://github.com/lintest/1cWinCtrl/raw/master/Example/Templates/_1cWinCtrl/Ext/Template.bin)

Порядок самостоятельной сборки внешней компоненты из исходников:
1. Для сборки компоненты необходимо установить Visual Studio Community 2019
2. Чтобы работала сборка примера обработки EPF надо установить OneScript версии 1.0.20 или выше
3. Устанавливаем VirtualBox и разворачиваем в минимальной конфигурации Ubuntu 18.04 или CentOS 8
4. Устанавливаем на Linux необходимые пакеты (см. ниже) и дополнения гостевой ОС
5. Подключаем в VirtualBox общую папку с исходными текстами внешней компоненты
6. В среде Linux для компиляции библиотек запустить ./build.sh
7. В среде Window для завершения сборки запустить ./compile.bat


```Batchfile
b2.exe toolset=msvc link=static threading=multi runtime-link=static release stage
```

Сборка для Linux в CentOS 8:
```bash
yum -y group install "Development Tools"
yum -y install cmake glibc-devel.i686 glibc-devel libuuid-devel 
yum -y install libstdc++-devel.i686 gtk2-devel.i686 glib2-devel.i686
yum -y install libstdc++-devel.x86_64 gtk2-devel.x86_64 glib2-devel.x86_64
git clone https://github.com/lintest/1cWinCtrl.git
cd 1cWinCtrl
./build.sh
```

Сборка для Linux в Ubuntu 18.04:
```bash
sudo apt update
sudo apt install -y build-essential cmake git
sudo apt install -y gcc-multilib g++-multilib
sudo apt install -y uuid-dev libx11-dev libxrandr-dev libpng-dev
git clone https://github.com/lintest/1cWinCtrl.git
cd 1cWinCtrl
./build.sh
```

Установка на VirtualBox дополнений гостевой ОС для Linux:
```bash
mkdir -p /media/cdrom
mount -r /dev/cdrom /media/cdrom
cd /media/cdrom
./VBoxLinuxAdditions.run
sudo usermod -a -G vboxsf "$USER"
reboot
```

***

## Установка и подключение

Для создания объекта экземпляра внешней компоненты используйте имя **WindowsControl**.
В прилагаемом примере файлы внешней компоненты хранятся в макете **_1cWinCtrl**, реквизит формы 
**МестоположениеКомпоненты** используется для передачи макета компоненты между сервером и клиентом.
Для установки и подключения внешней компоненты рекомендуется использовать следующий программный код:

```bsl
&НаКлиенте
Перем ИдентификаторКомпоненты, ВнешняяКомпонента;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	МакетКомпоненты = РеквизитФормыВЗначение("Объект").ПолучитьМакет("_1cWinCtrl");
	МестоположениеКомпоненты = ПоместитьВоВременноеХранилище(МакетКомпоненты, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ИдентификаторКомпоненты = "_" + СтрЗаменить(Новый УникальныйИдентификатор, "-", "");
	ВыполнитьПодключениеВнешнейКомпоненты(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПодключениеВнешнейКомпоненты(ДополнительныеПараметры) Экспорт
	ОписаниеОповещения = Новый ОписаниеОповещения("ПодключениеВнешнейКомпонентыЗавершение", ЭтаФорма, ДополнительныеПараметры);
	НачатьПодключениеВнешнейКомпоненты(ОписаниеОповещения, МестоположениеКомпоненты, ИдентификаторКомпоненты, ТипВнешнейКомпоненты.Native); 
КонецПроцедуры	

&НаКлиенте
Процедура ПодключениеВнешнейКомпонентыЗавершение(Подключение, ДополнительныеПараметры) Экспорт
	Если Подключение Тогда
		ВнешняяКомпонента = Новый("AddIn." + ИдентификаторКомпоненты + ".WindowsControl");
	ИначеЕсли ДополнительныеПараметры = Истина Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ВыполнитьПодключениеВнешнейКомпоненты", ЭтаФорма, Ложь);
		НачатьУстановкуВнешнейКомпоненты(ОписаниеОповещения, МестоположениеКомпоненты);
	КонецЕсли;
КонецПроцедуры	

```

## Свойства

### <a name="ScreenInfo">СвойстваЭкрана / ScreenInfo</a>
Тип значения: Строка (только чтение)
- Возвращает строку с текстом в формате JSON, при чтении которого получаем
объект типа ***Структура*** с размерами экрана и рабочей области.

### <a name="DisplayList">СписокДисплеев / DisplayList</a>
Тип значения: Строка (только чтение)
- Возвращает строку с текстом в формате JSON, при чтении которого получаем
объект типа ***Массив*** из элементов типа ***Структура*** с размерами дисплеев мониторов.

### <a name="WindowList">СписокОкон / WindowList</a>
Тип значения: Строка (только чтение)
- Возвращает строку с текстом в формате JSON, при чтении которого получаем
объект типа ***Массив*** из элементов типа ***Структура*** с информацией об окнах 
верхнего уровня: дескриптор окна, диентификатор процесса, владелец, заголовок окна.

### <a name="ProcessId">ИдентификаторПроцесса / ProcessId</a>
Тип значения: Целое число (только чтение)
- Возвращает идентификатор основного процесса приложения 1С, в сеансе которого 
вызывается внешняя компонента.

### <a name="ActiveWindow">АктивноеОкно / ActiveWindow</a>
Тип значения: Целое число (чтение и запись)
- Дескриптор приоритетного окна (окна, с которым пользователь в настоящее время работает). 

### <a name="ClipboardText">ТекстБуфераОбмена / ClipboardText</a>
Тип значения: Строка (чтение и запись)
- Предоставляет доступ к содержимому буфера обмена в текстовом формате. 

### <a name="ClipboardImage">КартинкаБуфераОбмена / ClipboardImage</a>
Тип значения: Двоичные данные (чтение и запись)
- Предоставляет доступ к содержимому буфера обмена в формате картинки PNG. 

```bsl
ПотокВПамяти = Новый ПотокВПамяти;
БиблиотекаКартинок.ДиалогИнформация.Записать(ПотокВПамяти);
ДвоичныеДанные = ПотокВПамяти.ЗакрытьИПолучитьДвоичныеДанные();
ВнешняяКомпонента.КартинкаБуфераОбмена = ДвоичныеДанные;
```

## Методы
### <a name="FindTestClient">НайтиКлиентТестирования(НомерПорта) / FindTestClient</a>
Возвращает текст в формате JSON, при чтении которого получаем объект типа ***Структура***, 
сотдержащий информацию о клиенте тестирования, найденному по номеру порта, 
который присутствует в командной строке экземпляра клиента тестирования.

Параметры функции:
- **НомерПорта** (обязательный), Тип: Целое число

Тип возвращаемого значения: Строка
- Содержит строку с текстом в формате JSON, при чтении которого получаем
объект типа ***Структура*** с подробной информацией о найденном процессе.
    - ProcessId - идентификатор процесса (Число)
	- CommandLine - командная строка процесса (Строка)
	- CreationDate - дата старта процесса (Дата)
	- Window - дескриптор основного окна (Число)
	- Title - заголовок основного окна (Строка)

```bsl
ТекстJSON = ВнешняяКомпонента.НайтиКлиентТестирования(ПортПодключения);
СтруктураСвойствПроцесса = ПрочитатьСтрокуJSON(ТекстJSON);
Если СтруктураСвойствПроцесса <> Неопределено Тогда
	ИдентификаторПроцесса = СтруктураСвойствПроцесса.ProcessId;
	ДескрипторОкна = СтруктураСвойствПроцесса.Window;
КонецЕсли;
```
### <a name="GetProcessList">ПолучитьСписокПроцессов(ИспользоватьОтбор) / GetProcessList</a>
Получает список запущенных процессов.

Параметры функции:
- **ИспользоватьОтбор** (обязательный), Тип: Булево

Тип возвращаемого значения: Строка
- Содержит строку с текстом в формате JSON, при чтении которого получаем
типа ***Массив*** из элементов типа ***Структура*** информацией о процессах.

```bsl
ТекстJSON = ВнешняяКомпонента.ПолучитьСписокПроцессов(Истина);
Для каждого Стр из ПрочитатьСтрокуJSON(ТекстJSON) Цикл
	НоваяСтр = СписокПроцессов.Добавить();
	ЗаполнитьЗначенияСвойств(НоваяСтр, Стр);
КонецЦикла;
```

### <a name="GetProcessInfo">ПолучитьСвойстваПроцесса(ИдентификаторПроцесса) / GetProcessInfo</a>
По идентификатору процесса возвращает всю доступную информацию о процессе.

Параметры функции:
- **ИдентификаторПроцесса** (обязательный), Тип: Целое число

Тип возвращаемого значения: Строка
- Содержит строку с текстом в формате JSON, при чтении которого получаем
объект типа ***Структура*** с подробной информацией о процессе:
    - ProcessId - идентификатор процесса (Число)
	- CommandLine - командная строка процесса (Строка)
	- CreationDate - дата старта процесса (Дата)

```bsl
ТекстJSON = ВнешняяКомпонента.ПолучитьСвойстваПроцесса(ИдентификаторПроцесса);
СтруктураСвойстваПроцесса = ПрочитатьСтрокуJSON(ТекстJSON);
```

### <a name="Sleep">ВебСокет(Адрес, Команда) / WebSocket</a>
Простейшая функция обмена данными по протоколу WebSocket.
Может быть использована для интеграции с браузером Google Chrome.

Параметры функции:
- **Адрес** (обязательный), Тип: Строка
- **Команда** (обязательный), Тип: Строка

Тип возвращаемого значения: Строка
- Содержит данные, полученные как ответ сервера WebSocket на отправленную команду.

```bsl
	АдресВебСокет = "ws://localhost:9222/devtools/page/771BF9AF6EE6F712337EF74397960652";
	КомандаJSON = "{""id"":1,""method"":""Page.captureScreenshot"",""params"":{""format"":""png""}";
	ТекстJSON = ВнешняяКомпонента.ВебСокет(АдресВебСокет, КомандаJSON);
	ДанныеJSON = ПрочитатьСтрокуJSON(ТекстJSON);
	ДвоичныеДанные = Base64Значение(ДанныеJSON.result.data);
```
Подробная информация о Chrome DevTools Protocol доступна по адресу:
* https://chromedevtools.github.io/devtools-protocol/

### <a name="Sleep">Пауза(Милисекунды) / Sleep</a>
Приостанавливает выполнение программного кода на заданное количество миллисекунд.

```bsl
ВнешняяКомпонента.Пауза(1000);
```

### <a name="GetDisplayList">ПолучитьСписокДисплеев(ДескрипторОкна) / GetDisplayList</a>
По дескриптору окна получает список дисплеев, на которых располагается окно или его части.

Параметры функции:
- **ДескрипторОкна** (необязательный), Тип: Целое число
Если параметр не задан, будет получена информация обо всех дисплеях.

Тип возвращаемого значения: Строка
- Содержит строку с текстом в формате JSON, при чтении которого получаем объект 
типа ***Массив*** из элементов типа ***Структура*** со свойствами дисплея: координаты 
границ, высота и ширина, наименование дисплея, координаты и размер рабочей области дисплея.

```bsl
ТекстJSON = ВнешняяКомпонента.ПолучитьСписокДисплеев(ДескрипторОкна);
Для каждого ЭлементМассива из ПрочитатьСтрокуJSON(ТекстJSON) Цикл
	ЗаполнитьЗначенияСвойств(СписокДисплеев.Добавить(), ЭлементМассива);
КонецЦикла;
```

### <a name="GetDisplayInfo">ПолучитьСвойстваДисплея(ДескрипторОкна) / GetDisplayInfo</a>
По дескриптору окна получает свойства дисплея, на котором располагается наибольшая часть окна.

Параметры функции:
- **ДескрипторОкна** (необязательный), Тип: Целое число
Если параметр не задан, будет получена информация для активного окна.

Тип возвращаемого значения: Строка
- Содержит строку с текстом в формате JSON, при чтении которого получаем объект 
типа ***Структура*** со свойствами дисплея: координаты границ, высота и ширина,
наименование дисплея, координаты и размер рабочей области дисплея.

```bsl
ТекстJSON = ВнешняяКомпонента.ПолучитьСвойстваДисплея(ДескрипторОкна);
СвойстваДисплея = ПрочитатьСтрокуJSON(ТекстJSON);
ВнешняяКомпонента.УстановитьПозициюОкна(ДескрипторОкна, СвойстваДисплея.Left, СвойстваДисплея.Top);
```

### <a name="GetWindowList">ПолучитьСписокОкон(ИдентификаторПроцесса) / GetWindowList</a>
Возвращает текст в формате JSON, при чтении которого получаем объект типа ***Массив***
из элементов типа ***Структура*** с информацией об окнах, принадлежащих указанному процессу.

Параметры функции:
- **ИдентификаторПроцесса** (обязательный), Тип: Целое число
	- Если параметр нулевой или не задан, возвращается список всех окон.

Тип возвращаемого значения: Строка
- Содержит строку с текстом в формате JSON, при чтении которого получаем объект 
типа ***Массив*** из элементов типа ***Структура*** с информацией о найденых окнах:
	- Window - дескриптор окна (Число)
    - ProcessId - идентификатор процесса (Число)
	- Class - идентификатор класса окна (Строка)
	- Title - заголовок окна (Строка)
	- Owner - окно владелец (Число)

```bsl
ТекстJSON = ВнешняяКомпонента.ПолучитьСписокОкон(ИдентификаторПроцесса);
МассивОкон = ПрочитатьСтрокуJSON(ТекстJSON);
ТаблицаОкон.Очистить();
Для каждого Стр из МассивОкон Цикл
	ЗаполнитьЗначенияСвойств(ТаблицаОкон.Добавить(), Стр);
КонецЦикла;
```

### <a name="GetWindowInfo">ПолучитьСвойстваОкна(ДескрипторОкна) / GetWindowInfo</a>
Возвращает текст в формате JSON, при чтении которого получаем объект 
типа ***Структура*** с информацией об основных свойставх окна:

Параметры функции:
- **ДескрипторОкна** (обязательный), Тип: Целое число
	- Если параметр нулевой, будут получены свойства активного окна.

Тип возвращаемого значения: Строка
- Содержит строку с текстом в формате JSON, при чтении которого получаем объект 
типа ***Структура*** с информацией об основных свойствах окна:
	- Window - дескриптор окна (Число)
    - ProcessId - идентификатор процесса (Число)
	- Maximized - распахнуто, максимизировано (Булево)
	- Class - идентификатор класса окна (Строка)
	- Title - заголовок окна (Строка)
	- Owner - окно владелец (Число)

```bsl
ТекстJSON = ВнешняяКомпонента.ПолучитьСписокОкон(ИдентификаторПроцесса);
СвойстваОкна = ПрочитатьСтрокуJSON(ТекстJSON);
ЗаголовокОкна = СвойстваОкна.Title;
```

### <a name="GetWindowSize">ПолучитьРазмерОкна(ДескрипторОкна) / GetWindowSize</a>
Возвращает текст в формате JSON, при чтении которого получаем объект объект 
типа ***Структура*** с информацией о размерах и позиции окна.

Параметры функции:
- **ДескрипторОкна** (обязательный), Тип: Целое число
	- Если параметр нулевой, будут получены размеры активного окна.

Тип возвращаемого значения: Строка
- Содержит строку с текстом в формате JSON, при чтении которого получаем объект 
типа ***Структура*** с информацией о размерах и позиции окна:
    - Left - левая граница (Число)
	- Top - верхняя граница (Число)
	- Right - правая граница (Строка)
	- Bottom - нижняя граница (Строка)
	- Width - ширина окна (Число)
	- Height - высота высота (Число)
	- Window - дескриптор окна (Число)

### <a name="ActivateWindow">АктивироватьОкно(ДескрипторОкна) / ActivateWindow</a>
Активирует окно по дескриптору.

Параметры функции:
- **ДескрипторОкна** (обязательный), Тип: Целое число

```bsl
ВнешняяКомпонента.АктивироватьОкно(ДескрипторОкна);
```
### <a name="MaximixeWindow">РаспахнутьОкно(ДескрипторОкна) / MaximixeWindow</a>
Распахиват (максимизирует) окно, разворачивая его на всё рабочую область экрана.

Параметры функции:
- **ДескрипторОкна** (обязательный), Тип: Целое число

```bsl
ВнешняяКомпонента.РаспахнутьОкно(ДескрипторОкна);
```
### <a name="RestoreWindow">РазвернутьОкно(ДескрипторОкна) / RestoreWindow</a>
Показывает окно в нормальном режиме отображения, если оно было свёрнуто или распахнуто.

Параметры функции:
- **ДескрипторОкна** (обязательный), Тип: Целое число

```bsl
ВнешняяКомпонента.РазвернутьОкно(ДескрипторОкна);
```

### <a name="SetCursorPos">УстановитьПозициюКурсора(X , Y) / SetCursorPos</a>
Перемещает позицию курсора (мышки) в указанную точку экрана.

### <a name="TakeScreenshot">ПолучитьСнимокЭкрана(Режим) / TakeScreenshot</a>
Получает снимок экрана или активного окна, в зависимости от переданного параметра.

Параметры функции:
- **Режим** (обязательный), Тип: Целое число
    - 0 - Чтобы сделать снимок всего экрана
    - 1 - Чтобы сделать снимок области активного окна

Тип возвращаемого значения: Двоичные данные
- Возвращает картинку в формате PNG.

```bsl
ДвоичныеДанные = ВнешняяКомпонента.ПолучитьСнимокЭкрана(0);
```

### <a name="CaptureWindow">ПолучитьСнимокОкна(ДескрипторОкна) / CaptureWindow</a>
Получает снимок произвольного окна по его дескриптору.

Параметры функции:
- **ДескрипторОкна** (обязательный), Тип: Целое число
    - 0 - Чтобы сделать снимок активного окна

Тип возвращаемого значения: Двоичные данные
- Возвращает картинку в формате PNG.

```bsl
ДвоичныеДанные = ВнешняяКомпонента.ПолучитьСнимокОкна(ДескрипторОкна);
```

### <a name="CaptureProcess">ПолучитьСнимокПроцесса(ИдентификаторПроцесса) / CaptureProcess</a>
Получает снимок верхнего окна экземпляра 1С:Предприятие по идентификатору процесса.

Параметры функции:
- **ИдентификаторПроцесса** (обязательный), Тип: Целое число
    - Идентификатор процесса приложения 1С:Предприятие

Тип возвращаемого значения: Двоичные данные
- Возвращает картинку в формате PNG.

```bsl
ДвоичныеДанные = ВнешняяКомпонента.ПолучитьСнимокПроцесса(ИдентификаторПроцесса);
```

### <a name="EmptyClipboard">ОчиститьБуферОбмена() / EmptyClipboard</a>
Очищает буфер обмена.

```bsl
ВнешняяКомпонента.ОчиститьБуферОбмена();
```

## <a name="ClipboardClipboard">Работа с буфером обмена: ClipboardControl</a>

Внешняя компонента содержит также отдельный класс для работы с буфером обмена.
Для создания объекта доступа к буферу обмена используйте имя **ClipboardControl**.

```bsl
&НаКлиенте
Перем БуферОбмена;

&НаКлиенте
Процедура ПодключениеВнешнейКомпонентыЗавершение(Подключение, ДополнительныеПараметры) Экспорт
	БуферОбмена = Новый("AddIn." + ИдентификаторКомпоненты + ".ClipboardControl");
КонецПроцедуры	

```
### Свойства
- Текст / Text</a>
- Картинка / Image</a>
- Файлы / Files</a>
- Формат / Format</a>
- Версия / Version</a>

### Методы
- ЗаписатьТекст / SetText
- ЗаписатьФайлы / SetFiles
- ЗаписатьКартинку / SetImage
- ЗаписатьДанные / SetData
- Очистить / Empty

***

При разработке использовались библиотеки:
- [cpp-c11-make-screenshot by Roman Shuvalov](https://github.com/Butataki/cpp-x11-make-screenshot)
- [Clip Library by David Capello](https://github.com/dacap/clip)
- [Boost C++ Libraries](https://www.boost.org/)