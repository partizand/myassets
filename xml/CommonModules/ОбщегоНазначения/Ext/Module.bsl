﻿Функция СтрокаВДату(стрДата) Экспорт

	стрДата = СтрЗаменить(стрДата,"-","");
	стрДата = СтрЗаменить(стрДата," ","");
	стрДата = СтрЗаменить(стрДата,":","");
	Возврат Дата(стрДата);

КонецФункции // СтрокаВДату()
