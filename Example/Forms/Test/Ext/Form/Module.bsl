﻿&НаСервере
Перем Соединение, МодульСервера, КоличествоТестов, КоличествоОшибок, КоличествоПроблем, ИмяФайлаОбработки, ВремяСтарта;

&НаСервере
Перем ИдКомпоненты, АдресКомпоненты;

&НаСервере
Перем Значение, ВК, ПК, Буф, git;

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Автотестирование Тогда
		ПодключитьОбработчикОжидания("ЗавершитьРаботу", 1, Истина);
	Иначе
		Для каждого ЭлементСписка из СписокУзлов Цикл
			Элементы.Результаты.Развернуть(ЭлементСписка.Значение, Истина);
		КонецЦикла;
		СписокУзлов.Очистить();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьРаботу()
	
	ЗавершитьРаботуСистемы(Ложь);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("Автотестирование", Автотестирование);
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ФайлОбработки = Новый Файл(ОбработкаОбъект.ИспользуемоеИмяФайла);
	ИмяФайлаОбработки = ФайлОбработки.Имя;
	ТекущийКаталог = ФайлОбработки.Путь;
	
	ИдКомпоненты = "_" + StrReplace(New UUID, "-", "");
	МакетКомпоненты = ОбработкаОбъект.ПолучитьМакет("VanessaExt");
	АдресКомпоненты = ПоместитьВоВременноеХранилище(МакетКомпоненты, УникальныйИдентификатор);
	
	КоличествоТестов = 0;
	КоличествоОшибок = 0;
	КоличествоПроблем = 0;
	
	Если Автотестирование Тогда
		Попытка
			МодульСервера = Вычислить("AppServer");
			Соединение = МодульСервера.СоздатьСоединение();
			ВыполнитьТесты();
			Если КоличествоОшибок = 0 И КоличествоПроблем = 0 Тогда
				ЗаписьТекста = Новый ЗаписьТекста(ТекущийКаталог + "success.txt");
				ЗаписьТекста.ЗаписатьСтроку(ТекущаяУниверсальнаяДата());
				ЗаписьТекста.Закрыть();
			КонецЕсли;
		Исключение
			Лог = Новый ЗаписьТекста(ТекущийКаталог + "autotest.log");
			Лог.ЗаписатьСтроку(ИнформацияОбОшибке().Описание);
			Лог.Закрыть();
		КонецПопытки;
	Иначе
		ВыполнитьТесты();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция JSON(ТекстJSON)
	
	Если ПустаяСтрока(ТекстJSON) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ПоляДаты = Новый Массив;
	ПоляДаты.Добавить("CreationDate");
	ПоляДаты.Добавить("date");
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(ТекстJSON);
	Возврат ПрочитатьJSON(ЧтениеJSON, , ПоляДаты);
	
КонецФункции

&НаСервере
Функция ДобавитьГруппуТестов(Родитель, Наименование)
	
	ВремяСтарта = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Стр = Родитель.ПолучитьЭлементы().Добавить();
	СписокУзлов.Добавить(Стр.ПолучитьИдентификатор());
	Стр.Наименование = Наименование;
	Возврат Стр;
	
КонецФункции

&НаСервере
Процедура УстановитьФлагОшибки(ТекСтр)
	
	Если Автотестирование Тогда
		МодульСервера.ОтправитьСообщение(Соединение, ТекСтр.Наименование, "Error", ТекСтр.Результат);
	КонецЕсли;
	
	Стр = ТекСтр;
	Пока Стр <> Неопределено Цикл
		Стр.Ошибка = Истина;
		Стр = Стр.ПолучитьРодителя();
	КонецЦикла;
	
	КоличествоОшибок = КоличествоОшибок + 1;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьФлагПроблемы(ТекСтр)
	
	Если Автотестирование Тогда
		МодульСервера.ОтправитьСообщение(Соединение, ТекСтр.Наименование, "Warning", ТекСтр.Результат);
	КонецЕсли;
	
	Стр = ТекСтр;
	Пока Стр <> Неопределено Цикл
		Стр.Проблема = Истина;
		Стр = Стр.ПолучитьРодителя();
	КонецЦикла;
	
	КоличествоПроблем = КоличествоПроблем + 1;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьГруппуТестов(ТекСтр)
	
	Если Автотестирование Тогда
		Статус = ?(ТекСтр.Ошибка, "Failed", ?(ТекСтр.Проблема, "Inconclusive", "Passed"));
		Длительность = ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяСтарта;
		МодульСервера.ОтправитьТест(Соединение, ТекСтр.Наименование, ИмяФайлаОбработки, Длительность, Статус);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ТестВычислить(Группа, ИмяТеста, Выражение, Эталон = "")
	
	КоличествоТестов = КоличествоТестов + 1;
	Стр = Группа.ПолучитьЭлементы().Добавить();
	Стр.Наименование = ИмяТеста;
	Стр.Выражение = Выражение;
	Попытка
		Значение = Вычислить(Выражение);
		Стр.Результат = Значение;
		Стр.Подробности = Значение;
		Если Не ПустаяСтрока(Эталон) Тогда
			Стр.Эталон = Эталон;
			Попытка
				РезультатПроверки = Вычислить(Эталон) = Истина;
			Исключение
				РезультатПроверки = Ложь;
				Информация = ИнформацияОбОшибке();
				Стр.Подробности = ПодробноеПредставлениеОшибки(Информация);
			КонецПопытки;
			Если Не РезультатПроверки Тогда
				УстановитьФлагПроблемы(Стр);
			КонецЕсли;
		КонецЕсли;
	Исключение
		Значение = Неопределено;
		Информация = ИнформацияОбОшибке();
		Стр.Результат = КраткоеПредставлениеОшибки(Информация);
		Стр.Подробности = ПодробноеПредставлениеОшибки(Информация);
		УстановитьФлагОшибки(Стр);
	КонецПопытки;
	
	Возврат Значение;
	
КонецФункции

&НаСервере
Процедура ТестВыполнить(Группа, ИмяТеста, Выражение, Эталон = "")
	
	КоличествоТестов = КоличествоТестов + 1;
	Стр = Группа.ПолучитьЭлементы().Добавить();
	Стр.Наименование = ИмяТеста;
	Стр.Выражение = Выражение;
	Попытка
		Выполнить(Выражение);
		Если Не ПустаяСтрока(Эталон) Тогда
			Стр.Эталон = Эталон;
			Попытка
				РезультатПроверки = Вычислить(Эталон) = Истина;
			Исключение
				РезультатПроверки = Ложь;
				Информация = ИнформацияОбОшибке();
				Стр.Подробности = ПодробноеПредставлениеОшибки(Информация);
			КонецПопытки;
			Если Не РезультатПроверки Тогда
				УстановитьФлагПроблемы(Стр);
			КонецЕсли;
		КонецЕсли;
	Исключение
		Значение = Неопределено;
		Информация = ИнформацияОбОшибке();
		Стр.Результат = КраткоеПредставлениеОшибки(Информация);
		Стр.Подробности = ПодробноеПредставлениеОшибки(Информация);
		УстановитьФлагОшибки(Стр);
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьЛоготип1С()
	
	ФайлРесурса = "v8res://mngbase/About.lf";
	ВременныйФайл = ПолучитьИмяВременногоФайла();
	КопироватьФайл(ФайлРесурса, ВременныйФайл);
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.Прочитать(ВременныйФайл);
	УдалитьФайлы(ВременныйФайл);
	
	Стр = ТекстовыйДокумент.ПолучитьТекст();
	НачПоз = СтрНайти(Стр, "{#base64:");
	КонПоз = СтрНайти(Стр, "}", , НачПоз);
	Стр = Сред(Стр, НачПоз + 9, КонПоз - НачПоз - 9);
	ДвоичныеДанные = Base64Значение(Стр);
	
	Картинка = Новый Картинка(ДвоичныеДанные);
	Соответствие = Новый Соответствие;
	Соответствие.Вставить("screenDensity", "xdpi");
	Возврат Картинка.ПолучитьДвоичныеДанные(Ложь, Соответствие);
	
КонецФункции

&НаСервере
Процедура ВыполнитьТесты()
	
	Группа = ДобавитьГруппуТестов(Результаты, "Инициализация библиотеки");
	ТестВычислить(Группа, "ПодключениеБиблиотеки", "ПодключитьВнешнююКомпоненту(АдресКомпоненты, ИдКомпоненты, ТипВнешнейКомпоненты.Native)");
	ВК = ТестВычислить(Группа, "Новый:WindowsControl", "Новый(""AddIn." + ИдКомпоненты + ".WindowsControl"")");
	ПК = ТестВычислить(Группа, "Новый:ProcessControl", "Новый(""AddIn." + ИдКомпоненты + ".ProcessControl"")");
	Буф = ТестВычислить(Группа, "Новый:ClipboardControl", "Новый(""AddIn." + ИдКомпоненты + ".ClipboardControl"")");
	git = ТестВычислить(Группа, "Новый:GitFor1C", "Новый(""AddIn." + ИдКомпоненты + ".GitFor1C"")");
	ЗаписатьГруппуТестов(Группа);
	
	Группа = ДобавитьГруппуТестов(Результаты, "Свойства WindowsControl");
	ТестВычислить(Группа, "Получить: Version", "ВК.Version");
	ТестВычислить(Группа, "Получить: Версия", "ВК.Версия");
	ТестВычислить(Группа, "Получить: ВЕРСИЯ", "ВК.ВЕРСИЯ");
	ТестВычислить(Группа, "Получить: ProcessId", "ВК.ProcessId", "Значение > 0");
	ТестВычислить(Группа, "ИдентификаторПроцесса", "ВК.ИдентификаторПроцесса", "Значение > 0");
	ТестВыполнить(Группа, "Установить: ТекстБуфераОбмена", "ВК.ТекстБуфераОбмена = ""ТекстБуфера""");
	ТестВычислить(Группа, "Получить: ТекстБуфераОбмена", "ВК.ТекстБуфераОбмена", "Значение = ""ТекстБуфера""");
	ТестВычислить(Группа, "Получить: ТекстБуфераОбмена", "ВК.ТекстБуфераОбмена", "Значение = ""ТекстБуфера""");
	ТестВыполнить(Группа, "Установить: КартинкаБуфераОбмена", "ВК.КартинкаБуфераОбмена = ПолучитьЛоготип1С()");
	ТестВычислить(Группа, "Получить: КартинкаБуфераОбмена", "ВК.КартинкаБуфераОбмена", "ТипЗнч(Значение) = Тип(""ДвоичныеДанные"")");
	ТестВычислить(Группа, "Получить: Формат картинки", "Новый Картинка(Значение)", "Значение.Формат() = ФорматКартинки.PNG");
	ТестВычислить(Группа, "Получить: СвойстваЭкрана", "ВК.СвойстваЭкрана");
	ТестВычислить(Группа, "Получить: СписокДисплеев", "ВК.СписокДисплеев");
	ТестВычислить(Группа, "Получить: СписокОкон", "ВК.СписокОкон");
	ТестВычислить(Группа, "Получить: АктивноеОкно", "ВК.АктивноеОкно");
	ТестВычислить(Группа, "Получить: ПозицияКурсора", "ВК.ПозицияКурсора");
	ЗаписатьГруппуТестов(Группа);
	
	Группа = ДобавитьГруппуТестов(Результаты, "Методы WindowsControl");
	ТестВычислить(Группа, "ПолучитьСписокОкон(PID)", "ВК.ПолучитьСписокОкон(ВК.ИдентификаторПроцесса)");
	ТестВычислить(Группа, "ПолучитьСвойстваОкна(hWnd)", "ВК.ПолучитьСвойстваОкна(ВК.АктивноеОкно)", "JSON(Значение).ProcessId = ВК.ProcessId");
	ТестВыполнить(Группа, "Пауза(100)", "ВК.Пауза(100)");
	ЗаписатьГруппуТестов(Группа);
	
	ИмяПапки = "Autotest";
	ВременнаяПапка = ПолучитьИмяВременногоФайла("git");
	УдалитьФайлы(ВременнаяПапка);
	СоздатьКаталог(ВременнаяПапка);
	ВременнаяПапка = ВременнаяПапка + "/" + ИмяПапки + "/";
	СоздатьКаталог(ВременнаяПапка);
	
	ИмяФайла = "example.txt";
	ПолноеИмя = ВременнаяПапка + ИмяФайла;
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.ДобавитьСтроку(ЧислоПрописью(51243, "L=en_US"));
	ТекстовыйДокумент.ДобавитьСтроку(ЧислоПрописью(24565, "L=en_US"));
	ТекстовыйДокумент.Записать(ПолноеИмя, КодировкаТекста.UTF8);
	
	Группа = ДобавитьГруппуТестов(Результаты, "Тетирование GitFor1C");
	ТестВычислить(Группа, "version", "git.version");
	ТестВычислить(Группа, "init", "git.init(""" + ВременнаяПапка + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "status", "git.status()", "JSON(Значение).result.work[0].new_name = ""example.txt""");
	ТестВычислить(Группа, "add", "git.add(""" + ИмяФайла + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "status", "git.status()", "JSON(Значение).result.index[0].new_name = ""example.txt""");
	ТестВычислить(Группа, "status", "git.status()");
	ЗаписатьГруппуТестов(Группа);
	
КонецПроцедуры