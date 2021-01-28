﻿#Область НаборТестов

&НаКлиенте
Процедура ЗаполнитьНаборТестов(ЮнитТест) Экспорт
	
	ЮнитТест.Добавить("Тест_ИнициализацияБиблиотеки", "Инициализация библиотеки");
	ЮнитТест.Добавить("Тест_СвойстваУправлениеОкнами", "Свойства WindowsControl");
	ЮнитТест.Добавить("Тест_МетодыУправлениеОкнами", "Методы WindowsControl");
	ЮнитТест.Добавить("Тест_ПолучениеСнимкаЭкрана", "Получение снимка экрана");
	ЮнитТест.Добавить("Тест_РегулярныеВыражения", "Регулярные выражения");
	ЮнитТест.Добавить("Тест_МетодыВизуаилзации", "Методы визуализации");
	ЮнитТест.Добавить("Тест_ЗапускПриложений", "Запуск приложений");
	ЮнитТест.Добавить("Тест_БуферОбмена", "Работа с буфером обмена");
	ЮнитТест.Добавить("Тест_ФункционалGit", "Тест функционала Git");
	ЮнитТест.Добавить("Тест_КлиентWebSocket", "Клиент WebSocket");
	ЮнитТест.Добавить("Тест_ПоискФайлов", "Поиск файлов");
	
КонецПроцедуры

&НаКлиенте
Процедура Тест_ИнициализацияБиблиотеки(Ожидается) Экспорт
	
	ИменаКомпонент = Новый Структура("WindowsControl,ProcessControl,ClipboardControl,GitFor1C");
	Для каждого КлючЗначение из ИменаКомпонент Цикл
		ИмяКомпоненты = "AddIn." + Ожидается.ИдентификаторКомпоненты + "." + КлючЗначение.Ключ;
		Ожидается.Тест().Компонента(КлючЗначение.Ключ).ИмеетТип(ИмяКомпоненты);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Тест_СвойстваУправлениеОкнами(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("WindowsControl").Вернуть();
	
	Ожидается.Тест().Что(ВК).Получить("Version").ИмеетТип("Строка");
	Ожидается.Тест().Что(ВК).Получить("Версия").ИмеетТип("Строка");
	Ожидается.Тест().Что(ВК).Получить("ВЕРСИЯ").ИмеетТип("Строка");
	Ожидается.Тест().Что(ВК).Ошибка().Получить("UnknownProp");
	Ожидается.Тест().Что(ВК).Получить("ProcessId").Больше(0);
	Ожидается.Тест().Что(ВК).Получить("ИдентификаторПроцесса").Больше(0);
	Ожидается.Тест().Что(ВК).Получить("АктивноеОкно").Больше(0);
	
	Ожидается.Тест().Что(ВК).Получить("СвойстваЭкрана");
	Ожидается.Тест().Что(ВК).Получить("СписокДисплеев");
	Ожидается.Тест().Что(ВК).Получить("СписокОкон");
	Ожидается.Тест().Что(ВК).Получить("ПозицияКурсора");
	
КонецПроцедуры

&НаКлиенте
Процедура Тест_БуферОбмена(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("WindowsControl").Вернуть();
	
	ИмяСвойства = "ТекстБуфераОбмена";
	ТестовыеДанные = "Текст примера для проверки";
	Ожидается.Тест().Что(ВК).Установить(ИмяСвойства, ТестовыеДанные);
	Ожидается.Тест().Что(ВК).Получить(ИмяСвойства).Равно(ТестовыеДанные);
	Ожидается.Тест().Что(ВК).Проц("ОчиститьБуферОбмена");
	Ожидается.Тест().Что(ВК).Получить(ИмяСвойства).Равно("");
	
	ИмяСвойства = "КартинкаБуфераОбмена";
	ТестовыеДанные = ПолучитьЛоготип1С();
	ИсходнаяКартинка = Новый Картинка(ТестовыеДанные);
	Ожидается.Тест().Что(ВК).Установить(ИмяСвойства, ТестовыеДанные);
	ДанныеБуфера = Ожидается.Тест().Что(ВК).Получить(ИмяСвойства).ЭтоКартинка().Вернуть();
	КартинкаБуфера = Новый Картинка(ДанныеБуфера);
	Ожидается.Тест("Ширина картинки").Что(КартинкаБуфера).Функц("Ширина").Равно(ИсходнаяКартинка.Ширина());
	Ожидается.Тест("Высота картинки").Что(КартинкаБуфера).Функц("Высота").Равно(ИсходнаяКартинка.Высота());
	Ожидается.Тест().Что(ВК).Проц("ОчиститьБуферОбмена");
	Ожидается.Тест().Что(ВК).Получить(ИмяСвойства).Ошибка().ЭтоКартинка();
	
КонецПроцедуры

&НаКлиенте
Процедура Тест_МетодыУправлениеОкнами(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("WindowsControl").Вернуть();
	
	Ожидается.Тест().Что(ВК).Функц("НайтиКлиентТестирования", 48000);
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСписокПроцессов", Истина);
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСписокДисплеев");
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСвойстваОкна", 0);
	Ожидается.Тест().Что(ВК).Ошибка().Функц("UnknownFunc");
	Ожидается.Тест().Что(ВК).Ошибка().Функц("UnknownProc");
	
	ИдентификаторПроцесса = Ожидается.Тест().Что(ВК).Получить("ИдентификаторПроцесса").Вернуть();
	Ожидается.Тест().Что(ВК).Проц("АктивироватьПроцесс", ИдентификаторПроцесса);
	ИдентификаторОкна = Ожидается.Тест().Что(ВК).Получить("АктивноеОкно").Вернуть();
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСвойстваОкна", ИдентификаторОкна).Получить("ProcessId").Равно(ИдентификаторПроцесса);
	
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСписокДисплеев", ИдентификаторОкна);
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСвойстваДисплея", ИдентификаторОкна);
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСвойстваОкна", ИдентификаторОкна);
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСписокОкон", ИдентификаторПроцесса);
	
	Размеры = Ожидается.Тест().Что(ВК).Функц("ПолучитьРазмерОкна", ИдентификаторОкна).JSON().Вернуть();
	Ожидается.Тест().Что(ВК).Проц("АктивироватьОкно", ИдентификаторОкна);
	Ожидается.Тест().Что(ВК).Проц("РаспахнутьОкно", ИдентификаторОкна);
	Ожидается.Тест().Что(ВК).Проц("РазвернутьОкно", ИдентификаторОкна);
	Ожидается.Тест().Что(ВК).Проц("СвернутьОкно", ИдентификаторОкна);
	Ожидается.Тест().Что(ВК).Проц("Пауза", 100);
	Ожидается.Тест().Что(ВК).Проц("РазвернутьОкно", ИдентификаторОкна);
	
	Ожидается.Тест().Что(ВК).Проц("УстановитьРазмерОкна", ИдентификаторОкна, Размеры.Width - 1, Размеры.Height - 1);
	Ожидается.Тест().Что(ВК).Проц("УстановитьПозициюОкна", ИдентификаторОкна, Размеры.Left + 1, Размеры.Top + 1);
	НовыеРазмеры = Ожидается.Тест().Что(ВК).Функц("ПолучитьРазмерОкна", ИдентификаторОкна).JSON().Вернуть();
	
	РазмерыСовпали = Истина
		И (Размеры.Left + 1 = НовыеРазмеры.Left)
		И (Размеры.Top + 1 = НовыеРазмеры.Top)
		И (Размеры.Width - 1 = НовыеРазмеры.Width)
		И (Размеры.Height - 1 = НовыеРазмеры.Height)
		И (Размеры.Right = НовыеРазмеры.Right)
		И (Размеры.Bottom = НовыеРазмеры.Bottom);
	
	Ожидается.Тест("Размеры и позиция окна совпали").Что(РазмерыСовпали).ЕстьИстина();
	
	Текст = Символы.ПС + "Пример вывода текста в консоль" + Символы.ПС;
	Ожидается.Тест().Что(ВК).Функц("ВывестиВКонсоль", Текст).ЕстьИстина();
	
КонецПроцедуры

&НаКлиенте
Процедура Тест_ПолучениеСнимкаЭкрана(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("WindowsControl").Вернуть();
	
	ИдентификаторОкна = Ожидается.Тест().Что(ВК).Получить("АктивноеОкно").Вернуть();
	Размеры = Ожидается.Тест().Что(ВК).Функц("ПолучитьРазмерОкна", ИдентификаторОкна).JSON().Вернуть();
	
	СнимокОбласти = Ожидается.Тест().Что(ВК).Функц("ПолучитьСнимокОбласти", Размеры.Left, Размеры.Top, Размеры.Width, Размеры.Height).ЭтоКартинка().Вернуть();
	СнимокЭкрана = Ожидается.Тест().Что(ВК).Функц("ПолучитьСнимокЭкрана").ЭтоКартинка().Вернуть();
	СнимокОкна = Ожидается.Тест().Что(ВК).Функц("ПолучитьСнимокЭкрана", 1).ЭтоКартинка().Вернуть();
	
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСнимокОкна", ИдентификаторОкна).ЭтоКартинка();
	Ожидается.Тест().Что(ВК).Функц("ПолучитьСнимокОкна").ЭтоКартинка();
	
	Координаты = Ожидается.Тест().Что(ВК).Функц("НайтиФрагмент", СнимокЭкрана, СнимокОбласти).JSON().Вернуть();
	Ожидается.Тест("Фрагмент найден на картинке").Что(Координаты).Получить("Match").Больше(0.9);
	Координаты = Ожидается.Тест().Что(ВК).Функц("НайтиНаЭкране", СнимокОбласти).JSON().Вернуть();
	Ожидается.Тест("Фрагмент найден на экране").Что(Координаты).Получить("Match").Больше(0.9);
	
КонецПроцедуры

&НаКлиенте
Процедура Тест_РегулярныеВыражения(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("RegExp1C").Вернуть();

	Ожидается.Тест("Замена строки").Что(ВК).Функц("Заменить", "AAAA-12222-BBBBB-44455", "(\w+)-(\d+)-(\w+)-(\d+)", "$1*$2*$3*$4").Равно("AAAA*12222*BBBBB*44455");
	
	ПримерТекста = "Пример текста" + Символы.Таб  + "для" + Символы.НПП + "разбинения  строки";
	ЭталонТекста = "[""Пример"",""текста"",""для"",""разбинения"",""строки""]";
	Ожидается.Тест("Разбиение строки").Что(ВК).Функц("Разделить", ПримерТекста, "\s+").Равно(ЭталонТекста);

КонецПроцедуры

&НаКлиенте
Процедура Тест_МетодыВизуаилзации(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("WindowsControl").Вернуть();
	
	Длительность = 2000;
	
	ИдентификаторПроцесса = Ожидается.Тест().Что(ВК).Получить("ИдентификаторПроцесса").Вернуть();
	ИдентификаторОкна = Ожидается.Тест().Что(ВК).Функц("ПолучитьОкноПроцесса", ИдентификаторПроцесса).Вернуть();
	Размеры = Ожидается.Тест().Что(ВК).Функц("ПолучитьРазмерОкна", ИдентификаторОкна).JSON().Вернуть();
	Ожидается.Тест().Что(ВК).Проц("УстановитьПозициюКурсора", Размеры.Left, Размеры.Top);
	Ожидается.Тест().Что(ВК).Проц("ЭмуляцияДвиженияМыши", Размеры.Left + Размеры.Width, Размеры.Top + Размеры.Height, 300, 3);
	Ожидается.Тест().Что(ВК).Проц("УстановитьПозициюКурсора", Размеры.Left + Размеры.Width / 2, Размеры.Top + Размеры.Height / 2);
	Ожидается.Тест().Что(ВК).Проц("ПоказатьНажатиеМыши", 255, 30, 12, 12, 127).Проц("Пауза", Длительность);
	
	ТекстПодсказки = "Тестирование методов визуализации";
	
	НастройкиРисования = Новый Структура;
	НастройкиРисования.Вставить("color", 255);
	НастройкиРисования.Вставить("transparency", 127);
	НастройкиРисования.Вставить("duration", Длительность);
	НастройкиРисования.Вставить("thickness", 5);
	НастройкиРисования.Вставить("frameDelay", 20);
	НастройкиРисования.Вставить("frameCount", 50);
	НастройкиРисования.Вставить("text", ТекстПодсказки);
	НастройкиРисования = ЗаписатьСтрокуJSON(НастройкиРисования);
	
	ТочкиКривой = Новый Массив;
	ТочкиКривой.Добавить(Новый Структура("x,y", Размеры.Left, Размеры.Top));
	ТочкиКривой.Добавить(Новый Структура("x,y", Размеры.Left, Размеры.Top + Размеры.Height));
	ТочкиКривой.Добавить(Новый Структура("x,y", Размеры.Left + Размеры.Width, Размеры.Top));
	ТочкиКривой.Добавить(Новый Структура("x,y", Размеры.Left + Размеры.Width, Размеры.Top + Размеры.Height));
	ТочкиКривой = ЗаписатьСтрокуJSON(ТочкиКривой);
	
	Ожидается.Тест().Что(ВК).Проц("НарисоватьТень", НастройкиРисования, Размеры.Left, Размеры.Top, Размеры.Width, Размеры.Height).Проц("Пауза", Длительность);
	Ожидается.Тест().Что(ВК).Проц("НарисоватьПрямоугольник", НастройкиРисования, Размеры.Left, Размеры.Top, Размеры.Width, Размеры.Height).Проц("Пауза", Длительность);
	Ожидается.Тест().Что(ВК).Проц("НарисоватьЭллипс", НастройкиРисования, Размеры.Left, Размеры.Top, Размеры.Width, Размеры.Height).Проц("Пауза", Длительность);
	Ожидается.Тест().Что(ВК).Проц("НарисоватьСтрелку", НастройкиРисования, Размеры.Left, Размеры.Top + Размеры.Height, Размеры.Left + Размеры.Width, Размеры.Top).Проц("Пауза", Длительность);
	Ожидается.Тест().Что(ВК).Проц("НарисоватьКривую", НастройкиРисования, ТочкиКривой).Проц("Пауза", 1000);
	
КонецПроцедуры	

&НаКлиенте
Процедура Тест_КлиентWebSocket(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("WindowsControl").Вернуть();
	
	ИдентификаторПроцесса = Ожидается.Тест().Что(ВК).Получить("ИдентификаторПроцесса").Вернуть();
	
	Ожидается.Тест("Запуск браузера в режиме отладки");
	КомандаЗапускаБраузера = """" + НайтиБраузер() + """ --remote-debugging-port=9222";
	ЗапуститьПриложение(КомандаЗапускаБраузера);
	
	ВК.Пауза(1000);
	
	КоличествоПопыток = 10;
	ИнтернетАдрес = "https://github.com/";
	Для НомерПопытки = 1 По КоличествоПопыток Цикл
		HTTPЗапрос = Новый HTTPЗапрос("/json/new?" + ИнтернетАдрес);
		Попытка
			HTTPСоединение = Новый HTTPСоединение("localhost", 9222, , , , 10);
			HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос);
			Прервать;
		Исключение
			Если НомерПопытки = КоличествоПопыток Тогда
				ВызватьИсключение "Не удалось подключиться к браузеру";
			КонецЕсли;
		КонецПопытки;
	КонецЦикла;
	
	АдресВебСокет = Ожидается.Тест("Адрес веб сокет").Что(HTTPОтвет).Функц("ПолучитьТелоКакСтроку").Получить("webSocketDebuggerUrl").Вернуть();
	Ожидается.Тест().Что(ВК).Функц("ОткрытьВебСокет", АдресВебСокет);
	
	ТекстJavaScript = "JSON.stringify(window.location)";
	ПараметрыМетода = Новый Структура("expression", ТекстJavaScript);
	ДанныеJSON = Новый Структура("id,method,params", 1, "Runtime.evaluate", ПараметрыМетода);
	КомандаJSON = ЗаписатьСтрокуJSON(ДанныеJSON);
	
	ВК.Пауза(1000);
	Ожидается.Тест().Что(ВК).Функц("ПослатьВебСокет", КомандаJSON).Получить("result", "result", "value").Получить("href").Равно(ИнтернетАдрес);
	
	ОшибочнаяКоманда = "[test:error}";
	Ожидается.Тест("Отправка ошибочного JSON").Что(ВК).Функц("ПослатьВебСокет", ОшибочнаяКоманда).JSON().Получить("error", "message").ИмеетТип("Строка");
	
	ДанныеJSON = Новый Структура("id,method,params", 1, "Vanessa.WebSocket", ПараметрыМетода);
	КомандаJSON = ЗаписатьСтрокуJSON(ДанныеJSON);
	Ожидается.Тест("Несуществующая команда").Что(ВК).Функц("ПослатьВебСокет", КомандаJSON).JSON().Получить("error", "message").ИмеетТип("Строка");
	
	Ожидается.Тест().Что(ВК).Проц("ЗакрытьВебСокет");
	НесуществующийАдрес = "ws://localhost:9222/unknownaddress/error";
	Ожидается.Тест("Открыть несуществующий адрес").Что(ВК).Функц("ОткрытьВебСокет", НесуществующийАдрес).JSON().Получить("error", "message").ИмеетТип("Строка");
	Ожидается.Тест("Отправка данных, сокет закрыт").Что(ВК).Функц("ПослатьВебСокет", КомандаJSON).JSON().Получить("error", "message").ИмеетТип("Строка");
	
	ПараметрыМетода = Новый Структура("format,quality,fromSurface", "png", 85, Ложь);
	ДанныеJSON = Новый Структура("id,method,params", 1, "Page.captureScreenshot", ПараметрыМетода);
	КомандаJSON = ЗаписатьСтрокуJSON(ДанныеJSON);
	Ожидается.Тест().Что(ВК).Функц("ВебСокет", АдресВебСокет, КомандаJSON).Получить("result", "data").Base64().ЭтоКартинка();
	
	Ожидается.Тест().Что(ВК).Проц("АктивироватьПроцесс", ИдентификаторПроцесса);
	
КонецПроцедуры

&НаКлиенте
Процедура Тест_ПоискФайлов(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("WindowsControl").Вернуть();
	
	ВременнаяПапка = ПолучитьИмяВременногоФайла();
	ВложеннаяПапка = ВременнаяПапка + "/Вложенная папка";
	УдалитьФайлы(ВременнаяПапка);
	СоздатьКаталог(ВременнаяПапка);
	СоздатьКаталог(ВложеннаяПапка);
	
	ИскомыйТекст = "Пример поиска Текста";
	СлучайныйТекстовыйФайл(ВременнаяПапка, "other.txt", "Произвольный текст");
	СлучайныйТекстовыйФайл(ВременнаяПапка, "upper.txt", ВРег(ИскомыйТекст));
	СлучайныйТекстовыйФайл(ВложеннаяПапка, "lower.tmp", НРег(ИскомыйТекст));
	СлучайныйТекстовыйФайл(ВложеннаяПапка, "simple.tmp", ИскомыйТекст);
	СлучайныйТекстовыйФайл(ВложеннаяПапка, "textfile.txt", ИскомыйТекст);
	
	ИмяФункции = "НайтиФайлы";
	Ожидается.Тест("С учётом регистра, маска *.*").Что(ВК).Функц(ИмяФункции, ВременнаяПапка, "*.*", ИскомыйТекст, Ложь).JSON().Функц("Количество").Равно(2);
	Ожидается.Тест("С учётом регистра, маска *.txt").Что(ВК).Функц(ИмяФункции, ВременнаяПапка, "*.txt", ИскомыйТекст, Ложь).JSON().Функц("Количество").Равно(1);
	Ожидается.Тест("Без учёта регистра, маска *.*").Что(ВК).Функц(ИмяФункции, ВременнаяПапка, "*.*", ИскомыйТекст, Истина).JSON().Функц("Количество").Равно(4);
	Ожидается.Тест("Без учёта регистра, маска *.txt").Что(ВК).Функц(ИмяФункции, ВременнаяПапка, "*.txt", ИскомыйТекст, Истина).JSON().Функц("Количество").Равно(2);
	Ожидается.Тест("Простой поиск по маске *.txt").Что(ВК).Функц(ИмяФункции, ВременнаяПапка, "*.txt").JSON().Функц("Количество").Равно(3);
	Ожидается.Тест("Простой поиск по маске *.*").Что(ВК).Функц(ИмяФункции, ВременнаяПапка).JSON().Функц("Количество").Равно(5);
	
КонецПроцедуры	

&НаКлиенте
Процедура Тест_ЗапускПриложений(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("WindowsControl").Вернуть();
	
	ВременнаяПапка = ПолучитьИмяВременногоФайла();
	УдалитьФайлы(ВременнаяПапка);
	СоздатьКаталог(ВременнаяПапка);
	
	Команда = "notepad.exe";
	ИмяФайла = "testfile.txt";
	ПутьФайла = ВременнаяПапка + "\" + ИмяФайла;
	ГСЧ = Новый ГенераторСлучайныхЧисел();
	ПримерТекста = ЧислоПрописью(ГСЧ.СлучайноеЧисло(1000, 100000));
	ИдентификаторПроцесса = Ожидается.Тест().Что(ВК).Функц("СоздатьПроцесс", Команда).Вернуть();
	ИдентификаторОкна = Ожидается.Тест("Список окон").Что(ВК).Проц("Пауза", 1000).Функц("ПолучитьСписокОкон", ИдентификаторПроцесса).Получить(0, "Window").Вернуть();
	Ожидается.Тест().Что(ВК).Проц("АктивироватьОкно", ИдентификаторОкна);
	
	Ожидается.Тест().Что(ВК).Проц("УстановитьПозициюОкна", ИдентификаторОкна, 100, 100);
	Ожидается.Тест().Что(ВК).Проц("УстановитьРазмерОкна", ИдентификаторОкна, 800, 600);
	Размеры = Ожидается.Тест().Что(ВК).Функц("ПолучитьРазмерОкна", ИдентификаторОкна).JSON().Вернуть();
	КурсорСлева = Размеры.Left + Размеры.Width / 2;
	КурсорСверху = Размеры.Top + 10;
	Ожидается.Тест().Что(ВК).Проц("УстановитьПозициюКурсора", КурсорСлева, КурсорСверху);
	Ожидается.Тест().Что(ВК).Проц("ЭмуляцияПеретаскивания", КурсорСлева + 100, КурсорСверху + 100, 100, 3);
	НовыеРазмеры = Ожидается.Тест().Что(ВК).Функц("ПолучитьРазмерОкна", ИдентификаторОкна).JSON().Вернуть();
	
	РазмерыСовпали = Истина
		И (Размеры.Left + 100 < НовыеРазмеры.Left + 5)
		И (Размеры.Left + 100 > НовыеРазмеры.Left - 5)
		И (Размеры.Top + 100 < НовыеРазмеры.Top + 5)
		И (Размеры.Top + 100 > НовыеРазмеры.Top - 5);
		
	Ожидается.Тест("Позиция окна ожидаемая").Что(РазмерыСовпали).ЕстьИстина();
	
	Ожидается.Тест().Что(ВК).Проц("АктивироватьОкно", ИдентификаторОкна).Проц("Пауза", 2000).Проц("ЭмуляцияНажатияКлавиши", "[27]");
	Ожидается.Тест("Эмуляция ввода текста").Что(ВК).Проц("Пауза", 2000).Проц("ЭмуляцияВводаТекста", ПримерТекста, 50);
	Ожидается.Тест("Вызов диалогового окна записи файла").Что(ВК).Проц("Пауза", 2000).Проц("ЭмуляцияНажатияКлавиши", "[17, 83]");
	Ожидается.Тест("Ввод имени файла в диалоге").Что(ВК).Проц("Пауза", 2000).Проц("ЭмуляцияВводаТекста", ПутьФайла, 50);
	Ожидается.Тест("Закрытие диалога записи файла").Что(ВК).Проц("Пауза", 2000).Проц("ЭмуляцияНажатияКлавиши", "[13]");
	Ожидается.Тест("Закрытие приложения").Что(ВК).Проц("Пауза", 2000).Проц("ЭмуляцияНажатияКлавиши", "[18, 115]").Проц("Пауза", 2000);
	Ожидается.Тест("Найти сохраненный файл").Что(ВК).Функц("НайтиФайлы", ВременнаяПапка, "*.*", ПримерТекста, Ложь).Получить(0, "name").Равно(ИмяФайла);
	
КонецПроцедуры	

&НаКлиенте
Процедура Тест_ФункционалGit(Ожидается) Экспорт
	
	ВК = Ожидается.Тест().Компонента("GitFor1C").Вернуть();
	
	ИмяПапки = "Autotest";
	ВременнаяПапка = ПолучитьИмяВременногоФайла("git");
	УдалитьФайлы(ВременнаяПапка);
	СоздатьКаталог(ВременнаяПапка);
	
	Репозиторий = ВременнаяПапка + "/" + ИмяПапки + "/";
	Подкаталог = Репозиторий + "test";
	СоздатьКаталог(Репозиторий);
	СоздатьКаталог(Подкаталог);
	
	АдресКлон = "https://github.com/lintest/AddinTemplate.git";
	ПапкаКлон = ВременнаяПапка + "clone";
	ФайлКлон = ПапкаКлон + "/LICENSE";
	
	ИмяФайла = "пример.txt";
	СлучайныйТекстовыйФайл(Репозиторий, ИмяФайла);
	
	Ожидается.Тест().Что(ВК).Получить("Version").ИмеетТип("Строка");
	Ожидается.Тест().Что(ВК).Проц("SetAuthor", "Автор", "author@lintest.ru");
	Ожидается.Тест().Что(ВК).Проц("SetCommitter", "Комиттер", "committer@lintest.ru");
	
	Ожидается.Тест("Клонирование репозитория").Что(ВК).Функц("clone", АдресКлон, ПапкаКлон).Успешно();
	Ожидается.Тест("Проверка сущестования файла").Что(ФайлСуществует(ФайлКлон)).ЕстьИстина();
	Ожидается.Тест("Информация о коммите").Что(ВК).Функц("info", "HEAD").Успешно();
	Репозитории = Ожидается.Тест().Что(ВК).Получить("remotes").Результат().ИмеетТип("Массив").Вернуть();
	Ожидается.Тест("Адрес репозитория").Что(Репозитории).Получить(0, "url").Равно(АдресКлон);
	Ожидается.Тест("Закрытие репозитория").Что(ВК).Функц("close").Успешно();
	
	Ожидается.Тест("Инициализация репозитория").Что(ВК).Функц("init", Репозиторий).Успешно();
	Ожидается.Тест("Статус рабочей области").Что(ВК).Функц("status").Результат().Получить("work", 0, "new_name").Равно(ИмяФайла);
	Ожидается.Тест("Добавление в индекс").Что(ВК).Функц("add", ИмяФайла).Успешно();
	Ожидается.Тест("Статус после добавления").Что(ВК).Функц("status").Результат().Получить("index", 0, "new_name").Равно(ИмяФайла);
	Ожидается.Тест("Первый коммит").Что(ВК).Функц("commit", "Инициализация").Успешно();
	Коммит = Ожидается.Тест("Информация о коммите").Что(ВК).Функц("info", "HEAD").Результат().Вернуть();
	Ожидается.Тест("Автор коммита").Что(Коммит).Получить("authorName").Равно("Автор");
	Ожидается.Тест("Комиттер коммита").Что(Коммит).Получить("committerName").Равно("Комиттер");
	Ожидается.Тест("Закрытие репозитория").Что(ВК).Функц("close").Успешно();
	
	Статус = Ожидается.Тест("Статус закрытого репозитория").Что(ВК).Функц("status").JSON().Вернуть();
	Ожидается.Тест("Статус получить не удалось").Что(Статус).Получить("success").Равно(Ложь);
	Ожидается.Тест("Код ошибки равен нулю").Что(Статус).Получить("error", "code").Равно(0);
	
	ИмяФайла = "текст.txt";
	СлучайныйТекстовыйФайл(Репозиторий, ИмяФайла);
	
	Статус = Ожидается.Тест("Поиск репозитория").Что(ВК).Функц("find", Подкаталог).Успешно().JSON().Вернуть();
	Ожидается.Тест("Открытие репозитория").Что(ВК).Функц("open", Статус.result).Успешно();
	Ожидается.Тест("Статус рабочей области").Что(ВК).Функц("status").Результат().Получить("work", 0, "new_name").Равно(ИмяФайла);
	Ожидается.Тест("Добавление в индекс").Что(ВК).Функц("add", ИмяФайла).Успешно();
	Ожидается.Тест("Статус после добавления").Что(ВК).Функц("status").Результат().Получить("index", 0, "new_name").Равно(ИмяФайла);
	Ожидается.Тест("Второй коммит").Что(ВК).Функц("commit", "Второй коммит").Успешно();
	Ожидается.Тест("Получение истории").Что(ВК).Функц("history").Результат().ИмеетТип("Массив").Функц("Количество").Равно(2);
	Ожидается.Тест("Создание новой ветки").Что(ВК).Функц("checkout", "develop", Истина).Успешно();
	Ожидается.Тест("Список веток").Что(ВК).Получить("branches").Результат().ИмеетТип("Массив").Функц("Количество").Равно(2);
	
	СлучайныйТекстовыйФайл(Репозиторий, ИмяФайла);
	Ожидается.Тест("Добавление в индекс").Что(ВК).Функц("add", ИмяФайла).Успешно();
	Ожидается.Тест("Статус после добавления").Что(ВК).Функц("status").Результат().Получить("index", 0, "new_name").Равно(ИмяФайла);
	Ожидается.Тест("Удаление из индекса").Что(ВК).Функц("reset", ИмяФайла).Успешно();
	Ожидается.Тест("Статус после удаления").Что(ВК).Функц("status").Результат().Получить("work", 0, "new_name").Равно(ИмяФайла);
	Ожидается.Тест("Отмена изменений").Что(ВК).Функц("discard", ИмяФайла).Успешно();
	Ожидается.Тест("Статус после отмены").Что(ВК).Функц("status").Результат().Равно(Неопределено);
	
	СлучайныйТекстовыйФайл(Репозиторий, ИмяФайла);
	Ожидается.Тест("Добавление в индекс").Что(ВК).Функц("add", ИмяФайла).Успешно();
	Ожидается.Тест("Третий коммит").Что(ВК).Функц("commit", "Третий коммит").Успешно();
	Ожидается.Тест("Указатель HEAD").Что(ВК).Получить("head").Результат().Равно("refs/heads/develop");
	Ожидается.Тест("Переключение ветки").Что(ВК).Функц("checkout", "master").Успешно();
	Ожидается.Тест("Указатель HEAD").Что(ВК).Получить("head").Результат().Равно("refs/heads/master");
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедуры

&НаКлиенте
Функция ПрочитатьСтрокуJSON(ТекстJSON)
	
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

&НаКлиенте
Функция ЗаписатьСтрокуJSON(Данные)
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Данные);
	Возврат ЗаписьJSON.Закрыть();
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьЛоготипНаСервере(УникальныйИдентификатор)
	
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
	ДвоичныеДанные = Картинка.ПолучитьДвоичныеДанные(Ложь, Соответствие);
	Возврат ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
	
КонецФункции

&НаКлиенте
Функция ПолучитьЛоготип1С()
	
	Адрес = ПолучитьЛоготипНаСервере(УникальныйИдентификатор);
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(Адрес);
	УдалитьИзВременногоХранилища(Адрес);
	Возврат ДвоичныеДанные;
	
КонецФункции

&НаКлиенте
Функция ПрочитатьТекст(ДвоичныеДанные)
	
	Поток = ДвоичныеДанные.ОткрытьПотокДляЧтения();
	ЧтениеТекста = Новый ЧтениеТекста(Поток);
	Возврат СокрЛП(ЧтениеТекста.Прочитать());
	
КонецФункции

&НаКлиенте
Функция ФайлСуществует(ИмяФайла)
	
	Файл = Новый Файл(ИмяФайла);
	Возврат Файл.Существует();
	
КонецФункции

&НаКлиенте
Функция НайтиБраузер()
	
	СисИнфо = Новый СистемнаяИнформация;
	Если СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86 ИЛИ СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда
		Попытка
			WScriptShell = Новый COMОбъект("WScript.Shell");
		Исключение
			ВызватьИсключение "Не удалось подключить COM объект <WScript.Shell>";
		КонецПопытки;
		ПапкиПоиска = Новый Массив;
		ПапкиПоиска.Добавить("C:\Program Files");
		ПапкиПоиска.Добавить("%ProgramFiles%");
		ПапкиПоиска.Добавить("%ProgramFiles(x86)%");
		ПапкиПоиска.Добавить("%LocalAppData%");
		ИмяФайла = "\Google\Chrome\Application\chrome.exe";
		Для каждого ПапкаПоиска Из ПапкиПоиска Цикл
			ProgramFiles = WScriptShell.ExpandEnvironmentStrings(ПапкаПоиска);
			Файл = Новый Файл(ProgramFiles + ИмяФайла);
			Если Файл.Существует() Тогда
				Возврат Файл.ПолноеИмя;
			КонецЕсли;
		КонецЦикла;
	ИначеЕсли СисИнфо.ТипПлатформы = ТипПлатформы.Linux_x86 ИЛИ СисИнфо.ТипПлатформы = ТипПлатформы.Linux_x86_64 Тогда
		ФайлыПоиска = Новый Массив;
		ФайлыПоиска.Добавить("/snap/bin/chromium");
		ФайлыПоиска.Добавить("/opt/google/chrome/chrome");
		Для каждого ИмяФайла Из ФайлыПоиска Цикл
			Файл = Новый Файл(ИмяФайла);
			Если Файл.Существует() Тогда
				Возврат Файл.ПолноеИмя;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ВызватьИсключение "Не удалось найти интернет-браузер";
	
КонецФункции

&НаКлиенте
Процедура СлучайныйТекстовыйФайл(ИмяПапки, ИмяФайла, ИскомыйТекст = "")

	ГСЧ = Новый ГенераторСлучайныхЧисел();
	НомерСтроки = ГСЧ.СлучайноеЧисло(1, 10);
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	Для Номер = 1 По 10 Цикл
		Если Номер = НомерСтроки Тогда
			НачалоСтроки = ЧислоПрописью(ГСЧ.СлучайноеЧисло(0, 99));
			КонецСтроки = ЧислоПрописью(ГСЧ.СлучайноеЧисло(0, 99));
			ТекстСтроки = НачалоСтроки + ИскомыйТекст + КонецСтроки;
		Иначе
			ТекстСтроки = ЧислоПрописью(ГСЧ.СлучайноеЧисло(100, 999));
		КонецЕсли;
		ТекстовыйДокумент.ДобавитьСтроку(ТекстСтроки);
	КонецЦикла;
	ПолноеИмя = ИмяПапки + "/" + ИмяФайла;
	ТекстовыйДокумент.Записать(ПолноеИмя, КодировкаТекста.UTF8);
	
КонецПроцедуры	

#КонецОбласти