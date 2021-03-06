﻿// Загружает отчет брокера ВТБ
//
// Параметры:
//  ИмяФайла  - Строка - Имя файла на сервере для загрузки
//                 
//
Процедура ЗагрузитьОтчет(ИмяФайла, БрокерскийСчет, РезультатЗагрузки) Экспорт

	//ИмяФайла = "C:\Users\Andrey\Documents\1C\МоиАктивы\ЗагрузкаXML\GetBrokerReport.xml";
	
	// Реализуем последовательное чтение файла порциями, дабы не переполнять память, но и уменьшить количество запросов в цикле
	// Количество одновременно записываемых данных регулируется константой
	// Определенное количество записей читаем в таблицу значений
	// Проверяем их махом на уникальность, находим ссылки на ценную бумагу, формируем документы
	РезультатЗагрузки = Новый Структура("ЗагруженоСделок,ВсегоСделок,ЗаголовокОтчета",0,0,"");
	РезультатЗагрузки.Вставить("ВсегоДенег", 0);
	РезультатЗагрузки.Вставить("ЗагруженоДенег", 0);
	РезультатЗагрузки.Вставить("НомерСоглашения", "");
	//ЗагруженоСделок = 0;
	//ВсегоСделок = 0;
	
	ИмяФайлаСхемы = "C:\Users\Andrey\Documents\1C\МоиАктивы\ЗагрузкаXML\GetBrokerReport_1c.xsd";	
	
	//ЧтениеТекста = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	//СтрокаXML = ЧтениеТекста.Прочитать();
	
	//СхемаXMLВТБ = Новый СхемаXML;
	////СхемаXMLВТБ.ПространствоИмен = "report577p_v1";
	//СхемаXMLВТБ.РасположениеСхемы=ИмяФайлаСхемы;

	//НаборСхемXMLВТБ=Новый НаборСхемXML;
	//НаборСхемXMLВТБ.Добавить(СхемаXMLВТБ);
	
	ЧтениеXMLФайл = Новый ЧтениеXML;
	ЧтениеXMLФайл.ОткрытьФайл(ИмяФайла,,); // Как добавить схему, да еще из пакета????
	
	
	// Получаем типы из свойств
	// Хотя можно просто создать тип ЗавершеннаяСделка
	ПакетВТБ=ФабрикаXDTO.Пакеты.Получить("report577p_v1");
	ТипReport=ПакетВТБ.КорневыеСвойства.Получить("Report").Тип;
	ТипЗавершенныеСделки = ТипReport.Свойства.Получить("ЗавершенныеСделки").Тип;
	ТипСписокЗавершенныхСделок = ТипЗавершенныеСделки.Свойства.Получить("СписокСделок").Тип;
	ТипЗавершеннаяСделка = ТипСписокЗавершенныхСделок.Свойства.Получить("Сделка").Тип;
	
	ТипОтчет = ПакетВТБ.Получить("ТипОтчет");
	
	СвойствоЗаголовокОтчета = ТипОтчет.Свойства.Получить("ЗаголовокОтчета");
	СвойствоДанныеСчета = ТипОтчет.Свойства.Получить("ДанныеСчета");
	// Обходим все движения денег, хотя в образце отчета есть только основной рынок, есть и другие рынки, не учитываем это в обработке
	СвойствоДвижениеДенег = ПакетВТБ.Получить("ТипСписокДвиженийДенег").Свойства.Получить("ДвижениеДенег");
	
	
	// Создаем таблицу значений
	ТипЧисло102 = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10,2));
	ТипСтрока15 = Новый ОписаниеТипов("Строка", Новый КвалификаторыСтроки(15));
	ТипСтрока3 = Новый ОписаниеТипов("Строка", Новый КвалификаторыСтроки(3));
	ТипСтрока = Новый ОписаниеТипов("Строка");
	
	ТипДата = Новый ОписаниеТипов("Дата");
	
	тзСделки = Новый ТаблицаЗначений;
	тзСделки.Колонки.Добавить("ISIN", Новый ОписаниеТипов("Строка", Новый КвалификаторыСтроки(12)));
	тзСделки.Колонки.Добавить("ТипСделки", ТипСтрока15);
	тзСделки.Колонки.Добавить("ДатаСделки", ТипДата);
	тзСделки.Колонки.Добавить("Количество", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10,0)));
	тзСделки.Колонки.Добавить("ВалютаЦены", ТипСтрока3);
	тзСделки.Колонки.Добавить("Цена", ТипЧисло102);
	тзСделки.Колонки.Добавить("ВалютаРасчетов", ТипСтрока3);
	тзСделки.Колонки.Добавить("СуммаСделки", ТипЧисло102);
	тзСделки.Колонки.Добавить("НКД", ТипЧисло102);
	тзСделки.Колонки.Добавить("КомиссияЗаРасчет", ТипЧисло102);
	тзСделки.Колонки.Добавить("КомиссияЗаЗаключение", ТипЧисло102);
	тзСделки.Колонки.Добавить("ДатаПоставки", ТипДата);
	тзСделки.Колонки.Добавить("ДатаОплаты", ТипДата);
	тзСделки.Колонки.Добавить("НомерЗаявки", ТипСтрока15);
	тзСделки.Колонки.Добавить("НомерСделки", ТипСтрока15);
	
	тзДеньги = Новый ТаблицаЗначений;
	тзДеньги.Колонки.Добавить("Дата", ТипДата);
	тзДеньги.Колонки.Добавить("Операция", ТипСтрока);
	тзДеньги.Колонки.Добавить("Сумма", ТипЧисло102);
	тзДеньги.Колонки.Добавить("Валюта", ТипСтрока3);
	тзДеньги.Колонки.Добавить("Комментарий", ТипСтрока);
	
	
	КоличествоЗаписей = 0;
	КоличествоНаПакет = Константы.КоличествоЗаписейВПорцииЗагрузки.Получить();
	
	РезультатЧтения=ЧтениеXMLФайл.Прочитать();
	
	Пока РезультатЧтения Цикл
	
		Если ЧтениеXMLФайл.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			
			Если ЧтениеXMLФайл.Имя = СвойствоЗаголовокОтчета.ЛокальноеИмя Тогда // Заголовок отчета
				хЗаголовокОтчета = ФабрикаXDTO.ПрочитатьXML(ЧтениеXMLФайл, СвойствоЗаголовокОтчета.Тип);
				РезультатЗагрузки.ЗаголовокОтчета = хЗаголовокОтчета.ТекстЗаголовка;
				
			ИначеЕсли ЧтениеXMLФайл.Имя = СвойствоДанныеСчета.ЛокальноеИмя Тогда // Данные отчета
				хДанныеСчета = ФабрикаXDTO.ПрочитатьXML(ЧтениеXMLФайл, СвойствоДанныеСчета.Тип);
				РезультатЗагрузки.НомерСоглашения = хДанныеСчета.НомерСоглашения;
				
			ИначеЕсли ЧтениеXMLФайл.Имя = СвойствоДвижениеДенег.ЛокальноеИмя Тогда // Движение денег
				хДвижениеДенег = ФабрикаXDTO.ПрочитатьXML(ЧтениеXMLФайл, СвойствоДвижениеДенег.Тип);
				НоваяСтрока=тзДеньги.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока,хДвижениеДенег);
				
				КоличествоЗаписей = КоличествоЗаписей + 1;
				РезультатЗагрузки.ВсегоДенег = РезультатЗагрузки.ВсегоДенег + 1;
				
				ЗагрузитьТаблицы(тзДеньги, тзСделки, КоличествоЗаписей, КоличествоНаПакет, БрокерскийСчет, РезультатЗагрузки);

				
			ИначеЕсли ЧтениеXMLФайл.Имя = "Подробности10" Тогда // завершенная сделка
			
				хЗавершеннаяСделка = ФабрикаXDTO.ПрочитатьXML(ЧтениеXMLФайл, ТипЗавершеннаяСделка);
				//Инструмент = хЗавершеннаяСделка.Инструмент;
				ISIN = СокрЛП(СтрРазделить(хЗавершеннаяСделка.Инструмент, ",")[2]);
				НоваяСтрока=тзСделки.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока,хЗавершеннаяСделка);
				НоваяСтрока.ISIN = ISIN;
				
				КоличествоЗаписей = КоличествоЗаписей + 1;
				РезультатЗагрузки.ВсегоСделок = РезультатЗагрузки.ВсегоСделок + 1;
				
				ЗагрузитьТаблицы(тзДеньги, тзСделки, КоличествоЗаписей, КоличествоНаПакет, БрокерскийСчет, РезультатЗагрузки);
				
			Иначе
				
				РезультатЧтения=ЧтениеXMLФайл.Прочитать();
				
			КонецЕсли; 
			
		Иначе
			
			РезультатЧтения=ЧтениеXMLФайл.Прочитать();
			
		КонецЕсли; 	
	
	КонецЦикла;
	
	ЧтениеXMLФайл.Закрыть();
	
	ЗагрузитьТаблицы(тзДеньги, тзСделки, 0, КоличествоНаПакет, БрокерскийСчет, РезультатЗагрузки);
	
	//Пакет=ФабрикаXDTO.Пакеты.Получить("report577p_v1");
	//СвойствоReport=Пакет.КорневыеСвойства.Получить("Report");	
	//
	//Report = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML, СвойствоReport.Тип);
	
	//Объект.СписокСделок.Очистить();	
	//
	//// Список сделок
	//Для каждого Сделка Из Report.ЗавершенныеСделки.СписокСделок.Сделка Цикл
	//
	//	НоваяСтрока=Объект.СписокСделок.Добавить();
	//	НоваяСтрока.Инструмент  = Сделка.Инструмент;
	//	НоваяСтрока.ТипСделки = Сделка.ТипСделки;
	//	НоваяСтрока.ДатаСделки = Сделка.ДатаСделки;
	//	НоваяСтрока.Количество = Сделка.Количество;
	//	НоваяСтрока.Цена = Сделка.Цена;
	//	НоваяСтрока.СуммаСделки = Сделка.СуммаСделки;
	//
	//КонецЦикла; 

КонецПроцедуры

Процедура ЗагрузитьТаблицы(тзДеньги, тзСделки, КоличествоЗаписей, КоличествоНаПакет, БрокерскийСчет, РезультатЗагрузки)

	Если КоличествоЗаписей=0 Тогда // Записать все что есть
	
		Если тзДеньги.Количество()>0 Тогда
			СоздатьДокументыДенег(тзДеньги, БрокерскийСчет, РезультатЗагрузки.ЗагруженоДенег);
		КонецЕсли; 
		
		Если тзСделки.Количество()>0 Тогда
			СоздатьДокументыСделок(тзСделки, БрокерскийСчет, РезультатЗагрузки.ЗагруженоСделок);
		КонецЕсли; 
	
	ИначеЕсли КоличествоЗаписей>=КоличествоНаПакет Тогда  // Записать при превышении количества
	
		СоздатьДокументыДенег(тзДеньги, БрокерскийСчет, РезультатЗагрузки.ЗагруженоДенег);
		СоздатьДокументыСделок(тзСделки, БрокерскийСчет, РезультатЗагрузки.ЗагруженоСделок);
		КоличествоЗаписей = 0;
	
	КонецЕсли; 
	

КонецПроцедуры
 

// Создает документы движения денег
// Контроль уникальности по дате и сумме
Процедура СоздатьДокументыДенег(ТЗ, БрокерскийСчет, ЗагруженоДокументов)

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТЗ.Дата КАК Дата,
		|	ТЗ.Сумма КАК Сумма,
		|	ТЗ.Операция КАК Операция
		|ПОМЕСТИТЬ ДанныеДенег
		|ИЗ
		|	&ТЗ КАК ТЗ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПоступлениеДенежныхСредств.Ссылка КАК Ссылка,
		|	НАЧАЛОПЕРИОДА(ПоступлениеДенежныхСредств.Дата, ДЕНЬ) КАК ДатаНачалоДня,
		|	ПоступлениеДенежныхСредств.Сумма КАК Сумма
		|ПОМЕСТИТЬ СписокДокументов
		|ИЗ
		|	Документ.ПоступлениеДенежныхСредств КАК ПоступлениеДенежныхСредств
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ВыводДенежныхСредств.Ссылка,
		|	НАЧАЛОПЕРИОДА(ВыводДенежныхСредств.Дата, ДЕНЬ),
		|	ВыводДенежныхСредств.Сумма
		|ИЗ
		|	Документ.ВыводДенежныхСредств КАК ВыводДенежныхСредств
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ДепозитарнаяКомиссия.Ссылка,
		|	НАЧАЛОПЕРИОДА(ДепозитарнаяКомиссия.Дата, ДЕНЬ),
		|	ДепозитарнаяКомиссия.Сумма
		|ИЗ
		|	Документ.ДепозитарнаяКомиссия КАК ДепозитарнаяКомиссия
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДанныеДенег.Дата КАК Дата,
		|	ВЫБОР
		|		КОГДА ДанныеДенег.Сумма < 0
		|			ТОГДА -ДанныеДенег.Сумма
		|		ИНАЧЕ ДанныеДенег.Сумма
		|	КОНЕЦ КАК Сумма,
		|	ДанныеДенег.Операция КАК Операция
		|ИЗ
		|	ДанныеДенег КАК ДанныеДенег
		|		ЛЕВОЕ СОЕДИНЕНИЕ СписокДокументов КАК СписокДокументов
		|		ПО ДанныеДенег.Дата = СписокДокументов.ДатаНачалоДня
		|			И ДанныеДенег.Сумма = СписокДокументов.Сумма
		|ГДЕ
		|	СписокДокументов.Ссылка ЕСТЬ NULL";
	
	Запрос.УстановитьПараметр("ТЗ", ТЗ);
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ВыборкаДетальныеЗаписи.Операция = "Зачисление денежных средств" Тогда
		
			НовыйДокумент = Документы.ПоступлениеСредствНаБрокерскийСчет.СоздатьДокумент();
		
		ИначеЕсли ВыборкаДетальныеЗаписи.Операция = "Вознаграждение Депозитария" Тогда
		
			НовыйДокумент = Документы.ДепозитарнаяКомиссия.СоздатьДокумент();
			
		Иначе
			
			Продолжить; // Гранаты не той системы
		
		КонецЕсли;
		
		НовыйДокумент.БрокерскийСчет = БрокерскийСчет;
		ЗаполнитьЗначенияСвойств(НовыйДокумент, ВыборкаДетальныеЗаписи);
		НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
		
		// Добавить в последовательность
		ДобавитьВПоследовательность(НовыйДокумент);

		ЗагруженоДокументов = ЗагруженоДокументов + 1;
		
	КонецЦикла;
	
	
	ТЗ.Очистить();

КонецПроцедуры
 

// Создает документы покупки и продажи по таблице значений
// Контроль уникальности по номеру сделки
Процедура СоздатьДокументыСделок(ТЗ, БрокерскийСчет, ЗагруженоСделок)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТЗ.ТипСделки КАК ТипСделки,
		|	ТЗ.ISIN КАК ISIN,
		|	ТЗ.ДатаСделки КАК ДатаСделки,
		|	ТЗ.Количество КАК Количество,
		|	ТЗ.Цена КАК Цена,
		|	ТЗ.СуммаСделки КАК СуммаСделки,
		|	ТЗ.НКД КАК НКД,
		|	ТЗ.НомерЗаявки КАК НомерЗаявки,
		|	ТЗ.НомерСделки КАК НомерСделки,
		|	ТЗ.КомиссияЗаРасчет КАК КомиссияЗаРасчет,
		|	ТЗ.КомиссияЗаЗаключение КАК КомиссияЗаЗаключение,
		|	ТЗ.ДатаПоставки КАК ДатаПоставки,
		|	ТЗ.ДатаОплаты КАК ДатаОплаты
		|ПОМЕСТИТЬ ДанныеФайла
		|ИЗ
		|	&ТЗ КАК ТЗ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДанныеФайла.ТипСделки КАК ТипСделки,
		|	ДанныеФайла.ISIN КАК ISIN,
		|	ДанныеФайла.ДатаСделки КАК ДатаСделки,
		|	ДанныеФайла.Количество КАК Количество,
		|	ДанныеФайла.Цена КАК Цена,
		|	ДанныеФайла.СуммаСделки КАК СуммаСделки,
		|	ДанныеФайла.НКД КАК НКД,
		|	ДанныеФайла.НомерЗаявки КАК НомерЗаявки,
		|	ДанныеФайла.НомерСделки КАК НомерСделки,
		|	ДанныеФайла.КомиссияЗаРасчет КАК КомиссияЗаРасчет,
		|	ДанныеФайла.КомиссияЗаЗаключение КАК КомиссияЗаЗаключение,
		|	ДанныеФайла.ДатаПоставки КАК ДатаПоставки,
		|	ДанныеФайла.ДатаОплаты КАК ДатаОплаты,
		|	ЦенныеБумаги.Ссылка КАК ЦеннаяБумага
		|ПОМЕСТИТЬ ДанныеФайлаСЦБ
		|ИЗ
		|	ДанныеФайла КАК ДанныеФайла
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ЦенныеБумаги КАК ЦенныеБумаги
		|		ПО ДанныеФайла.ISIN = ЦенныеБумаги.ISIN
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДанныеФайлаСЦБ.ТипСделки КАК ТипСделки,
		|	ДанныеФайлаСЦБ.ISIN КАК ISIN,
		|	ДанныеФайлаСЦБ.ДатаСделки КАК Дата,
		|	ДанныеФайлаСЦБ.Количество КАК Количество,
		|	ДанныеФайлаСЦБ.Цена КАК Цена,
		|	ДанныеФайлаСЦБ.СуммаСделки КАК Сумма,
		|	ДанныеФайлаСЦБ.НКД КАК НКД,
		|	ДанныеФайлаСЦБ.НомерЗаявки КАК НомерЗаявки,
		|	ДанныеФайлаСЦБ.НомерСделки КАК НомерСделки,
		|	ДанныеФайлаСЦБ.КомиссияЗаРасчет КАК КомиссияЗаРасчет,
		|	ДанныеФайлаСЦБ.КомиссияЗаЗаключение КАК КомиссияЗаЗаключение,
		|	ДанныеФайлаСЦБ.ДатаПоставки КАК ВремяПоставки,
		|	ДанныеФайлаСЦБ.ДатаОплаты КАК ВремяПлатежа,
		|	ДанныеФайлаСЦБ.ЦеннаяБумага КАК ЦеннаяБумага,
		|	ДанныеФайлаСЦБ.КомиссияЗаРасчет + ДанныеФайлаСЦБ.КомиссияЗаЗаключение КАК Комиссия
		|ИЗ
		|	ДанныеФайлаСЦБ КАК ДанныеФайлаСЦБ
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПокупкаЦеннойБумаги КАК ПокупкаЦеннойБумаги
		|		ПО ДанныеФайлаСЦБ.НомерСделки = ПокупкаЦеннойБумаги.НомерСделки
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПродажаЦеннойБумаги КАК ПродажаЦеннойБумаги
		|		ПО ДанныеФайлаСЦБ.НомерСделки = ПродажаЦеннойБумаги.НомерСделки
		|ГДЕ
		|	ПокупкаЦеннойБумаги.Ссылка ЕСТЬ NULL
		|	И ПродажаЦеннойБумаги.Ссылка ЕСТЬ NULL";
	
	Запрос.УстановитьПараметр("ТЗ", ТЗ);
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		// Создать документ
		Если ВыборкаДетальныеЗаписи.ТипСделки = "Покупка" Тогда
		
			НовыйДокумент = Документы.ПокупкаЦеннойБумаги.СоздатьДокумент();
		
		ИначеЕсли ВыборкаДетальныеЗаписи.ТипСделки = "Продажа" Тогда
			
			НовыйДокумент = Документы.ПродажаЦеннойБумаги.СоздатьДокумент();
			
		Иначе // Ошибка, хотя это можно контролировать схемой xml
			
			Продолжить;
		
		КонецЕсли;

		НовыйДокумент.БрокерскийСчет = БрокерскийСчет;
		ЗаполнитьЗначенияСвойств(НовыйДокумент, ВыборкаДетальныеЗаписи);
		НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
		
		// Добавить в последовательность
		ДобавитьВПоследовательность(НовыйДокумент);

		ЗагруженоСделок = ЗагруженоСделок + 1;
		
	КонецЦикла;
	
	ТЗ.Очистить();
	
		

КонецПроцедуры
 
Процедура ДобавитьВПоследовательность(Документ)

		// Добавить в последовательность
		НаборЗаписейРегистрации = Последовательности.ЗагрузкаОтчетов.СоздатьНаборЗаписей();
		НаборЗаписейРегистрации.Отбор.Регистратор.Установить(Документ.Ссылка);
		ЗаписьНабораПоследовательности = НаборЗаписейРегистрации.Добавить();
		ЗаписьНабораПоследовательности.Регистратор = Документ.Ссылка;
		ЗаписьНабораПоследовательности.Период = Документ.Дата;
		ЗаписьНабораПоследовательности.БрокерскийСчет = Документ.БрокерскийСчет;
		НаборЗаписейРегистрации.Записать();

КонецПроцедуры
 
