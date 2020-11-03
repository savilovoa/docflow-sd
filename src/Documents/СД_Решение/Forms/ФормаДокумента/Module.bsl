
&НаКлиенте
&Вместо("Оповещение_РешениеПодготовленоВопрос")
Процедура ЧСД_Оповещение_РешениеПодготовленоВопрос(РезультатВопроса, ДополнительныеПараметры)
	
	Если РезультатВопроса=КодВозвратаДиалога.Нет Тогда
        Возврат;
        
    КонецЕсли;
    
    РезультатПроверки=РешениеЗаполненоКорректно();
    
    Если НЕ ПустаяСтрока(РезультатПроверки) Тогда
        ПоказатьПредупреждение(Неопределено, РезультатПроверки, 60, СД_ОбщееКлиентПовтИсп.ЗаголовокДиалога());
        Возврат;
        
    КонецЕсли;
    
    УстановитьФактВыполнения();
    
    УстанавливаемыйСтатусЗаявки=ПредопределенноеЗначение("Перечисление.СД_СтатусыЗаявок.Закрыта");
    
    Попытка
        Записать();
    Исключение
        ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ОписаниеОшибки());
        Возврат;
        
    КонецПопытки;
    
    РешениеПодготовленоУспешно=УстановитьРешениеПодготовленоЗаявкаЗакрыта();
    
    Если РешениеПодготовленоУспешно Тогда
		Оповестить("ЗадачаЗакрыта");
        ЭтаФорма.Закрыть();
        
    Иначе
        ФлагРешениеПодготовлено=Ложь;
        
    КонецЕсли;

КонецПроцедуры

&НаСервере	
Функция УстановитьРешениеПодготовленоЗаявкаЗакрыта()
	
	УстановитьПривилегированныйРежим(Истина);
	
	//отметим связанную задачу как выполненную
			
	СтруктураРезультатаФункции=СД_ЗадачиПроцессовВызовСервера.ВыполнитьОбработчикПослеВыполнения(ЗадачаРешения);
	
	Если НЕ СтруктураРезультатаФункции.ЗавершеноУспешно Тогда
		//если программная функция не выполнена, то и задачу считаем не выполненной
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Отметка выполнения не установлена из-за ошибки выполнения события ""ПослеВыполнения""'"));
		Возврат Ложь;
		
	КонецЕсли;
	
	Попытка
		ЗадачаОбъектаОбъект=ЗадачаРешения.ПолучитьОбъект();
		ЗадачаОбъектаОбъект.ВыполнитьЗадачу();
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ОписаниеОшибки());
		Возврат Ложь;		
	КонецПопытки;
	СД_ЗадачиПроцессовВызовСервера.УстановитьСостояниеЗадачи(ЗадачаРешения, Перечисления.СД_СостояниеЗадач.Выполнена);
	
//	Документы.СД_Заявка.ЗакрытьЗаявкуПринудительноСервером(ЗаявкаВТехПоддержку);
	
	Если Объект.Заявка.СпособДоставки=Перечисления.СД_СпособыСоздания.ЭлектроннаяПочта Тогда 
		СД_ИнтернетШлюзСервер.ОтправитьРешениеИнициатору(Объект.Ссылка);
	КонецЕсли;
	
	СД_ИнтернетШлюзСервер.ОтправитьРешениеИнициатору(Объект.Ссылка);
		
//	СД_ПроцессыВызовСервера.ОбработатьМаршрутПроцесса(ЗадачаРешения.БизнесПроцесс, ЗадачаРешения, СтруктураРезультатаФункции);
	
	Возврат Истина;

КонецФункции	

&НаКлиенте
Процедура ЧСД_ДобавитьФайлПосле(Команда)
	
	ОткрытьФорму("Справочник.Файлы.Форма.ФормаВыбораФайлаВПапках", ,,,,, Новый ОписаниеОповещения("Оповещение_ВыбранФайл", ЭтаФорма, Новый Структура), РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры
	
&НаКлиенте
Процедура Оповещение_ВыбранФайл(ВыбранныйФайл, ДопПараметры) Экспорт
	Если ВыбранныйФайл=Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ДобавитьОбъектВСписок(ВыбранныйФайл, "Файл");
	ОбновитьТаблицуПриложений();
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьОбъектВСписок(СсылкаНаОбъект, ИмяТипа)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда 
		Записать();
	КонецЕсли;
	
	ИдентификаторОбъекта=СсылкаНаОбъект.УникальныйИдентификатор();
	
	РегистрСсылок=РегистрыСведений.СД_СписокПриложений.СоздатьНаборЗаписей();
	РегистрСсылок.Отбор.ВладелецСсылки.Установить(Объект.Ссылка);
	РегистрСсылок.Отбор.ОбъектПриложения.Установить(СсылкаНаОбъект);
	
	РегистрСсылок.Прочитать();
	
	Если РегистрСсылок.Количество()>0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru='Данный объект уже присутствует в списке.';en='The object already exists in the list.'"));
		Возврат;
		
	КонецЕсли;
	
	НоваяЗапись=РегистрСсылок.Добавить();
	НоваяЗапись.ВладелецСсылки=Объект.Ссылка;
	НоваяЗапись.ОбъектПриложения=СсылкаНаОбъект;
	НоваяЗапись.Информация=ИмяТипа;
		
	Попытка
		РегистрСсылок.Записать(Истина);
		
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ОписаниеОшибки());
		Возврат;
		
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьТаблицуПриложений()
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос=Новый Запрос("ВЫБРАТЬ РАЗРЕШЕННЫЕ
	                    |	СД_СписокПриложений.ВладелецСсылки,
	                    |	СД_СписокПриложений.Примечание,
	                    |	СД_СписокПриложений.ОбъектПриложения,
	                    |	СД_СписокПриложений.Информация

	                    |ИЗ
	                    |	РегистрСведений.СД_СписокПриложений КАК СД_СписокПриложений
	                    |ГДЕ
	                    |	СД_СписокПриложений.ВладелецСсылки = &ВладелецСсылки
	                    |	И СД_СписокПриложений.ВладелецСсылки.ПометкаУдаления = ЛОЖЬ");
		
	Запрос.УстановитьПараметр("ВладелецСсылки", Объект.Ссылка);
	ТаблицаЗапроса=Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.Прямой);
	
	ПриложенияРешения.Загрузить(ТаблицаЗапроса);
		
КонецПроцедуры


&НаСервере
Процедура ЧСД_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	//ВладелецСсылка = Объект.Ссылка;
	ОбновитьТаблицуПриложений();
	
КонецПроцедуры

&НаСервере
Функция ЭтоТипФайл(СсылкаНаОбъект)
	Возврат (ТипЗнч(СсылкаНаОбъект)=Тип("СправочникСсылка.Файлы"));
КонецФункции

&НаКлиенте
Процедура ЧСД_ПриложенияРешенияВыборПосле(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтрокаТЧ=Элементы.ПриложенияРешения.ТекущиеДанные;

	СсылкаНаОбъект=СтрокаТЧ.ОбъектПриложения;
	Если СсылкаНаОбъект=Неопределено Тогда
		Возврат;
	КонецЕсли;
		
	Если ЭтоТипФайл(СсылкаНаОбъект) Тогда
		ДанныеФайла = РаботаСФайламиВызовСервера.ДанныеФайлаДляОткрытия(СсылкаНаОбъект, Неопределено, ЭтаФорма.УникальныйИдентификатор);
		РаботаСФайламиКлиент.Открыть(ДанныеФайла, ЭтаФорма.УникальныйИдентификатор);
	Иначе
		ПоказатьЗначение(Неопределено, СсылкаНаОбъект);
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция ЧСД_ПредметЗаявки(ОбъектЗаявка)
	Запрос=Новый Запрос("ВЫБРАТЬ
	                    |	СД_Заявка.Ч_Предмет КАК Ч_Предмет
	                    |ИЗ
	                    |	Документ.СД_Заявка КАК СД_Заявка
	                    |ГДЕ
	                    |	СД_Заявка.Ссылка = &Ссылка");
		
	Запрос.УстановитьПараметр("Ссылка", ОбъектЗаявка);
	Данные = Запрос.Выполнить().Выбрать();
	Если Данные.Следующий() и ЗначениеЗаполнено(Данные.Ч_Предмет) Тогда
		Возврат Данные.Ч_Предмет;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

&НаКлиенте
Процедура ЧСД_ОткрытьПисьмоПосле(Команда)
	
	Если НЕ ЗначениеЗаполнено(Объект.Заявка) Тогда
		Возврат;
	КонецЕсли;
	
	Предмет = ЧСД_ПредметЗаявки(Объект.Заявка);
	Если Предмет = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	стрПараметры = Новый Структура("Ключ", Предмет);
	ФормаОснования = ПолучитьФорму("Документ.ВходящееПисьмо.ФормаОбъекта", стрПараметры);
		
	Если  ФормаОснования <> Неопределено Тогда
		ФормаОснования.Открыть();
	КонецЕсли;
		
КонецПроцедуры

