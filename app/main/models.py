from django.db import models
from django.conf import settings
from django.utils import timezone
import random, string
from datetime import datetime
from django.db import connection
from colorful.fields import RGBColorField
from django.utils.timezone import now
from django.contrib.postgres.fields import JSONField


def fnow():
    return timezone.make_aware(datetime.now(),timezone.get_default_timezone()).astimezone(timezone.get_default_timezone())


def nvl(pval, pdefault = None):
    return pval if pval else pdefault if pdefault else ''


def random_generator(size=8, chars=string.ascii_lowercase + string.digits):
    return ''.join(random.choice(chars) for x in range(size))


class Region(models.Model):
    name = models.CharField(max_length=200, blank=True, null=True, verbose_name='Наименование')
    image = models.ImageField(max_length=500, blank=True, null=True, verbose_name='Изображение')
    description = models.TextField(blank=True, null=True, verbose_name='Наименование')
    created = models.DateTimeField(blank=True, null=True)
    creator = models.ForeignKey(settings.AUTH_USER_MODEL, models.DO_NOTHING, related_name='+', blank=True, null=True)
    modified = models.DateTimeField(blank=True, null=True)
    modifier = models.ForeignKey(settings.AUTH_USER_MODEL, models.DO_NOTHING, related_name='+', blank=True, null=True)
    deleted = models.DateTimeField(blank=True, null=True)
    deleter = models.ForeignKey(settings.AUTH_USER_MODEL, models.DO_NOTHING, related_name='+', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tregion'
        verbose_name = 'Регион'
        verbose_name_plural = 'Регионы'

    def __str__(self):
        return self.name


class Support(models.Model):
    url = models.CharField(max_length=200, blank=True, null=True, verbose_name='URL записи')
    small_name = models.CharField(max_length=200, blank=True, null=True, verbose_name='Краткое наименование меры поддержки')
    full_name = models.CharField(max_length=200, blank=True, null=True, verbose_name='Полное наименование меры поддержки')
    number_npa = models.CharField(max_length=200, blank=True, null=True, verbose_name='Номер НПА меры поддержки')
    date_npa = models.CharField(max_length=200, blank=True, null=True, verbose_name='Дата НПА меры поддержки')
    npa_name = models.CharField(max_length=200, blank=True, null=True, verbose_name='Полное наименование НПА (ЛНА) меры поддержки')
    description = models.TextField(blank=True, null=True, verbose_name='Описание меры поддержки')
    purpose = models.CharField(max_length=200, blank=True, null=True, verbose_name='Цели предоставления поддержки')
    objective = models.CharField(max_length=200, blank=True, null=True, verbose_name='Задачи предоставления поддержки')
    type_mera = models.CharField(max_length=200, blank=True, null=True, verbose_name='Тип меры поддержки')
    type_format_support = models.CharField(max_length=200, blank=True, null=True, verbose_name='Формат предоставления поддержки')
    srok_vozvrata = models.CharField(max_length=200, blank=True, null=True, verbose_name='Срок возврата предоставленной поддержки')
    procent_vozvrata = models.CharField(max_length=200, blank=True, null=True, verbose_name='Процентная ставка предоставления поддержки')
    guarante_periode = models.CharField(max_length=200, blank=True, null=True, verbose_name='Срок предоставления гарантии')
    guarantee_cost = models.CharField(max_length=200, blank=True, null=True, verbose_name='Стоимость предоставления гарантии')
    appliance_id = models.CharField(max_length=200, blank=True, null=True, verbose_name='Список поддерживаемых отраслей')
    okved2 = models.CharField(max_length=200, blank=True, null=True, verbose_name='Список кодов ОКВЭД2, к которым применима мера поддержки')
    complexity = models.TextField(blank=True, null=True, verbose_name='Список типов проблем, на решение которых направлена мера поддержки')
    amount_of_support = models.TextField(blank=True, null=True, verbose_name='Методика расчета величины поддержки')
    regularity_select = models.CharField(max_length=200, blank=True, null=True, verbose_name='Регулярность оказания меры поддержки')
    period = models.CharField(max_length=200, blank=True, null=True, verbose_name='Периодичность рассмотрения заявок на предоставление меры поддержки')
    dogovor = models.CharField(max_length=200, blank=True, null=True, verbose_name='Распространяется ли мера поддержки на действующие договоры')
    gos_program = models.CharField(max_length=200, blank=True, null=True, verbose_name='Список госпрограмм, в которые входит мера поддержки')
    event = models.CharField(max_length=200, blank=True, null=True, verbose_name='Мероприятия, в которые входит мера поддержки')
    dop_info = models.CharField(max_length=200, blank=True, null=True, verbose_name='Дополнительная информация по мере поддержки')
    is_not_active = models.CharField(max_length=200, blank=True, null=True, verbose_name='Мера поддержки неактивна')
    prichina_not_act = models.CharField(max_length=200, blank=True, null=True, verbose_name='Причина неактивности меры поддержки')
    req_zayavitel = models.CharField(max_length=200, blank=True, null=True, verbose_name='Требования к заявителю')
    request_project = models.CharField(max_length=200, blank=True, null=True, verbose_name='Требования к проекту')
    is_sofinance = models.CharField(max_length=200, blank=True, null=True, verbose_name='Необходимость софинансирования проекта')
    dolya_isofinance = models.CharField(max_length=200, blank=True, null=True, verbose_name='Доля необходимого софинансирования')
    budget_project = models.CharField(max_length=200, blank=True, null=True, verbose_name='Допустимый бюджет проекта')
    pokazatel_result = models.CharField(max_length=200, blank=True, null=True, verbose_name='Список показателей результативности проекта')
    territorial_level = models.CharField(max_length=200, blank=True, null=True, verbose_name='Территориальный уровень меры поддержки')
    region = models.ForeignKey(Region, models.DO_NOTHING, verbose_name='Регион')
    respons_structure = models.CharField(max_length=200, blank=True, null=True, verbose_name='Администратор меры поддержки')
    org_id = models.CharField(max_length=200, blank=True, null=True, verbose_name='Организация, предоставляющая меру поддержки')
    created = models.DateTimeField(blank=True, null=True, default=now)
    creator = models.ForeignKey(settings.AUTH_USER_MODEL, models.DO_NOTHING, related_name='+', blank=True, null=True)
    modified = models.DateTimeField(blank=True, null=True, default=now)
    modifier = models.ForeignKey(settings.AUTH_USER_MODEL, models.DO_NOTHING, related_name='+', blank=True, null=True)
    deleted = models.DateTimeField(blank=True, null=True)
    deleter = models.ForeignKey(settings.AUTH_USER_MODEL, models.DO_NOTHING, related_name='+', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tsupport'
        verbose_name = 'Мера поддержки'
        verbose_name_plural = 'Меры поддержки'

    def __str__(self):
        return self.small_name

