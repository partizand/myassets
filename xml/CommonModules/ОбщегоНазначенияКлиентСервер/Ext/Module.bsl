﻿
// Разложение строки адреса в структуру с параметрами
//
// Параметры:
// 	СтрокаURI - Строка - Адрес на сайте	
// 
// Возвращаемое значение:
// Структура - Разобранная строка
// 	* Протокол - строка - Протокол http, https, ftp и т.п.
// 	* Логин - Строка - Логин
// 	* Пароль - Строка - Пароль
// 	* ИмяСервера - Строка - ИмяСервера
// 	* Хост - Строка - Хост
// 	* Порт - Число, Неопределено - Порт
// 	* ПутьНаСервере - Строка - ПутьНаСервере
//

Функция СтруктураURI(СтрокаURI) Экспорт
    СтрокаURI = СокрЛП(СтрокаURI);
    
    Схема = "";
    Позиция = Найти(СтрокаURI, "://");
    Если Позиция > 0 Тогда
        Схема = НРег(Лев(СтрокаURI, Позиция - 1));
        СтрокаURI = Сред(СтрокаURI, Позиция + 3);
    КонецЕсли;
 
    СтрокаСоединения = СтрокаURI;
    ПутьНаСервере = "";
    Позиция = Найти(СтрокаСоединения, "/");
    Если Позиция > 0 Тогда
        ПутьНаСервере = Сред(СтрокаСоединения, Позиция + 1);
        СтрокаСоединения = Лев(СтрокаСоединения, Позиция - 1);
    КонецЕсли;
        
    СтрокаАвторизации = "";
    ИмяСервера = СтрокаСоединения;
    Позиция = Найти(СтрокаСоединения, "@");
    Если Позиция > 0 Тогда
        СтрокаАвторизации = Лев(СтрокаСоединения, Позиция - 1);
        ИмяСервера = Сред(СтрокаСоединения, Позиция + 1);
    КонецЕсли;
    
    Логин = СтрокаАвторизации;
    Пароль = "";
    Позиция = Найти(СтрокаАвторизации, ":");
    Если Позиция > 0 Тогда
        Логин = Лев(СтрокаАвторизации, Позиция - 1);
        Пароль = Сред(СтрокаАвторизации, Позиция + 1);
    КонецЕсли;
    
    Хост = ИмяСервера;
    Порт = "";
    Позиция = Найти(ИмяСервера, ":");
    Если Позиция > 0 Тогда
        Хост = Лев(ИмяСервера, Позиция - 1);
        Порт = Сред(ИмяСервера, Позиция + 1);
    КонецЕсли;
    
    Результат = Новый Структура;
    Результат.Вставить("Протокол", Схема);
    Результат.Вставить("Логин", Логин);
    Результат.Вставить("Пароль", Пароль);
    Результат.Вставить("ИмяСервера", ИмяСервера);
    Результат.Вставить("Хост", Хост);
    Результат.Вставить("Порт", ?(Порт <> "", Число(Порт), Неопределено));
    Результат.Вставить("ПутьНаСервере", ПутьНаСервере);
    
    Возврат Результат;
КонецФункции

 
